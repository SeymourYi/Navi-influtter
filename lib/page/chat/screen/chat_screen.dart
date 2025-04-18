import 'package:Navi/api/getfriendlist.dart';
import 'package:Navi/page/chat/screen/useseletscreen.dart';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import '../config/app_config.dart';
import 'role_selection_screen.dart';
import '../../../Store/storeutils.dart';
// import 'recent_chats_screen.dart';

class ChatScreen extends StatefulWidget {
  final dynamic initialChatCharacter; // 添加初始聊天角色参数

  const ChatScreen({super.key, this.initialChatCharacter});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  dynamic _selectedCharacter;
  dynamic _chatWithCharacter; // 当前选择聊天的角色
  late ChatService _chatService;
  bool _isConnected = false;
  bool _isConnecting = false;
  String _errorMessage = "";
  List<CharacterRole> _onlineCharacters = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingHistory = false;
  // List<dynamic> _friends = [];

  // Future<void> _loadFriendList() async {
  //   GetFriendListService service = GetFriendListService();
  //   final username = await SharedPrefsUtils.getUsername();
  //   final friendList = await service.GetFriendList(username.toString());
  //   _friends = friendList['data'];
  //   print('好友列表: $_friends');
  //   print('好友列表长度:AAAAAAAAAAAAAAAAAAAAAAAAAA');
  // }

  @override
  void dispose() {
    //TODO 确保在退出前保存聊天记录
    //     实现实时保存（每次聊天内容变更就保存）

    // 使用WidgetsBindingObserver监听应用生命周期，在didChangeAppLifecycleState中处理暂停/退出状态

    // 对于关键数据，考虑更可靠的持久化方案
    if (_isConnected && _selectedCharacter != null) {
      _chatService.saveChatsToStorage();
    }

    if (_isConnected) {
      _chatService.disconnect();
    }
    _messageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // 可以在这里添加定期保存的逻辑，例如每5分钟保存一次
    _setupAutoSaving();

    // 如果有初始聊天角色，自动加载当前用户信息并进入聊天
    // if (widget.initialChatCharacter != null) {
    // _initializeWithCurrentUser();
    // }
    // _loadFriendList();
  }

  // 获取当前用户信息并初始化聊天
  // Future<void> _initializeWithCurrentUser() async {
  //   try {
  //     // 从本地存储获取当前用户信息
  //     final userInfo = await SharedPrefsUtils.getUserInfo();
  //     if (userInfo != null) {
  //       // 创建当前用户的角色
  //       final currentUserRole = CharacterRole(
  //         id: userInfo['username'],
  //         name: userInfo['nickname'] ?? userInfo['username'] ?? '我自己',
  //         description: '以自己的身份进行聊天',
  //         imageAsset: userInfo['userPic'] ?? '',
  //         color: Colors.purple.shade700,
  //         isCustom: false,
  //       );

  //       if (mounted) {
  //         setState(() {
  //           _selectedCharacter = currentUserRole;
  //           _isConnected = true;
  //           _isConnecting = false;
  //         });

  //         // 连接到聊天服务
  //         _connectToChat();

  //         if (_isConnected && mounted && widget.initialChatCharacter != null) {
  //           _selectCharacterToChat(widget.initialChatCharacter!);
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     print('初始化当前用户出错: $e');
  //   }
  // }

  // 设置自动保存
  void _setupAutoSaving() {
    // 每5分钟自动保存一次聊天记录
    const duration = Duration(minutes: 5);
    Future.delayed(duration, () {
      if (mounted && _isConnected) {
        _chatService.saveChatsToStorage();
        _setupAutoSaving(); // 递归调用以实现定期执行
      }
    });
  }

  // void _handleCharacterSelected(CharacterRole character) {
  //   setState(() {
  //     _selectedCharacter = character;
  //     _isConnected = true; // 立即设置为连接状态
  //     _isConnecting = false;
  //   });
  //   _connectToChat();
  // }

