import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../config/app_config.dart';
import '../screen/role_selection_screen.dart';
import 'package:http/http.dart' as http;

// 私聊会话类
class PrivateChat {
  final String userId;
  final String userName;
  final String userRole;
  final List<ChatMessage> messages;

  PrivateChat({
    required this.userId,
    required this.userName,
    required this.userRole,
    List<ChatMessage>? messages,
  }) : messages = messages ?? [];
}

class ChatService {
  final CharacterRole character;
  final String serverUrl;
  late StompClient stompClient;
  final Function(ChatMessage) onMessageReceived;
  final Function(List<CharacterRole>) onUsersReceived;
  final Function(String)? onError;
  bool isConnected = false;

  // 保存在线用户列表
  List<CharacterRole> onlineUsers = [];

  // 存储与各个用户的私聊会话
  Map<String, PrivateChat> privateChats = {};

  ChatService({
    required this.serverUrl,
    required this.character,
    required this.onMessageReceived,
    required this.onUsersReceived,
    this.onError,
  }) {
    // 去除URL中可能的协议前缀和末尾斜杠，确保格式正确
    String cleanServerUrl = serverUrl;
    if (cleanServerUrl.startsWith('http://')) {
      cleanServerUrl = cleanServerUrl.substring(7);
    } else if (cleanServerUrl.startsWith('https://')) {
      cleanServerUrl = cleanServerUrl.substring(8);
    }
    if (cleanServerUrl.endsWith('/')) {
      cleanServerUrl = cleanServerUrl.substring(0, cleanServerUrl.length - 1);
    }

    print('正在连接到WebSocket: ws://$cleanServerUrl/ws');

    // 如果配置了直接使用SockJS，则直接使用SockJS连接
    if (AppConfig.enableSockJS) {
      _connectWithSockJS(cleanServerUrl);
    } else {
      _connectWithWebSocket(cleanServerUrl);
    }
  }

  // 使用标准WebSocket连接
  void _connectWithWebSocket(String serverUrl) {
    stompClient = StompClient(
      config: StompConfig(
        url: 'ws://$serverUrl/ws',
        onConnect: onConnect,
        onWebSocketError: (dynamic error) {
          print('WebSocket 错误: $error');
          if (onError != null) {
            onError!('连接失败: $error');
          }
          // 尝试使用SockJS作为备用连接方式
          _connectWithSockJS(serverUrl);
        },
        onStompError: (StompFrame frame) {
          print('STOMP 错误: ${frame.body}');
          if (onError != null) {
            onError!('STOMP 错误: ${frame.body}');
          }
        },
        onDisconnect: (StompFrame frame) {
          print('断开连接: ${frame.body}');
          isConnected = false;
        },
        reconnectDelay: const Duration(milliseconds: 5000), // 5秒后重连
        webSocketConnectHeaders: {'Origin': 'http://$serverUrl'},
      ),
    );
  }

  // 使用SockJS连接
  void _connectWithSockJS(String serverUrl) {
    print('使用SockJS连接: http://$serverUrl/ws');

    stompClient = StompClient(
      config: StompConfig(
        url: 'http://$serverUrl/ws',
        onConnect: onConnect,
        useSockJS: true, // 启用SockJS
        onWebSocketError: (dynamic error) {
          print('SockJS连接失败: $error');
          if (onError != null) {
            onError!('所有连接方式都失败: $error，请检查服务器地址和网络');
          }
        },
        onStompError: (StompFrame frame) {
          print('SockJS STOMP 错误: ${frame.body}');
          if (onError != null) {
            onError!('STOMP 错误: ${frame.body}');
          }
        },
        onDisconnect: (StompFrame frame) {
          print('SockJS断开连接: ${frame.body}');
          isConnected = false;
        },
        reconnectDelay: const Duration(milliseconds: 5000),
        webSocketConnectHeaders: {'Origin': 'http://$serverUrl'},
      ),
    );
  }

  void connect() {
    try {
      stompClient.activate();
    } catch (e) {
      print('连接错误: $e');
      if (onError != null) {
        onError!('连接错误: $e');
      }
    }
  }

  void disconnect() {
    if (isConnected) {
      try {
        // 发送离开消息
        sendLeaveMessage();
        stompClient.deactivate();
        isConnected = false;
      } catch (e) {
        print('断开连接错误: $e');
      }
    }
  }

