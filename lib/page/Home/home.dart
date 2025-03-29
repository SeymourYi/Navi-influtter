import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterlearn2/components/like_notification_list.dart';
import 'package:flutterlearn2/models/like_notification.dart';
import 'package:flutterlearn2/page/Home/articlelist.dart';
import 'package:flutterlearn2/page/UserInfo/components/userpage.dart';
import 'package:flutterlearn2/page/edit/editpage.dart';
import 'package:flutterlearn2/page/friends/friendspage.dart';
import 'package:flutterlearn2/page/post/post.dart';
import 'package:flutterlearn2/page/search/search.dart';
import 'package:flutterlearn2/page/login/login.dart';
import 'package:flutterlearn2/Store/storeutils.dart';
import 'package:cached_network_image/cached_network_image.dart';

// 创建一个单独的抽屉组件，以便能够缓存起来
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
    // 当用户信息更新时，重新初始化图片
    if (oldWidget.userInfo != widget.userInfo) {
      _initImageProviders();
    }
  }

  void _initImageProviders() {
    if (widget.userInfo != null) {
      // 初始化背景图片提供者
      if (widget.userInfo!['bgImg'].isNotEmpty) {
        _backgroundImageProvider = CachedNetworkImageProvider(
          widget.userInfo!['bgImg'],
          maxWidth: 800, // 设置最大宽度以优化内存使用
        );
      } else {
        _backgroundImageProvider = null;
      }

      // 初始化头像图片提供者
      if (widget.userInfo!['userPic'].isNotEmpty) {
        _avatarImageProvider = CachedNetworkImageProvider(
          widget.userInfo!['userPic'],
          maxWidth: 200, // 设置最大宽度以优化内存使用
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

              // 当从EditProfilePage返回时刷新用户信息
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
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text("设置"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: Icon(
                                    Icons.exit_to_app,
                                    color: Colors.red,
                                  ),
                                  title: Text("退出登录"),
                                  onTap: () async {
                                    await SharedPrefsUtils.clearUserInfo();
                                    await SharedPrefsUtils.clearToken();

                                    Navigator.pop(context);
                                    Navigator.pop(context);

                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LoginPage(),
                                      ),
                                      (route) => false,
                                    );
                                  },
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("取消"),
                              ),
                            ],
                          ),
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

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  Map<String, dynamic>? _userInfo;
  bool _isLoading = true;
  // 创建一个持久化的drawer实例
  PersistentDrawer? _persistentDrawer;

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
    // 可以添加更多数据...
  ];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  // 添加didChangeDependencies方法，处理返回到这个页面时刷新数据
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final userInfo = await SharedPrefsUtils.getUserInfo();
      setState(() {
        _userInfo = userInfo;
        _isLoading = false;
        // 初始化持久化drawer
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

  // 添加一个方法来刷新用户信息，但不显示加载指示器
  Future<void> _refreshUserInfo() async {
    try {
      final userInfo = await SharedPrefsUtils.getUserInfo();
      if (mounted) {
        setState(() {
          _userInfo = userInfo;
          // 当用户信息更新时，更新drawer
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

  @override
  Widget build(BuildContext context) {
    // 确保在构建前已初始化drawer
    if (_persistentDrawer == null && !_isLoading && _userInfo != null) {
      _persistentDrawer = PersistentDrawer(
        userInfo: _userInfo,
        onRefreshUserInfo: _refreshUserInfo,
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder:
                        (context, animation, secondaryAnimation) =>
                            SearchPage(),
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
              icon: SvgPicture.asset(
                "lib/assets/icons/adduser.svg",
                height: 20,
                width: 20,
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Container(
              color: Color.fromARGB(67, 98, 73, 73),
              height: 0.3,
            ),
          ),
        ),
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
              tabs: [
                Tab(text: "主页", icon: Icon(Icons.home, size: 20)),
                Tab(text: "消息", icon: Icon(Icons.email, size: 20)),
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
            Articlelist(),
            LikeNotificationList(
              notifications: notifications,
              onFollowUser: (user) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("已关注 ${user.name}")));
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder:
                    (context, animation, secondaryAnimation) => PostPage(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
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
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
