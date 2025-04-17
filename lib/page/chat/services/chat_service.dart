// import 'dart:convert';
// import 'package:stomp_dart_client/stomp_dart_client.dart';
// import 'package:intl/intl.dart';
// import 'package:flutter/material.dart';
// import '../models/chat_message.dart';
// import '../config/app_config.dart';
// import '../screen/role_selection_screen.dart';
// import 'package:http/http.dart' as http;
// import 'dart:async';
// import 'package:connectivity_plus/connectivity_plus.dart';

// // 私聊会话类
// class PrivateChat {
//   final String userId;
//   final String userName;
//   final String userRole;
//   final List<ChatMessage> messages;

//   PrivateChat({
//     required this.userId,
//     required this.userName,
//     required this.userRole,
//     List<ChatMessage>? messages,
//   }) : messages = messages ?? [];
// }

// class ChatService {
//   final CharacterRole character;
//   final String serverUrl;
//   late StompClient stompClient;
//   final Function(ChatMessage) onMessageReceived;
//   final Function(List<CharacterRole>) onUsersReceived;
//   final Function(String)? onError;
//   Function()? onConnectedCallback; // 重命名为onConnectedCallback
//   bool isConnected = false;

//   // 保存在线用户列表
//   List<CharacterRole> onlineUsers = [];

//   // 存储与各个用户的私聊会话
//   Map<String, PrivateChat> privateChats = {};

//   // 存储会话ID
//   String? sessionId;

//   // 添加心跳定时器
//   Timer? _heartbeatTimer;

//   // 添加网络状态监听
//   StreamSubscription? _connectivitySubscription;
//   bool _wasConnected = false;
//   int _reconnectAttempts = 0;

//   ChatService({
//     required this.serverUrl,
//     required this.character,
//     required this.onMessageReceived,
//     required this.onUsersReceived,
//     this.onError,
//   }) {
//     // 初始化网络监听
//     _initConnectivityListener();

//     // 去除URL中可能的协议前缀和末尾斜杠，确保格式正确
//     String cleanServerUrl = serverUrl;
//     if (cleanServerUrl.startsWith('http://')) {
//       cleanServerUrl = cleanServerUrl.substring(7);
//     } else if (cleanServerUrl.startsWith('https://')) {
//       cleanServerUrl = cleanServerUrl.substring(8);
//     }
//     if (cleanServerUrl.endsWith('/')) {
//       cleanServerUrl = cleanServerUrl.substring(0, cleanServerUrl.length - 1);
//     }

//     print('正在连接到WebSocket: ws://$cleanServerUrl/ws');

//     // 如果配置了直接使用SockJS，则直接使用SockJS连接
//     if (AppConfig.enableSockJS) {
//       _connectWithSockJS(cleanServerUrl);
//     } else {
//       _connectWithWebSocket(cleanServerUrl);
//     }
//   }

//   // 初始化网络状态监听器
//   void _initConnectivityListener() {
//     _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
//       result,
//     ) {
//       print('网络状态变化: $result');
//       if (result == ConnectivityResult.none) {
//         // 断网
//         if (isConnected) {
//           _wasConnected = true;
//           isConnected = false; // 标记已断开
//           print('网络已断开，WebSocket连接可能已断开');
//           if (onError != null) {
//             onError!('网络已断开，等待网络恢复后将自动重连');
//           }
//         }
//       } else {
//         // 网络恢复
//         if (_wasConnected && !isConnected) {
//           print('网络已恢复，尝试重新连接');
//           // 延迟几秒后重连，确保网络稳定
//           Future.delayed(const Duration(seconds: 2), () {
//             if (!isConnected) {
//               _reconnectWithBackoff();
//             }
//           });
//         }
//       }
//     });
//   }

//   // 使用退避算法重连
//   void _reconnectWithBackoff() {
//     // 最大重连次数
//     if (_reconnectAttempts > 5) {
//       if (onError != null) {
//         onError!('重连失败，请手动尝试重新连接');
//       }
//       _reconnectAttempts = 0;
//       _wasConnected = false;
//       return;
//     }