  void onConnect(StompFrame frame) {
    isConnected = true;
    print('已连接到 WebSocket 服务器');

    try {
      // 订阅用户状态变化（用户加入/离开）
      stompClient.subscribe(
        destination: '/topic/users',
        callback: (StompFrame frame) {
          if (frame.body != null) {
            try {
              Map<String, dynamic> result = json.decode(frame.body!);
              ChatMessage message = ChatMessage.fromJson(result);

              if (message.type == ChatMessage.TYPE_USERS) {
                _handleUsersList(message.content);
              } else if (message.type == ChatMessage.TYPE_JOIN ||
                  message.type == ChatMessage.TYPE_LEAVE) {
                // 用户加入或离开的通知
                onMessageReceived(message);
              }
            } catch (e) {
              print('处理用户列表错误: $e');
            }
          }
        },
      );

      // 订阅私聊消息
      stompClient.subscribe(
        destination: '/user/${character.id}/topic/private',
        callback: (StompFrame frame) {
          if (frame.body != null) {
            try {
              Map<String, dynamic> result = json.decode(frame.body!);
              ChatMessage message = ChatMessage.fromJson(result);

              // 如果消息是自己发送的，则跳过（因为已经在本地添加过了）
              if (message.sender == character.id) {
                return;
              }

              // 只处理由他人发来的消息
              _addMessageToPrivateChat(message);
              onMessageReceived(message);
            } catch (e) {
              print('处理私聊消息错误: $e');
            }
          }
        },
      );

      // 发送加入消息，包含角色信息
      sendJoinMessage();

      // 主动请求在线用户列表
      Future.delayed(const Duration(milliseconds: 500), () {
        requestOnlineUsers();
      });
    } catch (e) {
      print('订阅错误: $e');
      if (onError != null) {
        onError!('订阅错误: $e');
      }
    }
  }

  void _addMessageToPrivateChat(ChatMessage message) {
    // 确定消息的另一方用户ID
    String otherUserId =
        message.sender == character.id ? message.receiver! : message.sender;

    if (!privateChats.containsKey(otherUserId)) {
      // 如果不存在与该用户的私聊，创建一个
      final user = onlineUsers.firstWhere(
        (u) => u.id == otherUserId,
        orElse:
            () => CharacterRole(
              id: otherUserId,
              name: otherUserId,
              description: '',
              imageAsset: '',
              color: Colors.grey,
            ),
      );

      privateChats[otherUserId] = PrivateChat(
        userId: otherUserId,
        userName: user.name,
        userRole: user.name,
      );
    }

    // 添加消息到私聊
    privateChats[otherUserId]!.messages.add(message);
  }

  // 获取与特定用户的私聊消息
  List<ChatMessage> getPrivateChatMessages(String userId) {
    if (privateChats.containsKey(userId)) {
      return privateChats[userId]!.messages;
    }
    return [];
  }

  void _handleUsersList(String userListContent) {
    try {
      // 打印原始用户列表数据
      print('收到用户列表数据: $userListContent');

      // 解析用户列表字符串
      List<String> userEntries = userListContent.split(',');
      List<CharacterRole> users = [];

      for (String entry in userEntries) {
        List<String> parts = entry.split(':');
        if (parts.length == 2) {
          String userId = parts[0];
          String roleName = parts[1];

          // 如果是自己，跳过
          if (userId == character.id) continue;

          print('添加在线用户: id=$userId, role=$roleName');

          users.add(
            CharacterRole(
              id: userId,
              name: roleName,
              description: '', // 无描述
              imageAsset: '', // 无图片
              color: _getRoleColor(roleName),
            ),
          );
        }
      }

      print('解析后在线用户数量: ${users.length}');
      onlineUsers = users;

      // 通知UI更新
      onUsersReceived(onlineUsers);
    } catch (e) {
      print('解析用户列表错误: $e');
    }
  }

  Color _getRoleColor(String roleName) {
    switch (roleName) {
      case '吕布':
        return Colors.red.shade700;
      case '张飞':
        return Colors.black;
      case '关羽':
        return Colors.green.shade800;
      case '曹操':
        return Colors.blue.shade900;
      default:
        return Colors.amber.shade800; // 自定义角色默认颜色
    }
  }

  void sendJoinMessage() {
    try {
      if (isConnected) {
        ChatMessage message = ChatMessage(
          type: ChatMessage.TYPE_JOIN,
          content: '${character.name} 进入了聊天',
          sender: character.id,
          role: character.name,
          time: _getCurrentTime(),
        );

        stompClient.send(
          destination: '/app/chat.addUser',
          body: json.encode(message.toJson()),
        );
      }
    } catch (e) {
      print('发送加入消息错误: $e');
    }
  }

