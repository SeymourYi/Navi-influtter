import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import '../config/app_config.dart';
import 'role_selection_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  CharacterRole? _selectedCharacter;
  CharacterRole? _chatWithCharacter; // 当前选择聊天的角色
  late ChatService _chatService;
  bool _isConnected = false;
  bool _isConnecting = false;
  String _errorMessage = "";
  List<CharacterRole> _onlineCharacters = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    if (_isConnected) {
      _chatService.disconnect();
    }
    _messageController.dispose();
    super.dispose();
  }

  void _handleCharacterSelected(CharacterRole character) {
    setState(() {
      _selectedCharacter = character;
    });
    _connectToChat();
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
          _isConnecting = false;
        });
      },
    );

    _chatService.connect();

    // 5秒后检查连接状态
    Future.delayed(const Duration(seconds: 5), () {
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
    });

    // 滚动到消息列表底部
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
        title: Text('${_selectedCharacter!.name}的聊天'),
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
      body: _isConnected ? _buildChatScreen() : _buildLoadingScreen(),
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

  Widget _buildChatScreen() {
    return Row(
      children: [
        // 聊天区域
        Expanded(
          flex: 3,
          child: Column(
            children: [
              // 顶部状态栏 - 显示当前聊天状态
              Container(
                padding: const EdgeInsets.all(8.0),
                color: Colors.grey.shade200,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          _chatWithCharacter?.color.withOpacity(0.3) ??
                          Colors.grey,
                      radius: 15,
                      child: Text(
                        _chatWithCharacter?.name.substring(0, 1) ?? '?',
                        style: TextStyle(
                          color: _chatWithCharacter?.color ?? Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _chatWithCharacter == null
                          ? '选择一个角色开始私聊'
                          : '与 ${_chatWithCharacter!.name} 的私聊',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    // 显示当前用户角色
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
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
                  ],
                ),
              ),

              // 消息区域
              Expanded(child: _buildMessageList()),

              // 输入区域
              _chatWithCharacter == null
                  ? _buildSelectCharacterPrompt()
                  : _buildMessageInput(),
            ],
          ),
        ),

        // 在线角色列表
        SizedBox(width: 200, child: _buildOnlineCharactersList()),
      ],
    );
  }

  Widget _buildSelectCharacterPrompt() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: const Text(
        '请从右侧列表选择一个角色开始私聊',
        style: TextStyle(fontSize: 16, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMessageList() {
    if (_chatWithCharacter == null) {
      return const Center(child: Text('选择一个角色开始聊天'));
    }

    // 获取与当前选中角色的私聊消息
    final messages = _chatService.getPrivateChatMessages(
      _chatWithCharacter!.id,
    );

    return messages.isEmpty
        ? Center(
          child: Text(
            '与 ${_chatWithCharacter!.name} 的聊天记录为空',
            style: const TextStyle(color: Colors.grey),
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
        );
  }

  Widget _buildOnlineCharactersList() {
    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            color: _selectedCharacter?.color ?? Colors.blue,
            width: double.infinity,
            child: const Text(
              '在线角色',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child:
                _onlineCharacters.isEmpty
                    ? const Center(child: Text('没有其他在线角色'))
                    : ListView.builder(
                      itemCount: _onlineCharacters.length,
                      itemBuilder: (context, index) {
                        final character = _onlineCharacters[index];
                        final isSelected =
                            character.id == _chatWithCharacter?.id;

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: character.color.withOpacity(0.3),
                            child: Text(
                              character.name.substring(0, 1),
                              style: TextStyle(
                                color: character.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            character.name,
                            style: TextStyle(
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                              color: isSelected ? character.color : null,
                            ),
                          ),
                          subtitle: Text(
                            character.description.isEmpty
                                ? '点击开始私聊'
                                : character.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          onTap: () => _selectCharacterToChat(character),
                          tileColor:
                              isSelected
                                  ? character.color.withOpacity(0.1)
                                  : null,
                        );
                      },
                    ),
          ),
        ],
      ),
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
            margin: const EdgeInsets.only(top: 4.0),
            padding: const EdgeInsets.all(12.0),
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
                hintText: '发送消息给 ${_chatWithCharacter!.name}...',
                border: const OutlineInputBorder(),
                fillColor: _chatWithCharacter!.color.withOpacity(0.05),
                filled: true,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
            color: _chatWithCharacter!.color,
          ),
        ],
      ),
    );
  }
}