//     // 计算退避时间（指数增长）
//     int backoffTime = 1000 * (1 << _reconnectAttempts);
//     if (backoffTime > 30000) backoffTime = 30000; // 最大30秒

//     print('尝试第 ${_reconnectAttempts + 1} 次重连，等待 ${backoffTime}ms');
//     Future.delayed(Duration(milliseconds: backoffTime), () {
//       if (!isConnected) {
//         connect();
//         _reconnectAttempts++;
//       } else {
//         // 已连接，重置计数
//         _reconnectAttempts = 0;
//         _wasConnected = false;
//       }
//     });
//   }

//   // 使用标准WebSocket连接
//   void _connectWithWebSocket(String serverUrl) {
//     Map<String, String> connectHeaders = {'Origin': 'http://$serverUrl'};

//     // 如果有会话ID，添加到连接头
//     if (sessionId != null) {
//       connectHeaders['X-Session-ID'] = sessionId!;
//     }

//     stompClient = StompClient(
//       config: StompConfig(
//         url: 'ws://$serverUrl/ws',
//         onConnect: (frame) => onConnect(frame),
//         onWebSocketError: (dynamic error) {
//           print('WebSocket 错误: $error');
//           if (onError != null) {
//             onError!('连接失败: $error');
//           }
//           // 尝试使用SockJS作为备用连接方式
//           _connectWithSockJS(serverUrl);
//         },
//         onStompError: (StompFrame frame) {
//           print('STOMP 错误: ${frame.body}');
//           if (onError != null) {
//             onError!('STOMP 错误: ${frame.body}');
//           }
//         },
//         onDisconnect: (StompFrame frame) {
//           print('断开连接: ${frame.body}');
//           isConnected = false;
//           _stopHeartbeat(); // 停止心跳
//         },
//         reconnectDelay: const Duration(milliseconds: 5000), // 5秒后重连
//         // webSocketConnectHeaders: {'Origin': 'http://$serverUrl'},
//         webSocketConnectHeaders: connectHeaders,
//       ),
//     );
//   }

//   // 使用SockJS连接
//   void _connectWithSockJS(String serverUrl) {
//     print('使用SockJS连接: http://$serverUrl/ws');

//     Map<String, String> connectHeaders = {'Origin': 'http://$serverUrl'};

//     // 如果有会话ID，添加到连接头
//     if (sessionId != null) {
//       connectHeaders['X-Session-ID'] = sessionId!;
//     }
//     stompClient = StompClient(
//       config: StompConfig(
//         url: 'http://$serverUrl/ws',
//         onConnect: (frame) => onConnect(frame),
//         useSockJS: true, // 启用SockJS
//         onWebSocketError: (dynamic error) {
//           print('SockJS连接失败: $error');
//           if (onError != null) {
//             onError!('所有连接方式都失败: $error，请检查服务器地址和网络');
//           }
//         },
//         onStompError: (StompFrame frame) {
//           print('SockJS STOMP 错误: ${frame.body}');
//           if (onError != null) {
//             onError!('STOMP 错误: ${frame.body}');
//           }
//         },
//         onDisconnect: (StompFrame frame) {
//           print('SockJS断开连接: ${frame.body}');
//           isConnected = false;
//           _stopHeartbeat(); // 停止心跳
//         },
//         reconnectDelay: const Duration(milliseconds: 5000),
//         // webSocketConnectHeaders: {'Origin': 'http://$serverUrl'},
//         webSocketConnectHeaders: connectHeaders,
//       ),
//     );
//   }

//   void connect() {
//     try {
//       stompClient.activate();
//     } catch (e) {
//       print('连接错误: $e');
//       if (onError != null) {
//         onError!('连接错误: $e');
//       }
//       // 尝试重连
//       _reconnectWithBackoff();
//     }
//   }

//   void disconnect() {
//     try {
//       // 取消网络监听
//       _connectivitySubscription?.cancel();
//       _connectivitySubscription = null;

//       // 停止心跳
//       _stopHeartbeat();

