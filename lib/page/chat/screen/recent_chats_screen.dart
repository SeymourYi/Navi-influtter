import 'package:Navi/api/userAPI.dart';
import 'package:Navi/page/chat/screen/privtschatcreen.dart';
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

class _RecentChatsScreenState extends State<RecentChatsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  List<RecentChat> _recentChats = [];

  bool _isLoading = true;
  UserService service = UserService();
  final Map<String, dynamic> chatData = {
    "nickname": "金杯车",
    "username": 2222,
    "userPic":
        'https://bigevent24563.oss-cn-beijing.aliyuncs.com/973eae25-8da6-4011-9281-f686f03c1bfd.jpg', // 添加 userPic 字段
    "bio": "我浑身难受",
  };
  @override
  void initState() {
    super.initState();
    _loadRecentChats();
  }

  Future<void> _getuserinf(username) async {
    var userinfo = await service.getsomeUserinfo(username);
    // print(userinfo);
    // print("-------------yyyyyyyyyyyyyyyyyyyyyy-------------------");
    // print(chatData);
    // print("-------------yyyyyyyyyyyyyyyyyyyyyy-------------------");
    // print("bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb");
    chatData['nickname'] = userinfo['data']['nickname'];
    chatData['username'] = userinfo['data']['username'];
    chatData['userPic'] = userinfo['data']['userPic'];
    chatData['bio'] = userinfo['data']['bio'];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrivtsChatScreen(character: chatData),
      ),
    );

    // // 同时通知父组件选择了这个角色
    widget.onChatSelected(chatData);
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

        // 将创建的recentChat添加到recentChats列表中
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
        _getuserinf(chat.userId);
        // 直接导航到聊天界面
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
