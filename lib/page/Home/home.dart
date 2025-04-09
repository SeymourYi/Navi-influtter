import 'package:Navi/api/emailAPI.dart';
import 'package:Navi/page/Email/components/infopage.dart';
import 'package:Navi/page/Email/emailList.dart';
import 'package:Navi/page/Home/components/things.dart';
import 'package:Navi/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:Navi/components/like_notification_list.dart';
import 'package:Navi/models/like_notification.dart';
import 'package:Navi/page/Home/articlelist.dart';
import 'package:Navi/page/UserInfo/components/userpage.dart';
import 'package:Navi/page/chat/screen/chat_screen.dart';
import 'package:Navi/page/edit/editpage.dart';
import 'package:Navi/page/friends/friendspage.dart';
import 'package:Navi/page/post/post.dart';
import 'package:Navi/page/search/search.dart';
import 'package:Navi/page/login/login.dart';
import 'package:Navi/Store/storeutils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import '../../utils/myjpush.dart';
import 'package:Navi/page/Setting/settings.dart';
import 'package:provider/provider.dart';

// PersistentDrawer remains the same as your original code
class PersistentDrawer extends StatefulWidget {
  final Map<String, dynamic>? userInfo;
  final VoidCallback onRefreshUserInfo;

  const PersistentDrawer({
    Key? key,
    required this.userInfo,
    required this.onRefreshUserInfo,
  }) : super(key: key);

  @override
  State<PersistentDrawer> createState() => _PersistentDrawerState();
}

class _PersistentDrawerState extends State<PersistentDrawer> {
  late CachedNetworkImageProvider? _backgroundImageProvider;
  late CachedNetworkImageProvider? _avatarImageProvider;
  String number = '';
  @override
  void initState() {
    super.initState();
    _initImageProviders();
  }

  @override
  void didUpdateWidget(PersistentDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userInfo != widget.userInfo) {
      _initImageProviders();
    }
  }

  EmailService service = EmailService();
  void _initImageProviders() async {
    if (widget.userInfo != null) {
      if (widget.userInfo!['bgImg'].isNotEmpty) {
        _backgroundImageProvider = CachedNetworkImageProvider(
          widget.userInfo!['bgImg'],
          maxWidth: 800,
        );
      } else {
        _backgroundImageProvider = null;
      }

      if (widget.userInfo!['userPic'].isNotEmpty) {
        _avatarImageProvider = CachedNetworkImageProvider(
          widget.userInfo!['userPic'],
          maxWidth: 200,
        );
      } else {
        _avatarImageProvider = null;
      }
    } else {
      _backgroundImageProvider = null;
      _avatarImageProvider = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // 顶部用户信息区域
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 16,
              left: 16,
              right: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 头像和关闭按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage:
                          widget.userInfo != null &&
                                  widget.userInfo!['userPic'].isNotEmpty
                              ? _avatarImageProvider
                              : AssetImage("lib/assets/images/userpic.jpg")
                                  as ImageProvider,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // 用户名和ID
                Text(
                  widget.userInfo != null
                      ? widget.userInfo!['nickname']
                      : "加载中...",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Inter-Regular",
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  widget.userInfo != null
                      ? "@${widget.userInfo!['username']}"
                      : "@加载中...",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 15,
                    fontFamily: "Inter-Regular",
                  ),
                ),
                SizedBox(height: 16),
                // 关注信息
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    FriendsList(),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.ease;
                              var tween = Tween(
                                begin: begin,
                                end: end,
                              ).chain(CurveTween(curve: curve));
                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "20 ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: "关注中",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "30 ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: "粉丝",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 0.5,
            color: Colors.grey.withOpacity(0.2),
          ),
          // 菜单区域
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildTwitterMenuItem(
                  title: "个人信息",
                  icon: Icons.person_outline,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder:
                            (context, animation, secondaryAnimation) =>
                                ProfilePage(),
                        transitionsBuilder: (
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.ease;
                          var tween = Tween(
                            begin: begin,
                            end: end,
                          ).chain(CurveTween(curve: curve));
                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                ),
                _buildTwitterMenuItem(
                  title: "关注列表",
                  icon: Icons.people_outline,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder:
                            (context, animation, secondaryAnimation) =>
                                FriendsList(),
                        transitionsBuilder: (
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.ease;
                          var tween = Tween(
                            begin: begin,
                            end: end,
                          ).chain(CurveTween(curve: curve));
                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                ),
                _buildTwitterMenuItem(
                  title: "编辑个人资料",
                  icon: Icons.edit_outlined,
                  onTap: () async {
                    Navigator.pop(context);
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfilePage(),
                      ),
                    );
                    if (result == true || result == null) {
                      widget.onRefreshUserInfo();
                    }
                  },
                ),
                _buildTwitterMenuItem(
                  title: "设置",
                  icon: Icons.settings_outlined,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => settings()),
                    );
                  },
                ),

                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: Colors.grey.withOpacity(0.2),
                ),
                _buildTwitterMenuItem(
                  title: "关于Navi",
                  icon: Icons.info_outline,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          // 底部退出按钮
          // Container(
          //   width: double.infinity,
          //   margin: EdgeInsets.all(16),
          //   child: ElevatedButton(
          //     onPressed: () async {
          //       await SharedPrefsUtils.clearUserInfo();
          //       await SharedPrefsUtils.clearToken();
          //       Navigator.pop(context);
          //       Navigator.pushAndRemoveUntil(
          //         context,
          //         MaterialPageRoute(builder: (context) => LoginPage()),
          //         (route) => false,
          //       );
          //     },
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: const Color.fromARGB(255, 126, 121, 211),
          //       foregroundColor: Colors.white,
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(30),
          //       ),
          //       padding: EdgeInsets.symmetric(vertical: 12),
          //     ),
          //     child: Text(
          //       "退出登录",
          //       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildTwitterMenuItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: const Color.fromARGB(255, 126, 121, 211),
            ),
            SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 创建动态页面TabView，包含自己的AppBar