//       // 重置重连计数
//       _reconnectAttempts = 0;
//       _wasConnected = false;

//       if (isConnected) {
//         // 发送离开消息
//         sendLeaveMessage();
//         stompClient.deactivate();
//         isConnected = false;
//       }
//     } catch (e) {
//       print('断开连接错误: $e');
//     }
//   }

//   void onConnect(StompFrame frame) {
//     isConnected = true;
//     print('已连接到 WebSocket 服务器');

//     // 调用onConnectedCallback回调
//     if (onConnectedCallback != null) {
//       onConnectedCallback!();
//     }

//     // 启动心跳检测
//     _startHeartbeat();

//     try {
//       stompClient.subscribe(
//         destination: '/user/${character.id}/topic/session.resumed',
//         callback: (StompFrame frame) {
//           if (frame.body != null) {
//             print('会话恢复通知: ${frame.body}');
//           }
//         },
//       );

//       // 订阅错误消息
//       stompClient.subscribe(
//         destination: '/user/${character.id}/topic/errors',
//         callback: (StompFrame frame) {
//           if (frame.body != null) {
//             print('收到错误消息: ${frame.body}');
//             try {
//               Map<String, dynamic> result = json.decode(frame.body!);
//               if (onError != null) {
//                 onError!(result['content'] ?? '未知错误');
//               }
//             } catch (e) {
//               print('解析错误消息失败: $e');
//             }
//           }
//         },
//       );
//       // 订阅用户状态变化（用户加入/离开）
//       stompClient.subscribe(
//         destination: '/topic/users',
//         callback: (StompFrame frame) {
//           if (frame.body != null) {
//             try {
//               Map<String, dynamic> result = json.decode(frame.body!);
//               ChatMessage message = ChatMessage.fromJson(result);

//               if (message.type == ChatMessage.TYPE_USERS) {
//                 _handleUsersList(message.content);
//               } else if (message.type == ChatMessage.TYPE_JOIN ||
//                   message.type == ChatMessage.TYPE_LEAVE) {
//                 // 用户加入或离开的通知
//                 onMessageReceived(message);
//               }
//             } catch (e) {
//               print('处理用户列表错误: $e');
//             }
//           }
//         },
//       );

//       // 订阅私聊消息
//       stompClient.subscribe(
//         destination: '/user/${character.id}/topic/private',
//         callback: (StompFrame frame) {
//           if (frame.body != null) {
//             try {
//               Map<String, dynamic> result = json.decode(frame.body!);
//               ChatMessage message = ChatMessage.fromJson(result);

//               // 如果消息是自己发送的，则跳过（因为已经在本地添加过了）
//               if (message.sender == character.id) {
//                 return;
//               }

//               // 只处理由他人发来的消息
//               _addMessageToPrivateChat(message);
//               onMessageReceived(message);
//             } catch (e) {
//               print('处理私聊消息错误: $e');
//             }
//           }
//         },
//       );

//       // 发送加入消息，包含角色信息
//       sendJoinMessage();

//       // 主动请求在线用户列表
//       Future.delayed(const Duration(milliseconds: 500), () {
//         requestOnlineUsers();
//       });
//     } catch (e) {
//       print('订阅错误: $e');
//       if (onError != null) {
//         onError!('订阅错误: $e');
//       }
//     }
//   }

//   void _addMessageToPrivateChat(ChatMessage message) {
//     // 确定消息的另一方用户ID
//     String otherUserId =
//         message.sender == character.id ? message.receiver! : message.sender;

//     if (!privateChats.containsKey(otherUserId)) {
//       // 如果不存在与该用户的私聊，创建一个
//       final user = onlineUsers.firstWhere(
//         (u) => u.id == otherUserId,
//         orElse:
//             () => CharacterRole(
//               id: otherUserId,
//               name: otherUserId,
//               description: '',
//               imageAsset: '',
//               color: Colors.grey,
//             ),
//       );

//       privateChats[otherUserId] = PrivateChat(
//         userId: otherUserId,
//         userName: user.name,
//         userRole: user.name,
//       );
//     }

