import 'package:Navi/Store/storeutils.dart';
import 'package:Navi/page/chat/config/app_config.dart';
import 'package:Navi/page/chat/models/chat_message.dart';
import 'package:Navi/page/chat/screen/role_selection_screen.dart';
import 'package:flutter/material.dart';
import '../services/chat_service.dart';

class PrivtsChatScreen extends StatefulWidget {
  const PrivtsChatScreen({super.key, required this.character});
  final dynamic character;

  @override
  State<PrivtsChatScreen> createState() => _PrivtsChatScreenState();
}

class _PrivtsChatScreenState extends State<PrivtsChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isLoadingHistory = false;
  final ScrollController _scrollController = ScrollController();
  late ChatService _chatService;
  bool _isConnected = false;
  List<CharacterRole> _onlineCharacters = [];

  String _errorMessage = "";
  bool _isConnecting = false;
  dynamic _selectedCharacter;
  void _handleMessageReceived(ChatMessage message) {
    if (mounted) {
      setState(() {
        _isConnected = true;
        _isConnecting = false;
      });

      // 自动滚动到底部
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || widget.character == null)
      return;

    final content = _messageController.text;

    _chatService.sendPrivateMessage(
      widget.character['username'].toString(),
      content,
    );
    _messageController.clear();

    // 发送后自动滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _handleUsersReceived(List<CharacterRole> characters) {
    if (mounted) {
      print('收到在线用户列表: ${characters.length} 个用户');
      for (var char in characters) {
        print('在线用户: ${char.id} - ${char.name}');
      }

      setState(() {
        _onlineCharacters = characters;
      });
    }
  }

  void _connectToChat() {
    if (_selectedCharacter == null) return;

    // 在后台连接，不显示加载界面
    _chatService = ChatService(
      serverUrl: AppConfig.serverUrl,
      character: _selectedCharacter!,
      onMessageReceived: _handleMessageReceived,
      onUsersReceived: _handleUsersReceived,
      onError: (error) {
        setState(() {
          _errorMessage = error;
          _isConnected = false; // 连接失败时才更新连接状态
        });
      },
    );

    _chatService.connect();

    // 5秒后检查连接状态
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isConnected = _chatService.isConnected;
          if (!_isConnected && _errorMessage.isEmpty) {
            _errorMessage = "连接超时，请检查服务器地址和网络";
          } else if (_isConnected) {
            // 连接成功后，主动请求在线用户列表
            print('连接成功，请求在线用户列表');
            _chatService.requestOnlineUsers();
          }
        });
      }
    });
  }

  Future<void> _initializeWithCurrentUser() async {
    try {
      // 从本地存储获取当前用户信息
      final userInfo = await SharedPrefsUtils.getUserInfo();
      if (userInfo != null) {
        // 创建当前用户的角色
        final currentUserRole = CharacterRole(
          id: userInfo['username'],
          name: userInfo['nickname'] ?? userInfo['username'] ?? '我自己',
          description: '以自己的身份进行聊天',
          imageAsset: userInfo['userPic'] ?? '',
          color: Colors.purple.shade700,
          isCustom: false,
        );

        if (mounted) {
          setState(() {
            _selectedCharacter = currentUserRole;
            _isConnected = true;
            _isConnecting = false;
          });

          // 连接到聊天服务
          _connectToChat();

          if (_isConnected && mounted && widget.character != null) {
            _selectCharacterToChat(widget.character!);
          }
        }
      }
    } catch (e) {
      print('初始化当前用户出错: $e');
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _selectCharacterToChat(dynamic character) {
    setState(() {
      _isLoadingHistory = true;
    });
    // 确保username是字符串类型
    String username = character['username'].toString();

    // 标记与该用户的所有消息为已读
    if (_chatService.privateChats.containsKey(username)) {
      _chatService.privateChats[username]!.markAsRead();

      // 如果有本地消息，先显示本地消息，让用户可以立即看到
      if (_chatService.privateChats[username]!.messages.isNotEmpty) {
        setState(() {
          _isLoadingHistory = false;
        });
      }
    }

    _chatService
        .loadHistoricalMessages(username)
        .then((_) {
          if (mounted) {
            setState(() {
              _isLoadingHistory = false;
            });

            // 加载完成后再次确保标记为已读
            if (_chatService.privateChats.containsKey(username)) {
              _chatService.privateChats[username]!.markAsRead();
              // 保存已读状态到本地
              _chatService.saveChatsToStorage();
            }
          }
        })
        .catchError((error) {
          if (mounted) {
            // 如果加载失败，设置加载状态为false
            setState(() {
              _isLoadingHistory = false;
            });
          }
        });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void initState() {
    super.initState();
    print(widget.character);
    if (widget.character != null) {
      _initializeWithCurrentUser();
    }
    // _selectCharacterToChat(widget.character);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('私聊')),
      body: Center(child: _buildChatScreen()),
    );
  }

  Widget _buildChatScreen() {
    // 确保username是字符串类型
    String username = widget.character['username'].toString();

    // 获取与当前选中角色的私聊消息
    final messages = _chatService.getPrivateChatMessages(username);

    return Container(
      color: Color(0xFFF8F9FA), // 更柔和的背景色
      child: Column(
        children: [
          // 简洁的头部状态
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  offset: Offset(0, 1),
                  blurRadius: 3,
                ),
              ],
            ),
            child: Row(
              children: [
                // 用户头像
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color(0xFF4288FC).withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child:
                        widget.character['userPic'] != null
                            ? Image.network(
                              widget.character['userPic'],
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (ctx, e, s) => CircleAvatar(
                                    backgroundColor: Color(
                                      0xFF4288FC,
                                    ).withOpacity(0.1),
                                    child: Text(
                                      widget.character['nickname']
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: TextStyle(
                                        color: Color(0xFF4288FC),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                            )
                            : CircleAvatar(
                              backgroundColor: Color(
                                0xFF4288FC,
                              ).withOpacity(0.1),
                              child: Text(
                                widget.character['nickname']
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: TextStyle(
                                  color: Color(0xFF4288FC),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                  ),
                ),
                SizedBox(width: 12),
                // 用户信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.character['nickname'],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      if (widget.character['bio'] != null &&
                          widget.character['bio'].isNotEmpty)
                        Text(
                          widget.character['bio'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 聊天内容区域
          Expanded(
            child:
                _isLoadingHistory
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF4288FC),
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            '正在加载聊天记录...',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                    : messages.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_outlined,
                            size: 56,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 16),
                          Text(
                            '开始和${widget.character['nickname']}聊天吧',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      controller: _scrollController,
                      itemCount: messages.length,
                      padding: const EdgeInsets.all(16.0),
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final message = messages[index];

                        // 忽略系统消息
                        if (message.sender == 'system') {
                          return const SizedBox.shrink();
                        }

                        // 确定是否需要显示时间分隔线
                        bool showDateHeader = false;
                        if (index == 0) {
                          // 第一条消息总是显示时间
                          showDateHeader = true;
                        } else if (index > 0) {
                          // 根据消息间隔时间决定是否显示分隔线
                          final prevMsg = messages[index - 1];
                          if (prevMsg.sender == 'system') {
                            showDateHeader = true;
                          } else {
                            // 检查日期是否不同或时间间隔大
                            // showDateHeader = _shouldShowTimeSeparator(
                            //   prevMsg,
                            //   message,
                            // );
                          }
                        }

                        return _buildMessageItem(message, showDateHeader);
                      },
                    ),
          ),

          // 输入区域_buildMessageInput
          _buildMessageInput(),
        ],
      ),
    );
  }

  String _formatMessageTime(String timeStr) {
    try {
      // 假设时间格式为 "yyyy-MM-dd HH:mm:ss"
      DateTime msgTime = DateTime.parse(timeStr.replaceAll(' ', 'T'));
      DateTime now = DateTime.now();

      // 今天的消息只显示时间
      if (msgTime.year == now.year &&
          msgTime.month == now.month &&
          msgTime.day == now.day) {
        return "今天 ${msgTime.hour.toString().padLeft(2, '0')}:${msgTime.minute.toString().padLeft(2, '0')}";
      }

      // 昨天的消息
      DateTime yesterday = now.subtract(Duration(days: 1));
      if (msgTime.year == yesterday.year &&
          msgTime.month == yesterday.month &&
          msgTime.day == yesterday.day) {
        return "昨天 ${msgTime.hour.toString().padLeft(2, '0')}:${msgTime.minute.toString().padLeft(2, '0')}";
      }

      // 本周内的消息
      if (now.difference(msgTime).inDays < 7) {
        List<String> weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
        int weekday = msgTime.weekday - 1; // 0-6, 周一到周日
        return "${weekdays[weekday]} ${msgTime.hour.toString().padLeft(2, '0')}:${msgTime.minute.toString().padLeft(2, '0')}";
      }

      // 更早的消息
      return "${msgTime.year}-${msgTime.month.toString().padLeft(2, '0')}-${msgTime.day.toString().padLeft(2, '0')} ${msgTime.hour.toString().padLeft(2, '0')}:${msgTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      // 如果解析失败，返回原始字符串
      return timeStr;
    }
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Row(
        children: [
          // 设计更现代的输入框
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: '发送消息...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
                textAlignVertical: TextAlignVertical.center,
                maxLines: null,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),

          // 发送按钮
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: Color(0xFF4288FC),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_upward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _sendMessage,
                // onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message, [bool showDateHeader = true]) {
    final isMe = message.sender != widget.character['username'];
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    // 为不同用户设置不同气泡颜色
    final myBubbleColor = Color(0xFF4288FC); // 蓝色
    final otherBubbleColor = Colors.white; // 白色

    // 系统消息处理
    if (message.type == ChatMessage.TYPE_JOIN ||
        message.type == ChatMessage.TYPE_LEAVE) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 12.0),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message.content,
              style: TextStyle(
                color:
                    message.type == ChatMessage.TYPE_JOIN
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        left: isMe ? 60 : 0,
        right: isMe ? 0 : 60,
        top: 8,
        bottom: 8,
      ),
      child: Column(
        crossAxisAlignment: align,
        children: [
          // 时间显示 - 只在需要的时候显示
          if (showDateHeader)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _formatMessageTime(message.time),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),

          // 消息气泡
          Container(
            decoration: BoxDecoration(
              color: isMe ? myBubbleColor : otherBubbleColor,
              borderRadius: BorderRadius.circular(18.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
              border:
                  isMe
                      ? null
                      : Border.all(color: Colors.grey.shade200, width: 1),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
