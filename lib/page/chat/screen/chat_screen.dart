import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import '../config/app_config.dart';
import 'role_selection_screen.dart';
import '../../../api/getfriendlist.dart';
import '../../../Store/storeutils.dart';
import 'dart:async';
import 'package:intl/intl.dart';

// Friend类定义
class Friend {
  final String name;
  final String username;
  final String avatarUrl;
  final String? bio;

  Friend({
    required this.name,
    required this.username,
    required this.avatarUrl,
    this.bio,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      name: json['nickname'] ?? '',
      username: json['username'] ?? '',
      avatarUrl: json['userPic'] ?? 'https://via.placeholder.com/150',
      bio: json['bio'] ?? '',
    );
  }
}

class ChatScreen extends StatefulWidget {
  // 添加初始聊天用户参数
  final String? initialChatUsername;
  final String? initialChatName;
  final String? initialChatAvatar;
  final String? initialChatBio;

  const ChatScreen({
    super.key,
    this.initialChatUsername,
    this.initialChatName,
    this.initialChatAvatar,
    this.initialChatBio,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // 保持页面状态

  final TextEditingController _messageController = TextEditingController();
  CharacterRole? _selectedCharacter;
  CharacterRole? _chatWithCharacter; // 当前选择聊天的角色
  late ChatService _chatService;
  bool _isConnected = false;
  bool _isConnecting = false;
  String _errorMessage = "";
  List<CharacterRole> _onlineCharacters = [];
  List<Friend> _friends = [];
  bool _isLoadingFriends = true;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMessages = true;
  bool _hasInitialChat = false; // 标记是否有初始聊天对象

  // 添加连接状态检查定时器
  Timer? _connectionCheckTimer;

  // 在类开头添加静态缓存变量
  static List<Friend>? _cachedFriendList;
  static DateTime? _lastFriendListFetchTime;
  static const Duration _friendListCacheValidity = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();

    // 检查是否有初始聊天对象
    _hasInitialChat =
        widget.initialChatUsername != null && widget.initialChatName != null;

    // 如果是从用户主页跳转过来的直接聊天
    if (_hasInitialChat) {
      // 显示连接中状态
      setState(() {
        _isConnecting = true;
        _errorMessage = "正在连接到聊天服务器...";
      });

      // 显示提示信息
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('正在建立聊天连接，请稍候...'),
            duration: Duration(seconds: 2),
          ),
        );
      });

      // 如果是直接聊天，立即触发角色选择和连接流程
      _preloadUserRoleAndConnect();
    }

    _loadFriends();
  }

  Future<void> _loadFriends() async {
    // 检查是否有有效缓存
    final bool hasCachedFriends =
        _cachedFriendList != null &&
        _lastFriendListFetchTime != null &&
        DateTime.now().difference(_lastFriendListFetchTime!) <
            _friendListCacheValidity;

    if (hasCachedFriends) {
      // 使用缓存数据
      print('使用缓存的好友列表数据');
      setState(() {
        _friends = _cachedFriendList!;
        _isLoadingFriends = false;
      });
      return;
    }

    try {
      setState(() {
        _isLoadingFriends = true;
      });

      GetFriendListService service = GetFriendListService();
      var username = await SharedPrefsUtils.getUsername();
      var result = await service.GetFriendList(username.toString());

      if (result['code'] == 0 && result['data'] is List) {
        final friendList =
            (result['data'] as List)
                .map((item) => Friend.fromJson(item))
                .toList();

        // 更新缓存
        _cachedFriendList = friendList;
        _lastFriendListFetchTime = DateTime.now();

        setState(() {
          _friends = friendList;
          _isLoadingFriends = false;
        });
      }
    } catch (e) {
      print('加载好友列表失败: $e');
      setState(() {
        _isLoadingFriends = false;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _stopConnectionCheck();
    _ensureDisconnect();
    super.dispose();
  }

  // 启动连接状态检查
  void _startConnectionCheck() {
    // 停止可能存在的旧定时器
    _stopConnectionCheck();

    // 每45秒检查一次连接状态
    _connectionCheckTimer = Timer.periodic(const Duration(seconds: 45), (
      timer,
    ) {
      if (_selectedCharacter != null) {
        // 检查服务实例是否已经初始化
        if (_chatService != null) {
          if (!_chatService.isConnected && _isConnected) {
            print('检测到连接已断开，尝试重新连接...');
            setState(() {
              _isConnected = false;
              _errorMessage = "连接已断开，正在尝试重新连接...";
            });
            // 重新连接
            _connectToChat();
          }
        }
      } else {
        // 如果没有选择角色，停止检查
        _stopConnectionCheck();
      }
    });
  }

  // 停止连接状态检查
  void _stopConnectionCheck() {
    _connectionCheckTimer?.cancel();
    _connectionCheckTimer = null;
  }

  void _ensureDisconnect() {
    if (_isConnected) {
      _chatService.disconnect();
    }
  }

  void _handleCharacterSelected(CharacterRole character) {
    setState(() {
      _selectedCharacter = character;
      _isConnected = true; // 立即设置为连接状态
      _isConnecting = false;
    });
    _connectToChat();
    // 启动连接检查
    _startConnectionCheck();
  }

  void _connectToChat() {
    if (_selectedCharacter == null) return;

    setState(() {
      _isConnecting = true;
      _errorMessage = "";
    });

    _chatService = ChatService(
      serverUrl: AppConfig.serverUrl,
      character: _selectedCharacter!,
      onMessageReceived: _handleMessageReceived,
      onUsersReceived: _handleUsersReceived,
      onError: (error) {
        setState(() {
          _errorMessage = error;
          _isConnected = false; // 连接失败时才更新连接状态
          _isConnecting = false;
        });
      },
    );

    _chatService.connect();

    // 缩短连接状态检查时间（原来是5秒）
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isConnected = _chatService.isConnected;
          _isConnecting = false;
          if (!_isConnected && _errorMessage.isEmpty) {
            _errorMessage = "连接超时，请检查服务器地址和网络";
          } else if (_isConnected) {
            // 连接成功后，主动请求在线用户列表
            print('连接成功，请求在线用户列表');
            _chatService.requestOnlineUsers();

            // 连接成功后，如果有初始聊天对象，立即初始化聊天（无需等待）
            if (_hasInitialChat && widget.initialChatUsername != null) {
              _initializeDirectChat();
            }
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
    // 无论是否在线都发送消息
    _chatService.sendPrivateMessage(_chatWithCharacter!.id, content);
    _messageController.clear();

    // 发送后自动滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _selectCharacterToChat(CharacterRole character) {
    setState(() {
      _chatWithCharacter = character;
      // 打开加载中状态
      _isLoadingMessages = true;
    });

    print('选择聊天对象: ${character.id} - ${character.name}');

    // 确保连接已建立
    if (!_chatService.isConnected) {
      print('连接尚未建立，等待连接...');
      // 减少等待时间（从3秒减到1秒）
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          if (_chatService.isConnected) {
            print('连接已建立，加载历史消息');
            _loadChatMessages(character.id);
          } else {
            setState(() {
              _isLoadingMessages = false;
              _errorMessage = "连接未建立，无法加载历史消息";
            });
            print('连接仍未建立，无法加载历史消息');
          }
        }
      });
    } else {
      // 连接已建立，直接加载消息
      _loadChatMessages(character.id);
    }
  }

  // 提取加载消息的逻辑为单独的方法，便于重试
  void _loadChatMessages(String userId) {
    print('开始加载与 $userId 的历史消息');

    // 如果已经有消息了，先显示缓存的消息
    final List<ChatMessage> cachedMessages = _chatService
        .getPrivateChatMessages(userId);
    if (cachedMessages.isNotEmpty) {
      print('显示缓存的历史消息 (${cachedMessages.length} 条)');
      setState(() {
        _isLoadingMessages = false;
      });

      // 滚动到消息列表底部
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });

      // 后台继续加载更多消息
      _loadMoreMessages(userId);
      return;
    }

    // 加载历史消息
    _chatService
        .loadHistoricalMessages(userId)
        .then((_) {
          if (mounted) {
            setState(() {
              // 关闭加载中状态
              _isLoadingMessages = false;
            });
            print('历史消息加载成功');
            // 滚动到消息列表底部
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToBottom();
            });
          }
        })
        .catchError((error) {
          print('加载历史消息失败: $error');
          if (mounted) {
            setState(() {
              _isLoadingMessages = false;
              _errorMessage = "加载历史消息失败: $error";
            });

            // 添加一个按钮，允许用户点击重试
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('加载历史消息失败'),
                action: SnackBarAction(
                  label: '重试',
                  onPressed: () {
                    setState(() {
                      _isLoadingMessages = true;
                      _errorMessage = "";
                    });
                    _loadChatMessages(userId);
                  },
                ),
              ),
            );
          }
        });
  }

  // 后台加载更多消息
  void _loadMoreMessages(String userId) {
    print('后台加载更多消息...');
    _chatService.loadHistoricalMessages(userId).catchError((error) {
      print('后台加载更多消息失败: $error');
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
    super.build(context); // 必须调用super.build

    if (_selectedCharacter == null) {
      return RoleSelectionScreen(onRoleSelected: _handleCharacterSelected);
    }

    return Scaffold(
      appBar: AppBar(
        title:
            _chatWithCharacter == null
                ? Text('${_selectedCharacter!.name}的聊天')
                : Text('与 ${_chatWithCharacter!.name} 聊天'),
        backgroundColor: _selectedCharacter!.color,
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
                      _ensureDisconnect();
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
          _isConnected
              ? (_chatWithCharacter == null
                  ? _buildUserSelectionScreen()
                  : _buildChatScreen())
              : _buildLoadingScreen(),
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
                                    _ensureDisconnect();
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
                          if (_hasInitialChat) // 如果是私聊模式，添加直接返回按钮
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('返回上一页'),
                            ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _connectToChat,
                        child: const Text('重新连接'),
                      ),
                      const SizedBox(width: 16),
                      if (_hasInitialChat) // 如果是私聊模式，添加直接返回按钮
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('返回上一页'),
                        ),
                    ],
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

  Widget _buildUserSelectionScreen() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '选择一个好友开始聊天',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _selectedCharacter!.color,
            ),
          ),
        ),
        if (_isLoadingFriends)
          const Center(child: CircularProgressIndicator())
        else if (_friends.isEmpty)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  '你还没有关注任何人',
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
              ],
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: _friends.length,
              itemBuilder: (context, index) {
                final friend = _friends[index];
                final isOnline = _onlineCharacters.any(
                  (char) => char.id == friend.username,
                );

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(friend.avatarUrl),
                        ),
                        if (isOnline)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Row(
                      children: [
                        Text(
                          friend.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isOnline)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '在线',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '离线',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          friend.bio ?? '点击开始聊天',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      // 创建一个CharacterRole对象用于聊天
                      final chatRole = CharacterRole(
                        id: friend.username,
                        name: friend.name,
                        description: friend.bio ?? '',
                        imageAsset: friend.avatarUrl,
                        color: isOnline ? Colors.green : Colors.grey,
                      );
                      _selectCharacterToChat(chatRole);
                    },
                  ),
                );
              },
            ),
          ),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '提示：离线好友将在上线后收到消息',
            style: TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildChatScreen() {
    // 获取与当前选中角色的私聊消息
    final messages = _chatService.getPrivateChatMessages(
      _chatWithCharacter!.id,
    );

    return Column(
      children: [
        // 头部状态栏 - 显示当前聊天状态
        Container(
          padding: const EdgeInsets.all(8.0),
          color: Colors.grey.shade200,
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: _chatWithCharacter!.color.withOpacity(0.3),
                radius: 15,
                child: Text(
                  _chatWithCharacter!.name.substring(0, 1),
                  style: TextStyle(
                    color: _chatWithCharacter!.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '与 ${_chatWithCharacter!.name} 的私聊',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              // 显示当前用户角色
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _selectedCharacter!.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedCharacter!.color,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 4),
                    Text(
                      _selectedCharacter!.name,
                      style: TextStyle(
                        color: _selectedCharacter!.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.people_outline, size: 20),
                onPressed: () {
                  setState(() {
                    _chatWithCharacter = null;
                  });
                },
                tooltip: '返回用户列表',
              ),
            ],
          ),
        ),

        // 消息区域
        Expanded(
          child:
              messages.isEmpty || _isLoadingMessages
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isLoadingMessages)
                          Column(
                            children: [
                              const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '正在加载聊天记录...',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          )
                        else
                          Text(
                            '与 ${_chatWithCharacter!.name} 的聊天记录为空',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        const SizedBox(height: 8),
                        if (_errorMessage.isNotEmpty)
                          Text(
                            _errorMessage,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    padding: const EdgeInsets.all(8.0),
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return _buildMessageItem(message);
                    },
                  ),
        ),

        // 输入区域
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    final isMe = message.sender == _selectedCharacter!.id;
    final bgColor =
        isMe
            ? _selectedCharacter!.color.withOpacity(0.1)
            : Colors.grey.shade200;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    if (message.type == ChatMessage.TYPE_JOIN ||
        message.type == ChatMessage.TYPE_LEAVE) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0), // 减小间距
        child: Center(
          child: Text(
            message.content,
            style: TextStyle(
              color:
                  message.type == ChatMessage.TYPE_JOIN
                      ? Colors.green
                      : Colors.red,
              fontStyle: FontStyle.italic,
              fontSize: 12, // 减小字体
            ),
          ),
        ),
      );
    }

    // 格式化时间显示 - 提前计算一次，避免重复计算
    String formattedTime = message.time;
    try {
      if (message.time.length > 8) {
        // 判断是否是完整时间戳
        final dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(message.time);
        formattedTime = DateFormat('MM-dd HH:mm').format(dateTime);
      }
    } catch (e) {
      // 格式解析失败，使用原始时间
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0), // 减小间距
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
                    color: _chatWithCharacter!.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _chatWithCharacter!.name,
                    style: TextStyle(
                      fontSize: 10,
                      color: _chatWithCharacter!.color,
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
                    color: _selectedCharacter!.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _selectedCharacter!.name,
                    style: TextStyle(
                      fontSize: 10,
                      color: _selectedCharacter!.color,
                    ),
                  ),
                ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 2.0), // 减小间距
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 12.0,
            ), // 减小内边距
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color:
                    isMe
                        ? _selectedCharacter!.color.withOpacity(0.3)
                        : _chatWithCharacter!.color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message.content),
                const SizedBox(height: 2), // 减小间距
                Text(
                  formattedTime,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.grey,
                  ), // 减小字体
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    final isOnline = _onlineCharacters.any(
      (char) => char.id == _chatWithCharacter!.id,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 4.0,
      ), // 减小内边距
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 1,
          ), // 减少阴影效果
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 确保只占用最小空间
        children: [
          if (!isOnline)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 2), // 减小内边距
              width: double.infinity,
              color: Colors.grey.shade100,
              child: Text(
                '对方当前离线，消息将在对方上线后收到',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 10,
                ), // 减小字体
                textAlign: TextAlign.center,
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: '发送消息给 ${_chatWithCharacter!.name}...',
                    hintStyle: TextStyle(fontSize: 14), // 减小字体
                    border: const OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ), // 减小内边距
                    fillColor: _chatWithCharacter!.color.withOpacity(0.05),
                    filled: true,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                  textInputAction: TextInputAction.send, // 设置键盘发送按钮
                  keyboardType: TextInputType.text, // 使用标准文本键盘
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
                color: _chatWithCharacter!.color,
                iconSize: 22, // 稍微减小图标尺寸
                padding: EdgeInsets.zero, // 减少内边距
                constraints: BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ), // 设置较小的约束
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 添加初始化直接聊天的方法
  void _initializeDirectChat() {
    if (!_hasInitialChat) return;

    print('初始化直接聊天，用户名: ${widget.initialChatUsername}');

    // 创建一个CharacterRole对象用于聊天
    final chatRole = CharacterRole(
      id: widget.initialChatUsername!,
      name: widget.initialChatName!,
      description: widget.initialChatBio ?? '',
      imageAsset: widget.initialChatAvatar ?? '',
      color: Colors.blue, // 默认颜色
    );

    // 立即初始化聊天，不再使用延迟
    _selectCharacterToChat(chatRole);
    _hasInitialChat = false; // 重置标记，防止多次触发
  }

  // 添加预加载用户角色并连接的方法
  Future<void> _preloadUserRoleAndConnect() async {
    try {
      final userInfo = await SharedPrefsUtils.getUserInfo();
      if (userInfo != null && mounted) {
        // 创建角色并直接触发连接
        final userRole = CharacterRole(
          id: userInfo['username'],
          name: userInfo['nickname'] ?? userInfo['username'] ?? '我自己',
          description: '以自己的身份进行聊天',
          imageAsset: userInfo['userPic'] ?? '',
          color: Colors.purple.shade700,
        );

        // 直接选择角色，跳过角色选择界面
        _handleCharacterSelected(userRole);
      }
    } catch (e) {
      print('预加载用户角色失败: $e');
    }
  }
}