//     // 添加消息到私聊
//     privateChats[otherUserId]!.messages.add(message);
//   }

//   // 获取与特定用户的私聊消息
//   List<ChatMessage> getPrivateChatMessages(String userId) {
//     if (privateChats.containsKey(userId)) {
//       return privateChats[userId]!.messages;
//     }
//     return [];
//   }

//   void _handleUsersList(String userListContent) {
//     try {
//       // 打印原始用户列表数据
//       print('收到用户列表数据: $userListContent');

//       // 解析用户列表字符串
//       List<String> userEntries = userListContent.split(',');
//       List<CharacterRole> users = [];

//       for (String entry in userEntries) {
//         List<String> parts = entry.split(':');
//         if (parts.length == 2) {
//           String userId = parts[0];
//           String roleName = parts[1];

//           // 如果是自己，跳过
//           if (userId == character.id) continue;

//           print('添加在线用户: id=$userId, role=$roleName');

//           users.add(
//             CharacterRole(
//               id: userId,
//               name: roleName,
//               description: '', // 无描述
//               imageAsset: '', // 无图片
//               color: _getRoleColor(roleName),
//             ),
//           );
//         }
//       }

//       print('解析后在线用户数量: ${users.length}');
//       onlineUsers = users;

//       // 通知UI更新
//       onUsersReceived(onlineUsers);
//     } catch (e) {
//       print('解析用户列表错误: $e');
//     }
//   }

//   Color _getRoleColor(String roleName) {
//     switch (roleName) {
//       case '吕布':
//         return Colors.red.shade700;
//       case '张飞':
//         return Colors.black;
//       case '关羽':
//         return Colors.green.shade800;
//       case '曹操':
//         return Colors.blue.shade900;
//       default:
//         return Colors.amber.shade800; // 自定义角色默认颜色
//     }
//   }

//   void sendJoinMessage() {
//     try {
//       if (isConnected) {
//         ChatMessage message = ChatMessage(
//           type: ChatMessage.TYPE_JOIN,
//           content: '${character.name} 进入了聊天',
//           sender: character.id,
//           role: character.name,
//           time: _getCurrentTime(),
//         );

//         stompClient.send(
//           destination: '/app/chat.addUser',
//           body: json.encode(message.toJson()),
//         );

//         // 接收服务器返回的消息，可能包含会话ID
//         stompClient.subscribe(
//           destination: '/topic/public',
//           callback: (StompFrame frame) {
//             if (frame.body != null) {
//               try {
//                 // 解析响应
//                 Map<String, dynamic> result = json.decode(frame.body!);
//                 String content = result['content'] ?? '';
//                 if (content.contains(';')) {
//                   List<String> parts = content.split(';');
//                   if (parts.length > 1) {
//                     Map<String, dynamic> additionalData = json.decode(parts[1]);
//                     if (additionalData.containsKey('sessionId')) {
//                       sessionId = additionalData['sessionId'];
//                       print('收到会话ID: $sessionId');
//                     }
//                   }
//                 }
//               } catch (e) {
//                 print('处理加入响应错误: $e');
//               }
//             }
//           },
//         );
//       }
//     } catch (e) {
//       print('发送加入消息错误: $e');
//     }
//   }

//   void sendLeaveMessage() {
//     try {
//       if (isConnected) {
//         ChatMessage message = ChatMessage(
//           type: ChatMessage.TYPE_LEAVE,
//           content: '${character.name} 离开了聊天',
//           sender: character.id,
//           role: character.name,
//           time: _getCurrentTime(),
//         );

//         stompClient.send(
//           destination: '/app/chat.sendMessage',
//           body: json.encode(message.toJson()),
//         );
//       }
//     } catch (e) {
//       print('发送离开消息错误: $e');
//     }
//   }

//   void sendPrivateMessage(String receiverId, String content) {
//     if (!isConnected) {
//       if (onError != null) {
//         onError!('无法发送消息：未连接');
//       }
//       return;
//     }

