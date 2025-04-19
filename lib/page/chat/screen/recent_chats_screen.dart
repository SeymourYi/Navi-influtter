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
  // 添加用户信息缓存Map
  final Map<String, Map<String, dynamic>> _userInfoCache = {};

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
    try {
      // 优先使用缓存数据
      if (_userInfoCache.containsKey(username)) {
        final cachedData = _userInfoCache[username]!;
        chatData['nickname'] = cachedData['nickname'];
        chatData['username'] = cachedData['username'];
        chatData['userPic'] = cachedData['userPic'];
        chatData['bio'] = cachedData['bio'];
      } else {
        // 如果没有缓存，才发起网络请求
        var userinfo = await service.getsomeUserinfo(username);
        chatData['nickname'] = userinfo['data']['nickname'];
        chatData['username'] = userinfo['data']['username'];
        chatData['userPic'] = userinfo['data']['userPic'];
        chatData['bio'] = userinfo['data']['bio'];

        // 将获取的数据加入缓存
        _userInfoCache[username] = {
          'nickname': userinfo['data']['nickname'],
          'username': userinfo['data']['username'],
          'userPic': userinfo['data']['userPic'],
          'bio': userinfo['data']['bio'],
        };
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PrivtsChatScreen(character: chatData),
        ),
      );

      // 通知父组件选择了这个角色
      widget.onChatSelected(chatData);
    } catch (e) {
      print('获取用户信息失败: $e');
    }
  }

  // 预加载所有用户信息
  Future<void> _preloadUserInfo(List<String> userIds) async {
    for (var userId in userIds) {
      if (!_userInfoCache.containsKey(userId)) {
        try {
          var userinfo = await service.getsomeUserinfo(userId);
          _userInfoCache[userId] = {
            'nickname': userinfo['data']['nickname'],
            'username': userinfo['data']['username'],
            'userPic': userinfo['data']['userPic'],
            'bio': userinfo['data']['bio'],
          };
        } catch (e) {
          print('预加载用户信息失败: $e');
        }
      }
    }
  }

  Future<Map<String, dynamic>> _getUserInfo(String userId) async {
    if (_userInfoCache.containsKey(userId)) {
      return _userInfoCache[userId]!;
    }

    try {
      var userinfo = await service.getsomeUserinfo(userId);
      _userInfoCache[userId] = {
        'nickname': userinfo['data']['nickname'],
        'username': userinfo['data']['username'],
        'userPic': userinfo['data']['userPic'],
        'bio': userinfo['data']['bio'],
      };
      return _userInfoCache[userId]!;
    } catch (e) {
      print('获取用户信息失败: $e');
      return {'nickname': '未知', 'username': userId, 'userPic': '', 'bio': ''};
    }
  }

  Future<void> _loadRecentChats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 从私聊会话中构建最近聊天列表
      List<RecentChat> recentChats = [];
      List<String> userIds = [];

      widget.chatService.privateChats.forEach((userId, privateChat) {
        // 忽略空聊天
        if (privateChat.messages.isEmpty) return;

        // 收集需要加载的用户ID
        userIds.add(userId);

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

      // 在设置完状态后，预加载所有用户信息
      await _preloadUserInfo(userIds);
    } catch (e) {
      print('加载最近聊天出错: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
        _getuserinf(chat.userId);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头像
            FutureBuilder<Map<String, dynamic>>(
              future: _getUserInfo(chat.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData &&
                    snapshot.data!['userPic'] != null) {
                  return CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(snapshot.data!['userPic']),
                    backgroundColor: Colors.transparent,
                    onBackgroundImageError: (exception, stackTrace) {
                      return;
                    },
                  );
                } else {
                  // 加载中或出错时显示默认头像
                  return CircleAvatar(
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
                  );
                }
              },
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
                          FutureBuilder<Map<String, dynamic>>(
                            future: _getUserInfo(chat.userId),
                            builder: (context, snapshot) {
                              return Text(
                                snapshot.connectionState ==
                                            ConnectionState.done &&
                                        snapshot.hasData
                                    ? snapshot.data!['nickname']
                                    : chat.userName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              );
                            },
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