  // void _connectToChat() {
  //   if (_selectedCharacter == null) return;

  //   // 在后台连接，不显示加载界面
  //   _chatService = ChatService(
  //     serverUrl: AppConfig.serverUrl,
  //     character: _selectedCharacter!,
  //     onMessageReceived: _handleMessageReceived,
  //     onUsersReceived: _handleUsersReceived,
  //     onError: (error) {
  //       setState(() {
  //         _errorMessage = error;
  //         _isConnected = false; // 连接失败时才更新连接状态
  //       });
  //     },
  //   );

  //   _chatService.connect();

  //   // 5秒后检查连接状态
  //   Future.delayed(const Duration(seconds: 5), () {
  //     if (mounted) {
  //       setState(() {
  //         _isConnected = _chatService.isConnected;
  //         if (!_isConnected && _errorMessage.isEmpty) {
  //           _errorMessage = "连接超时，请检查服务器地址和网络";
  //         } else if (_isConnected) {
  //           // 连接成功后，主动请求在线用户列表
  //           print('连接成功，请求在线用户列表');
  //           _chatService.requestOnlineUsers();
  //         }
  //       });
  //     }
  //   });
  // }

  // void _handleMessageReceived(ChatMessage message) {
  //   if (mounted) {
  //     setState(() {
  //       _isConnected = true;
  //       _isConnecting = false;
  //     });

  //     // 自动滚动到底部
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       _scrollToBottom();
  //     });
  //   }
  // }

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

  // void _sendMessage() {
  //   if (_messageController.text.trim().isEmpty || _chatWithCharacter == null)
  //     return;

  //   final content = _messageController.text;
  //   _chatService.sendPrivateMessage(
  //     _chatWithCharacter['id'].toString(),
  //     content,
  //   );
  //   _messageController.clear();

  //   // 发送后自动滚动到底部
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     _scrollToBottom();
  //   });
  // }

  // void _selectCharacterToChat(dynamic character) {
  //   setState(() {
  //     _chatWithCharacter = character;
  //     _isLoadingHistory = true;
  //   });
  //   print('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  //   print('选择角色: ${character}');
  //   print('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');

  //   // 确保username是字符串类型
  //   String username = character['username'].toString();

  //   // 标记与该用户的所有消息为已读
  //   if (_chatService.privateChats.containsKey(username)) {
  //     _chatService.privateChats[username]!.markAsRead();

  //     // 如果有本地消息，先显示本地消息，让用户可以立即看到
  //     if (_chatService.privateChats[username]!.messages.isNotEmpty) {
  //       setState(() {
  //         _isLoadingHistory = false;
  //       });
  //     }
  //   }

  //   _chatService
  //       .loadHistoricalMessages(username)
  //       .then((_) {
  //         if (mounted) {
  //           setState(() {
  //             _isLoadingHistory = false;
  //           });

  //           // 加载完成后再次确保标记为已读
  //           if (_chatService.privateChats.containsKey(username)) {
  //             _chatService.privateChats[username]!.markAsRead();
  //             // 保存已读状态到本地
  //             _chatService.saveChatsToStorage();
  //           }
  //         }
  //       })
  //       .catchError((error) {
  //         if (mounted) {
  //           // 如果加载失败，设置加载状态为false
  //           setState(() {
  //             _isLoadingHistory = false;
  //           });
  //         }
  //       });

  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     _scrollToBottom();
  //   });
  // }