//     try {
//       // 生成唯一消息ID
//       final String messageId =
//           '${DateTime.now().millisecondsSinceEpoch}_${character.id}';

//       ChatMessage message = ChatMessage(
//         id: messageId,
//         type: ChatMessage.TYPE_PRIVATE,
//         content: content,
//         sender: character.id,
//         receiver: receiverId,
//         role: character.name,
//         time: _getCurrentTime(),
//       );

//       // 保存到私聊会话
//       _addMessageToPrivateChat(message);

//       // 通知UI（先通知UI让消息立即显示）
//       onMessageReceived(message);

//       // 只发送到服务器，但不订阅自己的消息回传
//       stompClient.send(
//         destination: '/app/chat.sendPrivateMessage',
//         body: json.encode(message.toJson()),
//       );
//     } catch (e) {
//       print('发送私聊消息错误: $e');
//       if (onError != null) {
//         onError!('发送私聊消息错误: $e');
//       }
//     }
//   }

//   void requestOnlineUsers() {
//     try {
//       if (isConnected) {
//         print('请求在线用户列表...');
//         ChatMessage message = ChatMessage(
//           type: ChatMessage.TYPE_CHAT,
//           content: '',
//           sender: character.id,
//           role: character.name,
//           time: _getCurrentTime(),
//         );

//         // 确保用户订阅了正确的个人频道
//         stompClient.subscribe(
//           destination: '/user/${character.id}/topic/users',
//           callback: (StompFrame frame) {
//             if (frame.body != null) {
//               try {
//                 print('收到个人用户列表更新: ${frame.body}');
//                 Map<String, dynamic> result = json.decode(frame.body!);
//                 ChatMessage message = ChatMessage.fromJson(result);
//                 if (message.type == ChatMessage.TYPE_USERS) {
//                   _handleUsersList(message.content);
//                 }
//               } catch (e) {
//                 print('处理个人用户列表错误: $e');
//               }
//             }
//           },
//         );

//         stompClient.send(
//           destination: '/app/chat.getOnlineUsers',
//           body: json.encode(message.toJson()),
//         );
//       }
//     } catch (e) {
//       print('请求用户列表错误: $e');
//     }
//   }

//   String _getCurrentTime() {
//     // 返回完整的时间格式，包含年月日时分秒
//     return DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
//   }

//   // 获取历史聊天记录
//   Future<void> loadHistoricalMessages(String otherUserId) async {
//     if (!isConnected) {
//       if (onError != null) {
//         onError!('未连接到服务器，无法获取历史消息');
//       }
//       return;
//     }

//     try {
//       print('正在请求历史消息，用户ID: ${character.id} 和 $otherUserId');

//       // 构建API URL
//       final url =
//           '${AppConfig.httpUrl}/api/messages/private?userId1=${character.id}&userId2=$otherUserId';

//       print('请求URL: $url');

//       final response = await http.get(Uri.parse(url));
//       print('服务器响应状态码: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final responseBody = response.body;
//         print('响应数据: $responseBody');

//         if (responseBody.isEmpty) {
//           print('响应为空，没有历史消息');
//           return;
//         }

//         List<dynamic> messagesJson;
//         try {
//           messagesJson = jsonDecode(responseBody);
//         } catch (e) {
//           print('解析JSON失败: $e');
//           print('原始响应: $responseBody');
//           if (onError != null) {
//             onError!('解析历史消息失败: $e');
//           }
//           return;
//         }

//         if (messagesJson.isEmpty) {
//           print('没有历史消息');
//           return;
//         }

//         print('收到 ${messagesJson.length} 条历史消息');

//         List<ChatMessage> messages = [];
//         for (var json in messagesJson) {
//           try {
//             final message = ChatMessage.fromJson(json);
//             messages.add(message);
//             print('解析消息: ${message.content} 时间: ${message.time}');
//           } catch (e) {
//             print('解析消息失败: $e，原始数据: $json');
//           }
//         }

