import 'package:flutter/material.dart';
import '../models/recent_chat.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import 'role_selection_screen.dart';
import 'chat_screen.dart';

class RecentChatsScreen extends StatefulWidget {
  final ChatService chatService;
  final CharacterRole currentCharacter;
  // final Function(CharacterRole) onChatSelected;
  final dynamic onChatSelected;

  const RecentChatsScreen({
    Key? key,
    required this.chatService,
    required this.currentCharacter,
    required this.onChatSelected,
  }) : super(key: key);

  @override
  State<RecentChatsScreen> createState() => _RecentChatsScreenState();
}

class _RecentChatsScreenState extends State<RecentChatsScreen> {
  List<RecentChat> _recentChats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentChats();
  }

  Future<void> _loadRecentChats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 从私聊会话中构建最近聊天列表
      List<RecentChat> recentChats = [];

      widget.chatService.privateChats.forEach((userId, privateChat) {
        // 忽略空聊天
        if (privateChat.messages.isEmpty) return;

        // 获取最后一条消息
        ChatMessage lastMessage = privateChat.messages.last;

        // 查找用户角色信息
        CharacterRole userRole = widget.chatService.onlineUsers.firstWhere(
          (user) => user.id == userId,
          orElse:
              () => CharacterRole(
                id: userId,
                name: privateChat.userName,
                description: '',
                imageAsset: '',
                color: Colors.grey,
              ),
        );
        // 创建最近聊天项
        RecentChat recentChat = RecentChat(
          userId: userId,
          userName: privateChat.userName,
          userRole: userRole,
          lastMessage: lastMessage,
          unreadCount: privateChat.unreadCount, // 从私聊对象获取未读消息计数
        );

        recentChats.add(recentChat);
      });

      // 按最后活动时间排序
      recentChats.sort(
        (a, b) =>
            b.activityTimeFromMessage.compareTo(a.activityTimeFromMessage),
      );

      setState(() {
        _recentChats = recentChats;
        _isLoading = false;
      });
    } catch (e) {
      print('加载最近聊天出错: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('最近聊天'),
        backgroundColor: widget.currentCharacter.color,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecentChats,
            tooltip: '刷新',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _recentChats.isEmpty
              ? _buildEmptyView()
              : _buildChatList(),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无最近聊天',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // 导航到联系人列表
              widget.chatService.requestOnlineUsers();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.people),
            label: const Text('查看在线用户'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: widget.currentCharacter.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      itemCount: _recentChats.length,
      itemBuilder: (context, index) {
        final chat = _recentChats[index];
        return _buildChatItem(chat);
      },
    );
  }

  Widget _buildChatItem(RecentChat chat) {
    return ListTile(
      leading: CircleAvatar(
        // backgroundColor: chat.userRole.color.withOpacity(0.3),
        radius: 25,
        child: Text(
          chat.userName.substring(0, 1),
          style: TextStyle(
            fontSize: 18,
            color: chat.userRole.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              chat.userName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Text(
            chat.displayTime,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              chat.messagePreview,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (chat.unreadCount > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                chat.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: () {
        print("gggggggggggggggggggggg");
        print("chat.userRole: ${chat.userRole}");
        print("chat.userName: ${chat.userName}");
        print("chat.userId: ${chat.userId}");
        print("VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV");

        // 创建Map，确保所有字段都是正确的类型
        final Map<String, dynamic> chatData = {
          "nickname": chat.userName,
          "userId": chat.userId,
          "username": chat.userId,
          "id": chat.userId, // 添加id字段，ChatService中的方法需要使用它
        };

        print("chatData: $chatData");
        print("VVVVVTTTTTTTTTTTTTTTTTTTTTTTVVVVVVVVVVVVVVV");

        // 直接导航到聊天界面
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(initialChatCharacter: chatData),
          ),
        );

        // 同时通知父组件选择了这个角色
        widget.onChatSelected(chatData);
      },
    );
  }
}