class HomeTab extends StatelessWidget {
  final Map<String, dynamic>? userInfo;
  final VoidCallback onSearchPressed;
  final VoidCallback onAddPostPressed;

  const HomeTab({
    Key? key,
    required this.userInfo,
    required this.onSearchPressed,
    required this.onAddPostPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Navi",
          style: TextStyle(
            fontSize: 23,
            fontFamily: "Inter-Regular",
            color: const Color.fromARGB(71, 116, 55, 202),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            //打开侧边栏
            Scaffold.of(context).openDrawer(); // 打开侧边栏R
          },
          icon: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(userInfo!['userPic']),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: onSearchPressed,
            icon: SvgPicture.asset(
              "lib/assets/icons/adduser.svg",
              height: 20,
              width: 20,
            ),
          ),
        ],

        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(color: Color.fromARGB(67, 98, 73, 73), height: 0.3),
        ),
      ),
      body: things(),
      floatingActionButton: FloatingActionButton(
        onPressed: onAddPostPressed,
        backgroundColor: Color(0xFF6F6BCC),
        shape: CircleBorder(),
        child: SvgPicture.asset(
          "lib/assets/icons/postbuttonicon.svg",
          width: 24,
          height: 24,
          color: Colors.white,
        ),
      ),
    );
  }
}

// 创建通知页面TabView，包含自己的AppBar
class NotificationsTab extends StatelessWidget {
  final List<LikeNotification> notifications;

  const NotificationsTab({Key? key, required this.notifications})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "通知",
          style: TextStyle(
            fontSize: 23,
            fontFamily: "Inter-Regular",
            color: const Color.fromARGB(71, 116, 55, 202),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(color: Color.fromARGB(67, 98, 73, 73), height: 0.3),
        ),
      ),
      body: LikeNotificationList(
        notifications: notifications,
        onFollowUser: (user) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("已关注 ${user.name}")));
        },
      ),
    );
  }
}

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  Map<String, dynamic>? _userInfo;
  bool _isLoading = true;
  PersistentDrawer? _persistentDrawer;
  int _currentTabIndex = 0;

  final List<LikeNotification> notifications = [
    LikeNotification(
      postTitle: "我的Flutter学习心得",
      postPreview: "分享我最近学习Flutter的体会和经验...",
      user: UserInfo(
        avatar: "assets/avatars/user1.jpg",
        name: "张开发者",
        location: "北京 · 海淀区",
        occupation: "移动端开发工程师",
        joinDate: DateTime(2021, 3, 15),
        bio: "热爱技术分享，专注移动开发领域",
      ),
      likedAt: DateTime(2023, 7, 20, 14, 30),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final userInfo = await SharedPrefsUtils.getUserInfo();
      Myjpush().initPlatformState(userInfo!['username']);
      setState(() {
        _userInfo = userInfo;
        _isLoading = false;
        if (_persistentDrawer == null) {
          _persistentDrawer = PersistentDrawer(
            userInfo: _userInfo,
            onRefreshUserInfo: _refreshUserInfo,
          );
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('加载用户信息出错: $e');
    }
  }

  Future<void> _refreshUserInfo() async {
    try {
      final userInfo = await SharedPrefsUtils.getUserInfo();
      Myjpush().initPlatformState(userInfo!['username']);
      if (mounted) {
        setState(() {
          _userInfo = userInfo;
          if (_persistentDrawer != null) {
            _persistentDrawer = PersistentDrawer(
              userInfo: _userInfo,
              onRefreshUserInfo: _refreshUserInfo,
            );
          }
        });
      }
    } catch (e) {
      print('刷新用户信息出错: $e');
    }
  }

  void _navigateToSearch() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SearchPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  void _navigateToPost() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                PostPage(type: "发布", articelData: null),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.ease;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_persistentDrawer == null && !_isLoading && _userInfo != null) {
      _persistentDrawer = PersistentDrawer(
        userInfo: _userInfo,
        onRefreshUserInfo: _refreshUserInfo,
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // 移除主Scaffold的AppBar，AppBar将在各个Tab中定义
        drawer:
            _isLoading
                ? Drawer(child: Center(child: CircularProgressIndicator()))
                : _persistentDrawer,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey[300]!, width: 1.0),
            ),
          ),
          child: SizedBox(
            height: 50,
            child: TabBar(
              onTap: (index) {
                setState(() {
                  _currentTabIndex = index;
                });
              },
              tabs: [
                Tab(text: "动态", icon: Icon(Icons.home, size: 20)),
                Tab(
                  text: "通知",
                  icon: Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.only(right: 10, top: 4),
                        child: Icon(Icons.notifications, size: 20),
                      ),

                      Positioned(
                        right: 0,
                        top: 0,
                        child: Consumer<NotificationProvider>(
                          builder: (context, notificationProvider, child) {
                            final count =
                                notificationProvider.getnotificationcount();
                            return count > 0
                                ? Container(
                                  padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    count.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                                : SizedBox.shrink();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.transparent,
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              unselectedLabelStyle: TextStyle(fontSize: 12),
              labelStyle: TextStyle(fontSize: 12),
              labelColor: const Color.fromARGB(255, 106, 75, 202),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // 使用新创建的带AppBar的HomeTab
            HomeTab(
              userInfo: _userInfo,
              onSearchPressed: _navigateToSearch,
              onAddPostPressed: _navigateToPost,
            ),

            EmailList(),
          ],
        ),
      ),
    );
  }
}
