import 'package:Navi/api/getfriendlist.dart';
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
  List<dynamic> _friends = [];

  Future<void> _loadFriendList() async {
    GetFriendListService service = GetFriendListService();
    final username = await SharedPrefsUtils.getUsername();
    final friendList = await service.GetFriendList(username.toString());
    _friends = friendList['data'];
    print('好友列表: $_friends');
    print('好友列表长度:AAAAAAAAAAAAAAAAAAAAAAAAAA');
  }

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
    if (widget.initialChatCharacter != null) {
      _initializeWithCurrentUser();
    }
    _loadFriendList();
  }

  // 获取当前用户信息并初始化聊天
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

          if (_isConnected && mounted && widget.initialChatCharacter != null) {
            _selectCharacterToChat(widget.initialChatCharacter!);
          }
        }
      }
    } catch (e) {
      print('初始化当前用户出错: $e');
    }
  }

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

  void _handleCharacterSelected(CharacterRole character) {
    setState(() {
      _selectedCharacter = character;
      _isConnected = true; // 立即设置为连接状态
      _isConnecting = false;
    });
    _connectToChat();
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

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || _chatWithCharacter == null)
      return;

    final content = _messageController.text;
    _chatService.sendPrivateMessage(
      _chatWithCharacter['id'].toString(),
      content,
    );
    _messageController.clear();

    // 发送后自动滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _selectCharacterToChat(dynamic character) {
    setState(() {
      _chatWithCharacter = character;
      _isLoadingHistory = true;
    });
    print('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
    print('选择角色: ${character}');
    print('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');

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

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedCharacter == null) {
      return RoleSelectionScreen(onRoleSelected: _handleCharacterSelected);
    }
    return Scaffold(
      appBar: AppBar(
        title:
            _chatWithCharacter == null
                ? Text('聊天')
                : Text('与 ${_chatWithCharacter['nickname']} 聊天'),

        actions:
            _isConnected
                ? [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: _showServerSettings,
                    tooltip: '服务器设置',
                  ),
                  IconButton(
                    icon: const Icon(Icons.exit_to_app),
                    onPressed: () {
                      _chatService.disconnect();
                      setState(() {
                        _isConnected = false;
                        _errorMessage = "";
                        _chatWithCharacter = null;
                        _selectedCharacter = null;
                      });
                    },
                    tooltip: '退出聊天',
                  ),
                ]
                : [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: _showServerSettings,
                    tooltip: '服务器设置',
                  ),
                ],
      ),
      body:
          _chatWithCharacter == null
              ? _buildUserSelectionScreen()
              // : Text("data"),
              : _buildChatScreen(),
    );
  }

  Widget _buildUserSelectionScreen() {
    return _friends.isEmpty
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                '没有其他在线角色',
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _chatService.requestOnlineUsers(),
                child: const Text('刷新在线列表'),
              ),
            ],
          ),
        )
        : ListView.builder(
          itemCount: _friends.length,
          itemBuilder: (context, index) {
            final character = _friends[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  radius: 30,

                  child: Text(
                    character['nickname'].substring(0, 1),
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  character['nickname'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    character['bio'].isEmpty ? '点击开始私聊' : character['bio'],
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ),
                onTap: () => _selectCharacterToChat(character),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            );
          },
        );
  }

  Widget _buildChatScreen() {
    print(
      'chatWithCharacter: $_chatWithCharacter,aaaaaaaaaaaaaaaaaaaaaasssssssssssssssssss',
    );
    print('CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC');

    // 确保username是字符串类型
    String username = _chatWithCharacter['username'].toString();

    // 获取与当前选中角色的私聊消息
    final messages = _chatService.getPrivateChatMessages(username);

    // 打印消息列表用于调试
    print('准备显示消息列表，共 ${messages.length} 条消息');
    for (int i = 0; i < messages.length; i++) {
      final msg = messages[i];
      print(
        '消息[$i]: ID=${msg.id}, 时间=${msg.time}, 内容=${msg.content.length > 20 ? msg.content.substring(0, 20) : msg.content}...',
      );
    }

    return Column(
      children: [
        // 头部状态栏 - 显示当前聊天状态
        Container(
          padding: const EdgeInsets.all(8.0),
          color: Colors.grey.shade200,
          child: Row(
            children: [
              CircleAvatar(
                radius: 15,
                child: Text(
                  "REA",
                  // _chatWithCharacter['nickname'].substring(0, 1),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                // '与 ${_chatWithCharacter['nickname']} 的私聊',
                "REA",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              // 显示当前用户角色
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 4),
                    Text(
                      // _selectedCharacter['nickname'],
                      "REA",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child:
              _isLoadingHistory
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          // '正在加载与 ${_chatWithCharacter['nickname']} 的历史聊天记录...',
                          "REA",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                  : (messages.isEmpty
                      ? Center(
                        child: Text(
                          // '与 ${_chatWithCharacter['nickname']} 的聊天记录为空',
                          "REA",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                      : ListView.builder(
                        controller: _scrollController,
                        itemCount: messages.length,
                        padding: const EdgeInsets.all(8.0),
                        itemBuilder: (context, index) {
                          final message = messages[index];

                          // 忽略系统消息
                          if (message.sender == 'system') {
                            return const SizedBox.shrink();
                          }

                          return _buildMessageItem(message);
                        },
                      )),
        ),
        // 输入区域
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    // print("message: ${_selectedCharacter}");
    // print("message: ${_chatWithCharacter}");
    // print("VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV");
    final isMe = message.sender == _chatWithCharacter['username'];
    final bgColor = Colors.grey;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    if (message.type == ChatMessage.TYPE_JOIN ||
        message.type == ChatMessage.TYPE_LEAVE) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Center(
          child: Text(
            message.content,
            style: TextStyle(
              color:
                  message.type == ChatMessage.TYPE_JOIN
                      ? Colors.green
                      : Colors.red,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }
    // return Text("REA");
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isMe)
                Container(
                  margin: const EdgeInsets.only(right: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    // color: _chatWithCharacter!.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _chatWithCharacter['nickname'],
                    style: TextStyle(
                      fontSize: 10,
                      // color: _chatWithCharacter!.color,
                    ),
                  ),
                ),
              if (isMe)
                Container(
                  margin: const EdgeInsets.only(right: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    // color: _selectedCharacter!.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _chatWithCharacter['nickname'],
                    style: TextStyle(
                      fontSize: 10,
                      // color: _selectedCharacter!.color,
                    ),
                  ),
                ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 4.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: Colors.grey.shade300,
                // isMe
                //     ? _selectedCharacter!.color.withOpacity(0.3)
                //     : _chatWithCharacter!.color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message.content),
                const SizedBox(height: 4),
                Text(
                  message.time,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 2),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: '发送消息给 ${_chatWithCharacter['nickname']}...',
                border: const OutlineInputBorder(),
                // fillColor: _chatWithCharacter!.color.withOpacity(0.05),
                filled: true,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
            // color: _chatWithCharacter!.color,
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
                                    _connectToChat();
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
                    onPressed: _connectToChat,
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
}