  void sendLeaveMessage() {
    try {
      if (isConnected) {
        ChatMessage message = ChatMessage(
          type: ChatMessage.TYPE_LEAVE,
          content: '${character.name} 离开了聊天',
          sender: character.id,
          role: character.name,
          time: _getCurrentTime(),
        );

        stompClient.send(
          destination: '/app/chat.sendMessage',
          body: json.encode(message.toJson()),
        );
      }
    } catch (e) {
      print('发送离开消息错误: $e');
    }
  }

  void sendPrivateMessage(String receiverId, String content) {
    if (!isConnected) {
      if (onError != null) {
        onError!('无法发送消息：未连接');
      }
      return;
    }

    try {
      // 生成唯一消息ID
      final String messageId =
          '${DateTime.now().millisecondsSinceEpoch}_${character.id}';

      ChatMessage message = ChatMessage(
        id: messageId,
        type: ChatMessage.TYPE_PRIVATE,
        content: content,
        sender: character.id,
        receiver: receiverId,
        role: character.name,
        time: _getCurrentTime(),
      );

      // 保存到私聊会话
      _addMessageToPrivateChat(message);

      // 通知UI（先通知UI让消息立即显示）
      onMessageReceived(message);

      // 只发送到服务器，但不订阅自己的消息回传
      stompClient.send(
        destination: '/app/chat.sendPrivateMessage',
        body: json.encode(message.toJson()),
      );
    } catch (e) {
      print('发送私聊消息错误: $e');
      if (onError != null) {
        onError!('发送私聊消息错误: $e');
      }
    }
  }

  void requestOnlineUsers() {
    try {
      if (isConnected) {
        print('请求在线用户列表...');
        ChatMessage message = ChatMessage(
          type: ChatMessage.TYPE_CHAT,
          content: '',
          sender: character.id,
          role: character.name,
          time: _getCurrentTime(),
        );

        // 确保用户订阅了正确的个人频道
        stompClient.subscribe(
          destination: '/user/${character.id}/topic/users',
          callback: (StompFrame frame) {
            if (frame.body != null) {
              try {
                print('收到个人用户列表更新: ${frame.body}');
                Map<String, dynamic> result = json.decode(frame.body!);
                ChatMessage message = ChatMessage.fromJson(result);
                if (message.type == ChatMessage.TYPE_USERS) {
                  _handleUsersList(message.content);
                }
              } catch (e) {
                print('处理个人用户列表错误: $e');
              }
            }
          },
        );

        stompClient.send(
          destination: '/app/chat.getOnlineUsers',
          body: json.encode(message.toJson()),
        );
      }
    } catch (e) {
      print('请求用户列表错误: $e');
    }
  }

  String _getCurrentTime() {
    return DateFormat('HH:mm:ss').format(DateTime.now());
  }

  // 获取历史聊天记录
  Future<void> loadHistoricalMessages(String otherUserId) async {
    if (!isConnected) return;

    try {
      // 构建API URL
      final url =
          '${AppConfig.httpUrl}/api/messages/private?userId1=${character.id}&userId2=$otherUserId';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> messagesJson = jsonDecode(response.body);
        List<ChatMessage> messages =
            messagesJson.map((json) => ChatMessage.fromJson(json)).toList();

        // 将历史消息添加到私聊
        if (!privateChats.containsKey(otherUserId)) {
          final user = onlineUsers.firstWhere(
            (u) => u.id == otherUserId,
            orElse:
                () => CharacterRole(
                  id: otherUserId,
                  name: otherUserId,
                  description: '',
                  imageAsset: '',
                  color: Colors.grey,
                ),
          );

          privateChats[otherUserId] = PrivateChat(
            userId: otherUserId,
            userName: user.name,
            userRole: user.name,
          );
        }

        // 清除现有消息并添加历史消息
        privateChats[otherUserId]!.messages.clear();

        // 按时间排序
        messages.sort((a, b) {
          if (a.time.isEmpty || b.time.isEmpty) return 0;
          return a.time.compareTo(b.time);
        });

        privateChats[otherUserId]!.messages.addAll(messages);

        // 通知消息已加载
        for (var message in messages) {
          onMessageReceived(message);
        }

        print('已加载 ${messages.length} 条历史消息');
      } else {
        print('获取历史消息失败: ${response.statusCode}');
        if (onError != null) {
          onError!('获取历史消息失败: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('获取历史消息错误: $e');
      if (onError != null) {
        onError!('获取历史消息错误: $e');
      }
    }
  }
}