//         // 将历史消息添加到私聊
//         if (!privateChats.containsKey(otherUserId)) {
//           final user = onlineUsers.firstWhere(
//             (u) => u.id == otherUserId,
//             orElse:
//                 () => CharacterRole(
//                   id: otherUserId,
//                   name: otherUserId,
//                   description: '',
//                   imageAsset: '',
//                   color: Colors.grey,
//                 ),
//           );

//           privateChats[otherUserId] = PrivateChat(
//             userId: otherUserId,
//             userName: user.name,
//             userRole: user.name,
//           );
//         }

//         // 清除现有消息并添加历史消息
//         privateChats[otherUserId]!.messages.clear();

//         // 尝试按时间戳排序
//         try {
//           messages.sort((a, b) {
//             if (a.time.isEmpty || b.time.isEmpty) return 0;

//             // 检查时间格式
//             DateTime? timeA, timeB;
//             try {
//               timeA = DateFormat('yyyy-MM-dd HH:mm:ss').parse(a.time);
//             } catch (_) {
//               try {
//                 timeA = DateFormat('HH:mm:ss').parse(a.time);
//               } catch (_) {
//                 return 0;
//               }
//             }

//             try {
//               timeB = DateFormat('yyyy-MM-dd HH:mm:ss').parse(b.time);
//             } catch (_) {
//               try {
//                 timeB = DateFormat('HH:mm:ss').parse(b.time);
//               } catch (_) {
//                 return 0;
//               }
//             }

//             if (timeA == null || timeB == null) return 0;
//             return timeA.compareTo(timeB);
//           });
//         } catch (e) {
//           print('排序消息时出错: $e');
//         }

//         privateChats[otherUserId]!.messages.addAll(messages);

//         // 通知消息已加载
//         for (var message in messages) {
//           onMessageReceived(message);
//         }

//         print('已加载并显示 ${messages.length} 条历史消息');
//       } else {
//         print('获取历史消息失败: ${response.statusCode}, ${response.reasonPhrase}');
//         print('响应内容: ${response.body}');
//         if (onError != null) {
//           onError!('获取历史消息失败: HTTP ${response.statusCode}');
//         }
//       }
//     } catch (e) {
//       print('获取历史消息错误: $e');
//       if (onError != null) {
//         onError!('获取历史消息错误: $e');
//       }
//     }
//   }

//   // 添加心跳机制
//   void _startHeartbeat() {
//     // 停止可能存在的旧定时器
//     _stopHeartbeat();

//     // 创建新的定时器，每30秒发送一次心跳
//     _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
//       if (isConnected) {
//         try {
//           print('发送心跳...');
//           // 发送心跳消息
//           stompClient.send(
//             destination: '/app/chat.heartbeat',
//             body: json.encode({
//               'sender': character.id,
//               'type': 'HEARTBEAT',
//               'time': _getCurrentTime(),
//             }),
//           );
//         } catch (e) {
//           print('发送心跳错误: $e');
//           // 如果发送心跳失败，尝试重新连接
//           if (isConnected) {
//             isConnected = false;
//             // 尝试重新连接
//             Future.delayed(const Duration(seconds: 2), () {
//               if (!isConnected) {
//                 connect();
//               }
//             });
//           }
//         }
//       } else {
//         // 如果连接已断开，停止心跳
//         _stopHeartbeat();
//       }
//     });
//   }

//   // 停止心跳
//   void _stopHeartbeat() {
//     _heartbeatTimer?.cancel();
//     _heartbeatTimer = null;
//   }
// }
//////////////////////////////////////////////////////////////////
import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../config/app_config.dart';
import '../screen/role_selection_screen.dart';
import '../services/storage_service.dart';

// 私聊会话类
class PrivateChat {
  final String userId;
  final String userName;
  final String userRole;
  final List<ChatMessage> messages;
  int unreadCount; // 添加未读消息计数

  PrivateChat({
    required this.userId,
    required this.userName,
    required this.userRole,
    List<ChatMessage>? messages,
    this.unreadCount = 0,
  }) : messages = messages ?? [];

  // 添加未读消息
  void addUnreadMessage() {
    unreadCount++;
  }

  // 标记所有消息为已读
  void markAsRead() {
    unreadCount = 0;
  }

