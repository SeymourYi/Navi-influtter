import 'dart:ui';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:Navi/api/emailAPI.dart';
import 'package:Navi/components/full_screen_image_view.dart';
import 'package:Navi/page/About/aboutNavi.dart';
import 'package:Navi/page/Email/components/infopage.dart';
import 'package:Navi/page/Email/emailList.dart';
import 'package:Navi/page/Home/components/things.dart';
import 'package:Navi/page/UserInfo/userhomemain.dart';
import 'package:Navi/page/chat/screen/recent_chats_screen.dart';
import 'package:Navi/providers/notification_provider.dart';
import 'package:Navi/page/me/me.dart';
// import 'package:Navi/test/article/articletest.dart';
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
import 'package:Navi/page/search/add_friend_page.dart';
import 'package:Navi/page/search/search_posts_page.dart';
import 'package:Navi/page/login/login.dart';
import 'package:Navi/Store/storeutils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import '../../utils/myjpush.dart';
import '../../utils/route_utils.dart';
import 'package:Navi/page/Setting/settings.dart';
import 'package:provider/provider.dart';
import 'package:Navi/page/chat/services/chat_service.dart';
import 'package:Navi/page/chat/screen/role_selection_screen.dart';
import 'package:Navi/page/chat/config/app_config.dart';
import 'package:Navi/page/chat/models/chat_message.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';

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
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => FullScreenImageView(
                              // imageUrls: List.from(
                              //   _userinfo["userPic"],
                              // ),
                              imageUrls: [widget.userInfo!['userPic']],
                              initialIndex: 0,
                            ),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: widget.userInfo != null &&
                                widget.userInfo!['userPic'].isNotEmpty
                            ? _avatarImageProvider
                            : AssetImage("lib/assets/images/userpic.jpg")
                                as ImageProvider,
                      ),
                    ),

                    // CircleAvatar(
                    //   radius: 20,
                    //   backgroundImage:
                    //       widget.userInfo != null &&
                    //               widget.userInfo!['userPic'].isNotEmpty
                    //           ? _avatarImageProvider
                    //           : AssetImage("lib/assets/images/userpic.jpg")
                    //               as ImageProvider,
                    // ),
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
                      RouteUtils.slideFromRight(ProfilePage()),
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
                      RouteUtils.slideFromRight(const FriendsList()),
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
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => Aboutnavi()),
                    );
                  },
                ),
              ],
            ),
          ),
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
class HomeTab extends StatefulWidget {
  final Map<String, dynamic>? userInfo;
  final VoidCallback onSearchPressed;
  final VoidCallback onAddPostPressed;
  final Function(double)? onScrollChanged; // 添加滚动变化回调

  const HomeTab({
    Key? key,
    required this.userInfo,
    required this.onSearchPressed,
    required this.onAddPostPressed,
    this.onScrollChanged,
  }) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  double _animationValue = 0.0; // 动画值 0.0-1.0
  double _lastScrollOffset = 0.0;
  late AnimationController _hideAnimationController;
  late Animation<double> _hideAnimation;

  // 滚动方向检测
  bool _isScrollingUp = false;
  DateTime _lastScrollTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    // 初始化隐藏动画控制器
    _hideAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _hideAnimation = CurvedAnimation(
      parent: _hideAnimationController,
      curve: Curves.easeOutCubic,
    );

    _hideAnimation.addListener(() {
      // 确保每次动画值变化都更新UI
      if (mounted) {
        final newValue = _hideAnimation.value;
        if ((newValue - _animationValue).abs() > 0.001) {
          setState(() {
            _animationValue = newValue;
          });
          // 根据动画值动态控制状态栏
          _updateSystemUI();
        }
      }
    });

