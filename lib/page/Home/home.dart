import 'package:Navi/page/Email/components/infopage.dart';
import 'package:Navi/page/Home/components/things.dart';
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

  void _initImageProviders() {
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
      child: ListView(
        padding: EdgeInsets.all(0),
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture:
                widget.userInfo != null &&
                        widget.userInfo!['userPic'].isNotEmpty
                    ? CircleAvatar(backgroundImage: _avatarImageProvider)
                    : CircleAvatar(
                      backgroundImage: AssetImage(
                        "lib/assets/images/userpic.jpg",
                      ),
                    ),
            decoration: BoxDecoration(
              image: DecorationImage(
                image:
                    widget.userInfo != null &&
                            widget.userInfo!['bgImg'].isNotEmpty
                        ? _backgroundImageProvider!
                        : CachedNetworkImageProvider(
                          'https://img-s.msn.cn/tenant/amp/entityid/AA1yQEG5?w=0&h=0&q=60&m=6&f=jpg&u=t',
                          maxWidth: 800,
                        ),
                fit: BoxFit.cover,
              ),
            ),
            accountName: Text(
              widget.userInfo != null ? widget.userInfo!['nickname'] : "加载中...",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: "Inter-Regular",
                color: Colors.black,
              ),
            ),
            accountEmail: Text(
              widget.userInfo != null
                  ? "@${widget.userInfo!['username']}"
                  : "@加载中...",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
                fontFamily: "Inter-Regular",
              ),
            ),
          ),
          ListTile(
            title: Text(
              "个人信息",
              style: TextStyle(
                color: const Color.fromARGB(255, 126, 121, 211),
                fontSize: 18,
                fontFamily: "Inter-Regular",
              ),
            ),
            leading: SvgPicture.asset("lib/assets/icons/Profile.svg"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder:
                      (context, animation, secondaryAnimation) => ProfilePage(),
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
          ListTile(
            title: Text(
              "关注列表",
              style: TextStyle(
                color: const Color.fromARGB(255, 126, 121, 211),
                fontSize: 18,
                fontFamily: "Inter-Regular",
              ),
            ),
            leading: SvgPicture.asset("lib/assets/icons/Vector1.svg"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder:
                      (context, animation, secondaryAnimation) => FriendsList(),
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
          ListTile(
            title: Text(
              "编辑个人资料",
              style: TextStyle(
                color: const Color.fromARGB(255, 126, 121, 211),
                fontSize: 18,
                fontFamily: "Inter-Regular",
              ),
            ),
            leading: SvgPicture.asset("lib/assets/icons/Vector.svg"),
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
          Divider(),
          ListTile(
            title: Text(
              "关于Navi",
              style: TextStyle(
                color: const Color.fromARGB(255, 126, 121, 211),
                fontSize: 18,
                fontFamily: "Inter-Regular",
              ),
            ),
            leading: SvgPicture.asset("lib/assets/icons/information.svg"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          Padding(
            padding: EdgeInsets.only(top: 310),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                  onPressed: () async {
                    await SharedPrefsUtils.clearUserInfo();
                    await SharedPrefsUtils.clearToken();

                    Navigator.pop(context);

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                      (route) => false,
                    );
                  },
                  icon: Icon(Icons.exit_to_app, color: Colors.red, size: 20),
                  label: Text(
                    "退出",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 117, 113, 206),
                      fontFamily: "Inter-Regular",
                    ),
                  ),
                ),
                Expanded(child: SizedBox.shrink()),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => settings()),
                    );
                  },
                  child: Text(
                    "设置",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 117, 113, 206),
                      fontFamily: "Inter-Regular",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
            (context, animation, secondaryAnimation) => PostPage(type: "发布"),
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
                Tab(text: "通知", icon: Icon(Icons.notifications, size: 20)),
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
            // 使用新创建的带AppBar的NotificationsTab
            ChineseSocialMediaPage(),
          ],
        ),
      ),
    );
  }
}