  // void _scrollToBottom() {
  //   if (_scrollController.hasClients) {
  //     _scrollController.animateTo(
  //       _scrollController.position.maxScrollExtent,
  //       duration: const Duration(milliseconds: 300),
  //       curve: Curves.easeOut,
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // if (_selectedCharacter == null) {
    //   return RoleSelectionScreen(onRoleSelected: _handleCharacterSelected);
    // }
    return Scaffold(
      appBar: AppBar(
        title:
            _chatWithCharacter == null
                ? Text('聊天')
                : Text('与 ${_chatWithCharacter['nickname']} 聊天'),
        leading:
            _chatWithCharacter == null
                ? null
                : IconButton(
                  onPressed: () {
                    // Navigator.of(context).pop();
                    setState(() {
                      _chatWithCharacter = null;
                    });
                  },
                  icon: Icon(Icons.arrow_back_ios),
                ),
        automaticallyImplyLeading: _chatWithCharacter != null,
      ),
      body:
          _chatWithCharacter == null
              ? UseSelectScreen()
              // : Text("data"),
              : _buildChatScreen(),
    );
  }

  // Widget _buildUserSelectionScreen() {
  //   // 定义指定的主题色
  //   final Color redColor = Color(0xFFFB514F);
  //   final Color greenColor = Color(0xFF00C74E);
  //   final Color blueColor = Color(0xFF4288FC);

  //   return Column(
  //     children: [
  //       Expanded(
  //         child: ListView.builder(
  //           itemCount: _friends.length,
  //           physics: const BouncingScrollPhysics(),
  //           padding: const EdgeInsets.symmetric(vertical: 6),
  //           itemBuilder: (context, index) {
  //             final character = _friends[index];

  //             // 每个联系人使用不同颜色
  //             final List<Color> colorOptions = [
  //               redColor,
  //               greenColor,
  //               blueColor,
  //             ];
  //             final mainColor = colorOptions[index % colorOptions.length];

  //             return Container(
  //               margin: const EdgeInsets.symmetric(vertical: 1),
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 border: Border(
  //                   bottom: BorderSide(color: Colors.grey.shade100, width: 1),
  //                 ),
  //               ),
  //               child: Material(
  //                 color: Colors.transparent,
  //                 child: InkWell(
  //                   onTap: () => _selectCharacterToChat(character),
  //                   child: Padding(
  //                     padding: const EdgeInsets.symmetric(
  //                       horizontal: 18,
  //                       vertical: 15,
  //                     ),
  //                     child: Row(
  //                       children: [
  //                         // 简约头像
  //                         Container(
  //                           width: 46,
  //                           height: 46,
  //                           decoration: BoxDecoration(
  //                             border: Border.all(
  //                               color: mainColor.withOpacity(0.6),
  //                               width: 1.5,
  //                             ),
  //                             shape: BoxShape.circle,
  //                           ),
  //                           child: ClipOval(
  //                             child: Image.network(
  //                               character['userPic'],
  //                               fit: BoxFit.cover,
  //                               errorBuilder:
  //                                   (ctx, e, s) => CircleAvatar(
  //                                     backgroundColor: mainColor.withOpacity(
  //                                       0.15,
  //                                     ),
  //                                     child: Text(
  //                                       character['nickname']
  //                                           .substring(0, 1)
  //                                           .toUpperCase(),
  //                                       style: TextStyle(
  //                                         color: mainColor,
  //                                         fontWeight: FontWeight.bold,
  //                                       ),
  //                                     ),
  //                                   ),
  //                             ),
  //                           ),
  //                         ),

  //                         const SizedBox(width: 18),

  //                         // 简约信息
  //                         Expanded(
  //                           child: Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               Text(
  //                                 character['nickname'],
  //                                 style: const TextStyle(
  //                                   fontSize: 16,
  //                                   fontWeight: FontWeight.w500,
  //                                   color: Colors.black87,
  //                                 ),
  //                               ),
  //                               if (character['bio'].isNotEmpty)
  //                                 Padding(
  //                                   padding: const EdgeInsets.only(top: 4),
  //                                   child: Text(
  //                                     character['bio'],
  //                                     style: TextStyle(
  //                                       fontSize: 13,
  //                                       color: Colors.grey.shade600,
  //                                     ),
  //                                     maxLines: 1,
  //                                     overflow: TextOverflow.ellipsis,
  //                                   ),
  //                                 ),
  //                             ],
  //                           ),
  //                         ),

  //                         // 简约箭头
  //                         Icon(
  //                           Icons.chevron_right,
  //                           color: Colors.grey.shade300,
  //                           size: 22,
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             );
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildChatScreen() {
    // 确保username是字符串类型
    String username = _chatWithCharacter['username'].toString();

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
                        _chatWithCharacter['userPic'] != null
                            ? Image.network(
                              _chatWithCharacter['userPic'],
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (ctx, e, s) => CircleAvatar(
                                    backgroundColor: Color(
                                      0xFF4288FC,
                                    ).withOpacity(0.1),
                                    child: Text(
                                      _chatWithCharacter['nickname']
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
                                _chatWithCharacter['nickname']
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
                        _chatWithCharacter['nickname'],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      if (_chatWithCharacter['bio'] != null &&
                          _chatWithCharacter['bio'].isNotEmpty)
                        Text(
                          _chatWithCharacter['bio'],
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
                            '开始和${_chatWithCharacter['nickname']}聊天吧',
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
                            showDateHeader = _shouldShowTimeSeparator(
                              prevMsg,
                              message,
                            );
                          }
                        }

                        // return _buildMessageItem(message, showDateHeader);
                      },
                    ),
          ),

          // 输入区域
          _buildMessageInput(),
        ],
      ),
    );
  }

  // Widget _buildMessageItem(ChatMessage message, [bool showDateHeader = true]) {
  //   final isMe = message.sender != _chatWithCharacter['username'];
  //   final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

  //   // 为不同用户设置不同气泡颜色
  //   final myBubbleColor = Color(0xFF4288FC); // 蓝色
  //   final otherBubbleColor = Colors.white; // 白色

  //   // 系统消息处理
  //   if (message.type == ChatMessage.TYPE_JOIN ||
  //       message.type == ChatMessage.TYPE_LEAVE) {
  //     return Container(
  //       margin: const EdgeInsets.symmetric(vertical: 12.0),
  //       child: Center(
  //         child: Container(
  //           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  //           decoration: BoxDecoration(
  //             color: Colors.black.withOpacity(0.06),
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //           child: Text(
  //             message.content,
  //             style: TextStyle(
  //               color:
  //                   message.type == ChatMessage.TYPE_JOIN
  //                       ? Colors.green.shade700
  //                       : Colors.red.shade700,
  //               fontSize: 12,
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //         ),
  //       ),
  //     );
  //   }

  //   return Padding(
  //     padding: EdgeInsets.only(
  //       left: isMe ? 60 : 0,
  //       right: isMe ? 0 : 60,
  //       top: 8,
  //       bottom: 8,
  //     ),
  //     child: Column(
  //       crossAxisAlignment: align,
  //       children: [
  //         // 时间显示 - 只在需要的时候显示
  //         if (showDateHeader)
  //           Padding(
  //             padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
  //             child: Container(
  //               padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  //               decoration: BoxDecoration(
  //                 color: Colors.grey.shade200,
  //                 borderRadius: BorderRadius.circular(10),
  //               ),
  //               child: Text(
  //                 _formatMessageTime(message.time),
  //                 style: TextStyle(
  //                   fontSize: 11,
  //                   color: Colors.grey.shade700,
  //                   fontWeight: FontWeight.w400,
  //                 ),
  //               ),
  //             ),
  //           ),

  //         // 消息气泡
  //         Container(
  //           decoration: BoxDecoration(
  //             color: isMe ? myBubbleColor : otherBubbleColor,
  //             borderRadius: BorderRadius.circular(18.0),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.black.withOpacity(0.05),
  //                 blurRadius: 2,
  //                 offset: Offset(0, 1),
  //               ),
  //             ],
  //             border:
  //                 isMe
  //                     ? null
  //                     : Border.all(color: Colors.grey.shade200, width: 1),
  //           ),
  //           padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
  //           child: Text(
  //             message.content,
  //             style: TextStyle(
  //               color: isMe ? Colors.white : Colors.black87,
  //               fontSize: 15,
  //               height: 1.4,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // 格式化消息时间为更友好的显示
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
                // onPressed: _sendMessage,
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showServerSettings() {
    // 当前服务器配置
    final hostController = TextEditingController(text: AppConfig.serverHost);
    final portController = TextEditingController(
      text: AppConfig.serverPort.toString(),
    );
    bool useSockJS = AppConfig.enableSockJS;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('服务器设置'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: '服务器地址',
                    hintText: '例如：122.51.93.212 或 localhost',
                  ),
                  controller: hostController,
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: '端口号',
                    hintText: '例如：5487 或 8080',
                  ),
                  controller: portController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                StatefulBuilder(
                  builder:
                      (context, setState) => Row(
                        children: [
                          Checkbox(
                            value: useSockJS,
                            onChanged: (value) {
                              setState(() {
                                if (value != null) {
                                  useSockJS = value;
                                }
                              });
                            },
                          ),
                          const Text('使用SockJS (推荐)'),
                        ],
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '如果连接失败，请尝试切换SockJS选项',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    AppConfig.setServerConfig(
                      host: hostController.text,
                      port: int.tryParse(portController.text) ?? 8080,
                      useSockJS: useSockJS,
                    );
                    Navigator.of(context).pop();

                    // 如果已经连接，询问是否重新连接
                    if (_isConnected) {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('重新连接'),
                              content: const Text('是否使用新设置重新连接服务器？'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('取消'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _chatService.disconnect();
                                    setState(() {
                                      _isConnected = false;
                                      _errorMessage = "";
                                    });
                                    // _connectToChat();
                                  },
                                  child: const Text('重新连接'),
                                ),
                              ],
                            ),
                      );
                    }
                  },
                  child: const Text('保存设置'),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child:
          _isConnecting
              ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_errorMessage.isEmpty ? '连接中...' : _errorMessage),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Column(
                        children: [
                          const Text(
                            '连接提示：',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '1. 确保服务器地址正确，包含端口号\n'
                            '2. 如果使用手机，确保手机和服务器在同一网络\n'
                            '3. 检查服务器防火墙是否放行WebSocket端口\n'
                            '4. 如果使用公网服务器，确认端口已开放',
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                ],
              )
              : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage.isEmpty ? '连接失败' : _errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {},

                    // _connectToChat,
                    child: const Text('重新连接'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedCharacter = null;
                      });
                    },
                    child: const Text('返回角色选择'),
                  ),
                ],
              ),
    );
  }

  bool _shouldShowTimeSeparator(ChatMessage previous, ChatMessage current) {
    // 这里改为基于时间的比较或者索引的比较，而不是使用id

    // 1. 尝试比较日期部分是否不同（不同天显示分隔线）
    String prevDate =
        previous.time.split(' ')[0]; // 假设时间格式为 "yyyy-MM-dd HH:mm:ss"
    String currDate = current.time.split(' ')[0];

    if (prevDate != currDate) {
      return true; // 不同日期显示分隔线
    }

    // 2. 或者基于固定间隔显示时间
    // 如果消息id包含时间戳（格式如 "timestamp_xxx"）
    if (previous.id.contains('_') && current.id.contains('_')) {
      try {
        String prevTimePart = previous.id.split('_')[0];
        String currTimePart = current.id.split('_')[0];

        // 如果能解析为整数，则每隔一定时间显示分隔线
        int prevTime = int.parse(prevTimePart);
        int currTime = int.parse(currTimePart);

        // 如果两条消息相差超过5分钟，显示分隔线
        return (currTime - prevTime).abs() > 5 * 60 * 1000;
      } catch (e) {
        // 解析失败，回退到简单的消息索引方案
      }
    }

    return false; // 如果前面的条件都不满足，则不显示分隔线
  }
}