    // 初始化时设置状态栏
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSystemUI();
    });
  }

  @override
  void dispose() {
    _hideAnimationController.dispose();
    // 恢复系统UI设置
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    super.dispose();
  }

  void _handleScroll(double offset) {
    // 将滚动位置传递给父组件
    if (widget.onScrollChanged != null) {
      widget.onScrollChanged!(offset);
    }

    // 计算滚动方向：offset 增加 = 向上滚动（内容向下），offset 减少 = 向下滚动（内容向上）
    final double scrollDelta = offset - _lastScrollOffset;

    // 如果滚动变化太小，忽略但更新位置
    if (scrollDelta.abs() < 0.1) {
      _lastScrollOffset = offset;
      return;
    }

    // 更新最后滚动时间
    _lastScrollTime = DateTime.now();

    // 判断滚动方向
    final bool scrollingUp = scrollDelta > 0;
    _isScrollingUp = scrollingUp;

    // 计算目标动画值
    double targetValue = _hideAnimationController.value;

    if (scrollingUp) {
      // 向上滚动：隐藏导航栏（增加动画值）
      double increment = (scrollDelta.abs() / 20.0).clamp(0.05, 0.25);
      targetValue = (targetValue + increment).clamp(0.0, 1.0);
    } else {
      // 向下滚动：显示导航栏（减少动画值）
      // 如果已经隐藏很多，使用更快的显示速度
      if (targetValue > 0.9) {
        // 完全隐藏时，任何向下滚动都立即开始显示
        targetValue = (targetValue - 0.2).clamp(0.0, 1.0);
      } else if (targetValue > 0.5) {
        // 部分隐藏时，快速显示
        double decrement = (scrollDelta.abs() / 10.0).clamp(0.1, 0.3);
        targetValue = (targetValue - decrement).clamp(0.0, 1.0);
      } else {
        // 正常显示速度
        double decrement = (scrollDelta.abs() / 20.0).clamp(0.05, 0.25);
        targetValue = (targetValue - decrement).clamp(0.0, 1.0);
      }
    }

    // 如果滚动到顶部，强制显示
    if (offset <= 0) {
      targetValue = 0.0;
    }

    // 确保边界值
    targetValue = targetValue.clamp(0.0, 1.0);

    // 立即更新动画值（直接设置值，动画监听器会自动触发 setState）
    if ((targetValue - _hideAnimationController.value).abs() > 0.001) {
      _hideAnimationController.value = targetValue;
    }

    _lastScrollOffset = offset;
  }

  /// 根据动画值更新系统UI（状态栏）
  void _updateSystemUI() {
    // 不使用沉浸式模式，避免无法交互
    // 而是通过透明度控制状态栏的视觉隐藏
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values, // 始终保持所有系统UI可交互
    );

    // 根据动画值设置状态栏样式
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        // 当隐藏时，状态栏图标变浅（但保持可见以确保可交互）
        statusBarIconBrightness:
            _animationValue > 0.7 ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        // 根据可见性设置状态栏样式
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            _animationValue > 0.8 ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(kToolbarHeight * (1 - _animationValue)),
          child: ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: 1.0 - _animationValue,
              child: Opacity(
                opacity: 1.0 - _animationValue,
                child: AppBar(
                  centerTitle: true,
                  title: Text(
                    "Navi",
                    style: TextStyle(
                      fontSize: 23,
                      fontFamily: "Inter-Regular",
                      color: const Color.fromARGB(71, 116, 55, 202),
                    ),
                  ),
                  leading: null,
                  automaticallyImplyLeading: false,
                  actions: [
                    PopupMenuButton<String>(
                      icon: SvgPicture.asset(
                        "lib/assets/icons/adduser.svg",
                        height: 20,
                        width: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.white,
                      elevation: 8,
                      offset: const Offset(0, 50), // 菜单往下偏移
                      onSelected: (value) {
                        if (value == 'add_friend') {
                          Navigator.push(
                            context,
                            RouteUtils.slideFromBottom(AddFriendPage()),
                          );
                        } else if (value == 'search_posts') {
                          Navigator.push(
                            context,
                            RouteUtils.slideFromBottom(SearchPostsPage()),
                          );
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<String>(
                          value: 'add_friend',
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.person_add_outlined,
                                size: 20,
                                color: Colors.black87,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                '添加朋友',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'search_posts',
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                size: 20,
                                color: Colors.black87,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                '搜索帖子',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(0),
                    child: Container(color: Colors.transparent, height: 0),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: things(onScrollChanged: _handleScroll),
        floatingActionButton: Transform.translate(
          offset: Offset(0, 100 * _animationValue),
          child: Transform.scale(
            scale: 1.0 - 0.3 * _animationValue,
            child: Opacity(
              opacity: 1.0 - _animationValue,
              child: FloatingActionButton(
                onPressed: widget.onAddPostPressed,
                backgroundColor: Color.fromRGBO(98, 1, 231, 1.00),
                shape: CircleBorder(),
                child: SvgPicture.asset(
                  "lib/assets/icons/PostButtonIcon.svg",
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> with TickerProviderStateMixin {
  Map<String, dynamic>? _userInfo;
  bool _isLoading = true;
  int _currentTabIndex = 0;
  late TabController _tabController;
  // 添加动画值监听的变量
  double _homePosition = 0.0;
  double _notificationPosition = 0.0;
  double _personPosition = 0.0;

  // 添加聊天相关变量
  ChatService? _chatService;
  CharacterRole? _selectedCharacter;
  bool _isChatInitialized = false;

  // 添加底部导航栏动画值
  double _bottomBarAnimationValue = 0.0;
  double _lastScrollOffset = 0.0;
  late AnimationController _bottomBarAnimationController;
  late Animation<double> _bottomBarAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _tabController = TabController(length: 3, vsync: this);

    // 初始化底部导航栏动画控制器
    _bottomBarAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _bottomBarAnimation = CurvedAnimation(
      parent: _bottomBarAnimationController,
      curve: Curves.easeOutCubic,
    );

    _bottomBarAnimation.addListener(() {
      // 确保每次动画值变化都更新UI
      if (mounted) {
        final newValue = _bottomBarAnimation.value;
        if ((newValue - _bottomBarAnimationValue).abs() > 0.001) {
          setState(() {
            _bottomBarAnimationValue = newValue;
          });
        }
      }
    });

    // 修改监听方式，添加动画监听
    _homePosition = 1.0;
    _tabController.addListener(_handleTabAnimation);
    _tabController.animation!.addListener(_handleTabControllerAnimationTick);
    _getnotifitionlison();
  }

  // 处理主页滚动变化（基于滚动方向）
  void _handleHomeScrollChanged(double offset) {
    if (_currentTabIndex == 0) {
      // 只在主页标签时控制底部导航栏
      // 计算滚动方向
      final double scrollDelta = offset - _lastScrollOffset;

      // 如果滚动变化太小，忽略但更新位置
      if (scrollDelta.abs() < 0.1) {
        _lastScrollOffset = offset;
        return;
      }

      // 判断滚动方向
      final bool scrollingUp = scrollDelta > 0;

      // 计算目标动画值
      double targetValue = _bottomBarAnimationController.value;

      if (scrollingUp) {
        // 向上滚动：隐藏底部导航栏（增加动画值）
        double increment = (scrollDelta.abs() / 20.0).clamp(0.05, 0.25);
        targetValue = (targetValue + increment).clamp(0.0, 1.0);
      } else {
        // 向下滚动：显示底部导航栏（减少动画值）
        // 如果已经隐藏很多，使用更快的显示速度
        if (targetValue > 0.9) {
          // 完全隐藏时，任何向下滚动都立即开始显示
          targetValue = (targetValue - 0.2).clamp(0.0, 1.0);
        } else if (targetValue > 0.5) {
          // 部分隐藏时，快速显示
          double decrement = (scrollDelta.abs() / 10.0).clamp(0.1, 0.3);
          targetValue = (targetValue - decrement).clamp(0.0, 1.0);
        } else {
          // 正常显示速度
          double decrement = (scrollDelta.abs() / 20.0).clamp(0.05, 0.25);
          targetValue = (targetValue - decrement).clamp(0.0, 1.0);
        }
      }

      // 如果滚动到顶部，强制显示
      if (offset <= 0) {
        targetValue = 0.0;
      }

      // 确保边界值
      targetValue = targetValue.clamp(0.0, 1.0);

      // 立即更新动画值（直接设置值，动画监听器会自动触发 setState）
      if ((targetValue - _bottomBarAnimationController.value).abs() > 0.001) {
        _bottomBarAnimationController.value = targetValue;
      }
    } else {
      // 切换到其他标签时，重置为显示状态
      if (_bottomBarAnimationValue > 0.01) {
        _bottomBarAnimationController.value = 0.0;
      }
    }

    _lastScrollOffset = offset;
  }

  void _getnotifitionlison() {
    _checkAndRequestNotificationPermission();
  }

  Future<void> _checkAndRequestNotificationPermission() async {
    try {
      // 检查通知权限状态
      final status = await Permission.notification.status;

      if (status.isDenied || status.isPermanentlyDenied) {
        // 如果权限被拒绝，显示对话框提示用户
        // if (mounted) {
        //   showDialog(
        //     context: context,
        //     builder: (BuildContext context) {
        //       return AlertDialog(
        //         shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(16),
        //         ),
        //         backgroundColor: Colors.white,
        //         title: Row(
        //           children: [
        //             Icon(
        //               Icons.notifications_active_outlined,
        //               color: Color(0xFF6201E7),
        //               size: 24,
        //             ),
        //             const SizedBox(width: 12),
        //             const Expanded(
        //               child: Text(
        //                 '开启通知权限',
        //                 style: TextStyle(
        //                   fontSize: 18,
        //                   fontWeight: FontWeight.bold,
        //                   color: Colors.black87,
        //                 ),
        //               ),
        //             ),
        //           ],
        //         ),
        //         content: const Text(
        //           '为了及时接收私信消息，请允许Navi发送通知',
        //           style: TextStyle(
        //             fontSize: 14,
        //             color: Colors.black87,
        //             height: 1.5,
        //           ),
        //         ),
        //         actions: [
        //           TextButton(
        //             onPressed: () {
        //               Navigator.of(context).pop();
        //             },
        //             style: TextButton.styleFrom(
        //               padding: const EdgeInsets.symmetric(
        //                   horizontal: 20, vertical: 10),
        //             ),
        //             child: Text(
        //               '稍后再说',
        //               style: TextStyle(
        //                 color: Colors.grey[600],
        //                 fontSize: 14,
        //                 fontWeight: FontWeight.w500,
        //               ),
        //             ),
        //           ),
        //           ElevatedButton(
        //             style: ElevatedButton.styleFrom(
        //               backgroundColor: const Color(0xFF6201E7),
        //               foregroundColor: Colors.white,
        //               shape: RoundedRectangleBorder(
        //                 borderRadius: BorderRadius.circular(20),
        //               ),
        //               padding: const EdgeInsets.symmetric(
        //                   horizontal: 20, vertical: 10),
        //               elevation: 0,
        //             ),
        //             onPressed: () async {
        //               Navigator.of(context).pop();
        //               // 打开应用设置页面，让用户手动开启权限
        //               await openAppSettings();
        //             },
        //             child: const Text(
        //               '去设置',
        //               style: TextStyle(
        //                 fontSize: 14,
        //                 fontWeight: FontWeight.w600,
        //               ),
        //             ),
        //           ),
        //         ],
        //       );
        //     },
        //   );
        // }
      } else if (status.isLimited) {
        // 权限有限，可能需要进一步处理
        print('通知权限受限');
      } else if (status.isGranted) {
        // 已授予权限，可以进行后续操作
        print('已获得通知权限');
      }
    } catch (e) {
      print('检查通知权限出错: $e');
    }
  }

  // 新增动画监听函数
  void _handleTabAnimation() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentTabIndex = _tabController.index;
        // 切换标签时，重置底部导航栏为显示状态
        if (_currentTabIndex != 0) {
          _bottomBarAnimationValue = 0.0;
        }
      });
    }
  }

  // 初始化聊天服务
  void _initializeChatService() {
    if (_userInfo != null && !_isChatInitialized) {
      try {
        // 创建用户角色
        _selectedCharacter = CharacterRole(
          id: _userInfo!['username'],
          name: _userInfo!['nickname'] ?? _userInfo!['username'] ?? '我自己',
          description: '以自己的身份进行聊天',
          imageAsset: _userInfo!['userPic'] ?? '',
          color: Colors.purple.shade700,
        );

        // 创建聊天服务
        _chatService = ChatService(
          serverUrl: AppConfig.serverUrl,
          character: _selectedCharacter!,
          onMessageReceived: (message) {
            // 可以添加消息通知逻辑
            setState(() {}); // 刷新UI
          },
          onUsersReceived: (users) {
            setState(() {}); // 刷新UI显示最新的在线用户
          },
          onError: (error) {
            print('聊天连接错误: $error');
          },
        );

        // 连接到聊天服务器
        _chatService!.connect();
        _isChatInitialized = true;

        print('聊天服务初始化成功');
      } catch (e) {
        print('初始化聊天服务出错: $e');
        _isChatInitialized = false;
      }
    }
  }

  // 选择用户聊天
  void _selectCharacterToChat(CharacterRole character) {
    // 跳转到聊天屏幕
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          initialChatCharacter: character, // 传递选中的角色作为初始聊天角色
        ),
      ),
    );
  }

  // 新增动画变化监听函数
  void _handleTabControllerAnimationTick() {
    setState(() {
      // 计算每个标签页的动画位置值（0.0-1.0之间）
      final double animationValue = _tabController.animation!.value;

      // 计算每个标签的激活程度
      _homePosition = _getPositionForIndex(0, animationValue);
      _notificationPosition = _getPositionForIndex(1, animationValue);
      _personPosition = _getPositionForIndex(2, animationValue);
    });
  }

  // 计算特定标签页的激活值
  double _getPositionForIndex(int index, double animationValue) {
    // 计算当前索引与动画值之间的距离
    final double distanceFromCurrentIndex = (index - animationValue).abs();
    // 使用更平滑的曲线函数，采用贝塞尔曲线效果
    if (distanceFromCurrentIndex >= 1.0) {
      return 0.0;
    } else {
      // 使用缓动函数让效果更丝滑
      final double t = 1.0 - distanceFromCurrentIndex;
      // 使用缓入缓出函数: t*t*t*(t*(t*6-15)+10)，这是一个更平滑的Hermite曲线
      return t * t * t * (t * (t * 6 - 15) + 10);
    }
  }

  @override
  void dispose() {
    // 移除所有监听器
    _tabController.animation!.removeListener(_handleTabControllerAnimationTick);
    _tabController.removeListener(_handleTabAnimation);
    _tabController.dispose();
    _bottomBarAnimationController.dispose();

    // 断开聊天连接
    if (_isChatInitialized) {
      _chatService!.disconnect();
    }

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final userInfo = await SharedPrefsUtils.getUserInfo();
      final consentGranted = await SharedPrefsUtils.hasPrivacyConsent();
      final isAndroidPlatform =
          !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

      if (userInfo != null && consentGranted && isAndroidPlatform) {
        Myjpush().initPlatformState(userInfo['username']);
      }

      setState(() {
        _userInfo = userInfo;
        _isLoading = false;
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
      final consentGranted = await SharedPrefsUtils.hasPrivacyConsent();
      final isAndroidPlatform =
          !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

      if (userInfo != null && consentGranted && isAndroidPlatform) {
        Myjpush().initPlatformState(userInfo['username']);
      }

      if (mounted) {
        setState(() {
          _userInfo = userInfo;
        });
      }
    } catch (e) {
      print('刷新用户信息出错: $e');
    }
  }

  void _navigateToSearch() {
    Navigator.push(
      context,
      RouteUtils.slideFromRight(SearchPage()),
    );
  }

  void _navigateToPost() {
    Navigator.push(
      context,
      RouteUtils.slideFromBottom(PostPage(type: "发布", articelData: null)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 定义激活和未激活颜色
    final Color activeColor = Color.fromRGBO(98, 1, 231, 1.00);
    final Color inactiveColor = Colors.grey;

    return Scaffold(
      bottomNavigationBar: ClipRect(
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1.0 - _bottomBarAnimationValue,
          child: Opacity(
            opacity: 1.0 - _bottomBarAnimationValue,
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
                dividerTheme: DividerThemeData(
                  color: Colors.transparent,
                  space: 0,
                  thickness: 0,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    height: 50,
                    child: TabBar(
                      controller: _tabController,
                      onTap: (index) {
                        setState(() {
                          _currentTabIndex = index;
                        });
                      },
                      indicatorColor: Colors.transparent,
                      dividerColor: Colors.transparent,
                      indicator: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.transparent, width: 0),
                        ),
                      ),
                      tabs: [
                        Tab(
                          icon: Stack(
                            children: [
                              // 未激活图标
                              Opacity(
                                opacity: 1.0 - _homePosition,
                                child: SvgPicture.asset(
                                  "lib/assets/icons/home-outline.svg",
                                  height: 25,
                                  width: 25,
                                  colorFilter: ColorFilter.mode(
                                    inactiveColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                              // 激活图标
                              Opacity(
                                opacity: _homePosition,
                                child: SvgPicture.asset(
                                  "lib/assets/icons/home.svg",
                                  height: 25,
                                  width: 25,
                                  colorFilter: ColorFilter.mode(
                                    activeColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          icon: Stack(
                            children: [
                              // 渐变透明度混合两个图标，而不是直接切换
                              Stack(
                                children: [
                                  // 未激活图标
                                  Opacity(
                                    opacity: 1.0 - _notificationPosition,
                                    child: Container(
                                      padding:
                                          EdgeInsets.only(right: 10, top: 4),
                                      child: SvgPicture.asset(
                                        "lib/assets/icons/notifications-outline.svg",
                                        height: 25,
                                        width: 25,
                                        colorFilter: ColorFilter.mode(
                                          inactiveColor,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // 激活图标
                                  Opacity(
                                    opacity: _notificationPosition,
                                    child: Container(
                                      padding:
                                          EdgeInsets.only(right: 10, top: 4),
                                      child: SvgPicture.asset(
                                        "lib/assets/icons/notifications.svg",
                                        height: 25,
                                        width: 25,
                                        colorFilter: ColorFilter.mode(
                                          activeColor,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Consumer<NotificationProvider>(
                                  builder:
                                      (context, notificationProvider, child) {
                                    final count = notificationProvider
                                        .getnotificationcount();
                                    return count > 0
                                        ? Container(
                                            padding: EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                        Tab(
                          icon: Stack(
                            children: [
                              // 未激活图标
                              Opacity(
                                opacity: 1.0 - _personPosition,
                                child: SvgPicture.asset(
                                  "lib/assets/icons/person-outline.svg",
                                  height: 25,
                                  width: 25,
                                  colorFilter: ColorFilter.mode(
                                    inactiveColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                              // 激活图标
                              Opacity(
                                opacity: _personPosition,
                                child: SvgPicture.asset(
                                  "lib/assets/icons/person.svg",
                                  height: 25,
                                  width: 25,
                                  colorFilter: ColorFilter.mode(
                                    activeColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      unselectedLabelColor: Colors.grey,
                      overlayColor:
                          MaterialStateProperty.all(Colors.transparent),
                      unselectedLabelStyle: TextStyle(fontSize: 12),
                      labelStyle: TextStyle(fontSize: 12),
                      labelColor: Color.fromRGBO(111, 107, 204, 1.00),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Text("133323"),
          // Articletest(),
          HomeTab(
            userInfo: _userInfo,
            onSearchPressed: _navigateToSearch,
            onAddPostPressed: _navigateToPost,
            onScrollChanged: _handleHomeScrollChanged,
          ),
          EmailList(),
          MePage(),
        ],
      ),
    );
  }
}
