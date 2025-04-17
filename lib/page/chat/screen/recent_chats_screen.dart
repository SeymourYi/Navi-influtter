import 'package:flutter/material.dart';
import '../models/recent_chat.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import 'role_selection_screen.dart';
import 'chat_screen.dart';
import 'dart:math' as math;

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
          userPic: userRole.imageAsset, // 添加用户头像参数
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

    print(_recentChats);
    print(_recentChats.length);
    print("---------------------------------");
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.currentCharacter.color;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          '私信',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: themeColor),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: themeColor),
            onPressed: _loadRecentChats,
            tooltip: '刷新',
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator(color: themeColor))
              : _recentChats.isEmpty
              ? _buildEmptyView()
              : _buildChatList(),
    );
  }

  Widget _buildEmptyView() {
    final themeColor = widget.currentCharacter.color;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 70,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无私信',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // 导航到联系人列表
              widget.chatService.requestOnlineUsers();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: themeColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              '查看在线用户',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.separated(
      itemCount: _recentChats.length,
      separatorBuilder:
          (context, index) =>
              Divider(height: 1, color: Colors.grey.shade200, indent: 80),
      itemBuilder: (context, index) {
        final chat = _recentChats[index];
        return _buildChatItem(chat);
      },
    );
  }

  Widget _buildChatItem(RecentChat chat) {
    final themeColor = widget.currentCharacter.color;

    return InkWell(
      onTap: () {
        // 创建Map，确保所有字段都是正确的类型
        final Map<String, dynamic> chatData = {
          "nickname": chat.userName,
          "userId": chat.userId,
          "username": chat.userId,
          "id": chat.userId, // 添加id字段，ChatService中的方法需要使用它
          "userPic": chat.userPic, // 添加 userPic 字段
        };
        print(chatData);
        print(chat.userName);
        print(chat.userId);
        print(chat.userRole);
        print(chat.lastMessage);
        print(chat.unreadCount);

        // 直接导航到聊天界面
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => ChatScreen(initialChatCharacter: chatData),
        //   ),
        // );

        // // 同时通知父组件选择了这个角色
        // widget.onChatSelected(chatData);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头像
            chat.userPic.isNotEmpty
                ? CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(chat.userPic),
                  backgroundColor: Colors.transparent,
                  onBackgroundImageError: (exception, stackTrace) {
                    // 图片加载错误时显示的内容
                    return; // 只是标记错误发生，不做特殊处理
                  },
                )
                : CircleAvatar(
                  backgroundColor: themeColor.withOpacity(0.2),
                  radius: 28,
                  child: Text(
                    chat.userName.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 20,
                      color: themeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            SizedBox(width: 12),
            // 消息内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 用户名和时间
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            chat.userName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '@${chat.userId.substring(0, math.min(6, chat.userId.length))}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        chat.displayTime,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  // 消息预览
                  Text(
                    chat.messagePreview,
                    style: TextStyle(color: Colors.grey.shade800, fontSize: 15),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // 未读消息数
            if (chat.unreadCount > 0)
              Padding(
                padding: EdgeInsets.only(left: 8),
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: themeColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      chat.unreadCount > 9 ? '9+' : chat.unreadCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