  // 获取最后一条消息
  ChatMessage? getLastMessage() {
    if (messages.isEmpty) return null;
    return messages.last;
  }
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

  // 存储会话ID
  String? sessionId;

  // 用于标记是否已从本地加载过数据
  bool _isDataLoaded = false;

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

    // 从本地存储加载聊天记录
    _loadChatsFromStorage();

    // 如果配置了直接使用SockJS，则直接使用SockJS连接
    if (AppConfig.enableSockJS) {
      _connectWithSockJS(cleanServerUrl);
    } else {
      _connectWithWebSocket(cleanServerUrl);
    }
  }

  // 从本地存储加载聊天记录
  Future<void> _loadChatsFromStorage() async {
    if (_isDataLoaded) return;

    try {
      Map<String, PrivateChat> loadedChats =
          await StorageService.loadPrivateChats(character.id);
      if (loadedChats.isNotEmpty) {
        print('从本地存储加载了 ${loadedChats.length} 个聊天会话');
        loadedChats.forEach((userId, chat) {
          if (!privateChats.containsKey(userId)) {
            privateChats[userId] = chat;
          }
        });
        _isDataLoaded = true;
      }
    } catch (e) {
      print('加载聊天记录时出错: $e');
    }
  }

  // 保存当前所有聊天记录到本地存储
  Future<void> saveChatsToStorage() async {
    try {
      if (privateChats.isNotEmpty) {
        bool result = await StorageService.savePrivateChats(
          character.id,
          privateChats,
        );
        if (result) {
          print('已将聊天记录保存到本地存储');
        } else {
          print('保存聊天记录失败');
        }
      }
    } catch (e) {
      print('保存聊天记录时出错: $e');
    }
  }

  // 使用标准WebSocket连接
  void _connectWithWebSocket(String serverUrl) {
    Map<String, String> connectHeaders = {'Origin': 'http://$serverUrl'};

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
        webSocketConnectHeaders: connectHeaders,
      ),
    );
  }

  // 使用SockJS连接
  void _connectWithSockJS(String serverUrl) {
    print('使用SockJS连接: http://$serverUrl/ws');

    Map<String, String> connectHeaders = {'Origin': 'http://$serverUrl'};

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
        webSocketConnectHeaders: connectHeaders,
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
        // 在断开连接前保存最新的聊天记录
        saveChatsToStorage();

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
      // 订阅错误消息
      stompClient.subscribe(
        destination: '/user/${character.id}/topic/errors',
        callback: (StompFrame frame) {
          if (frame.body != null) {
            print('收到错误消息: ${frame.body}');
            try {
              Map<String, dynamic> result = json.decode(frame.body!);
              if (onError != null) {
                onError!(result['content'] ?? '未知错误');
              }
            } catch (e) {
              print('解析错误消息失败: $e');
            }
          }
        },
      );

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

    // 如果消息不是自己发送的，增加未读消息计数
    if (message.sender != character.id) {
      privateChats[otherUserId]!.addUnreadMessage();
    }

    // 每当有新消息时，保存到本地存储
    saveChatsToStorage();
  }

  // 获取所有私聊会话，按最后消息时间排序
  List<PrivateChat> getRecentChats() {
    List<PrivateChat> chats = [];

    privateChats.forEach((userId, chat) {
      // 只添加有消息的会话
      if (chat.messages.isNotEmpty) {
        chats.add(chat);
      }
    });

    // 按最后一条消息的时间排序，最近的在前面
    chats.sort((a, b) {
      if (a.messages.isEmpty || b.messages.isEmpty) {
        return 0;
      }

      ChatMessage lastA = a.messages.last;
      ChatMessage lastB = b.messages.last;

      // 尝试从消息ID中提取时间戳
      if (lastA.id.isNotEmpty &&
          lastB.id.isNotEmpty &&
          lastA.id.contains('_') &&
          lastB.id.contains('_')) {
        try {
          int timeA = int.parse(lastA.id.split('_')[0]);
          int timeB = int.parse(lastB.id.split('_')[0]);
          return timeB.compareTo(timeA); // 降序排列
        } catch (e) {
          print('从ID解析时间戳失败: $e');
        }
      }

      // 如果ID解析失败，使用时间字符串排序
      if (lastA.time.isNotEmpty && lastB.time.isNotEmpty) {
        return lastB.time.compareTo(lastA.time);
      }

      return 0;
    });

    return chats;
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

          // 生成用户头像URL
          final String avatarUrl =
              "https://ui-avatars.com/api/?name=${roleName.substring(0, 1)}&background=${_getRoleColor(roleName).value.toRadixString(16).substring(2)}&color=fff";

          users.add(
            CharacterRole(
              id: userId,
              name: roleName,
              description: '', // 无描述
              imageAsset: '', // 无图片
              color: _getRoleColor(roleName),
              // avatarUrl: avatarUrl, // 设置头像URL
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

      // 添加发送者名字作为前缀
      String messageContent = '${character.name}: $content';

      ChatMessage message = ChatMessage(
        id: messageId,
        type: ChatMessage.TYPE_PRIVATE,
        content: messageContent,
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
    // 首先检查本地存储中是否已有该用户的聊天记录
    if (privateChats.containsKey(otherUserId) &&
        privateChats[otherUserId]!.messages.isNotEmpty) {
      print(
        '从本地加载与 $otherUserId 的聊天记录: ${privateChats[otherUserId]!.messages.length} 条消息',
      );
      // 如果本地已有记录，仍然尝试从服务器获取最新消息，但不需要等待
      _fetchMessagesFromServer(otherUserId);
      return;
    }

    if (!isConnected) return;

    await _fetchMessagesFromServer(otherUserId);
  }

  // 从服务器获取消息
  Future<void> _fetchMessagesFromServer(String otherUserId) async {
    try {
      // 构建API URL
      final url =
          '${AppConfig.httpUrl}/api/messages/private?userId1=${character.id}&userId2=$otherUserId';

      print('请求历史消息URL: $url');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> messagesJson = jsonDecode(response.body);
        print('收到历史消息原始数据: ${response.body}');
        print('历史消息JSON数量: ${messagesJson.length}');

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

        // 使用多个排序条件
        messages.sort((a, b) {
          // 首先尝试使用消息ID排序（如果ID是基于时间戳生成的）
          if (a.id.isNotEmpty &&
              b.id.isNotEmpty &&
              a.id.contains('_') &&
              b.id.contains('_')) {
            // 尝试从ID中提取时间戳部分
            try {
              int timeA = int.parse(a.id.split('_')[0]);
              int timeB = int.parse(b.id.split('_')[0]);
              return timeA.compareTo(timeB);
            } catch (e) {
              print('从ID解析时间戳失败: $e');
            }
          }

          // 如果ID解析失败，再使用时间字符串排序
          if (a.time.isNotEmpty && b.time.isNotEmpty) {
            return a.time.compareTo(b.time);
          }

          // 如果都失败，保持原始顺序
          return 0;
        });

        // 打印排序后的消息顺序
        print('排序后的消息顺序:');
        for (var msg in messages) {
          print(
            'ID: ${msg.id}, 时间: ${msg.time}, 内容: ${msg.content.substring(0, msg.content.length > 20 ? 20 : msg.content.length)}...',
          );
        }

        privateChats[otherUserId]!.messages.addAll(messages);

        // 通知消息已加载 - 修改为一次性批量通知UI更新
        print('批量通知UI更新 ${messages.length} 条历史消息');
        onMessageReceived(
          ChatMessage(
            type: ChatMessage.TYPE_PRIVATE,
            content: '已加载 ${messages.length} 条历史消息',
            sender: 'system',
            receiver: character.id,
            role: 'system',
            time: _getCurrentTime(),
          ),
        );

        print('已加载 ${messages.length} 条历史消息');

        // 保存加载的消息到本地存储
        saveChatsToStorage();
      } else {
        print('获取历史消息失败: ${response.statusCode}, 响应: ${response.body}');
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
