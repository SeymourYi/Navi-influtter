// import 'package:Navi/page/Email/emailList.dart';
// import 'package:Navi/page/chat/screen/chat_screen.dart';
// import 'package:Navi/providers/notification_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:provider/provider.dart';
// import 'package:Navi/Store/storeutils.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:app_settings/app_settings.dart';
// import 'package:Navi/page/chat/screen/recent_chats_screen.dart';
// import 'package:Navi/page/chat/services/chat_service.dart';
// import 'package:Navi/page/chat/models/chat_message.dart';
// import 'package:Navi/page/chat/config/app_config.dart';
// import 'package:Navi/page/search/search.dart';
// import 'package:Navi/page/post/post.dart';
// import 'package:Navi/page/UserInfo/components/userpage.dart';
// import 'package:Navi/page/Setting/settings.dart';
// import 'package:Navi/page/edit/editpage.dart';
// import 'package:Navi/page/friends/friendspage.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:Navi/api/emailAPI.dart';

// class EmailService {
//   // 仅作为引用占位符，实际实现应该在emailAPI.dart中
// }

// // 添加PersistentDrawer
// class PersistentDrawer extends StatefulWidget {
//   final Map<String, dynamic>? userInfo;
//   final VoidCallback onRefreshUserInfo;

//   const PersistentDrawer({
//     Key? key,
//     required this.userInfo,
//     required this.onRefreshUserInfo,
//   }) : super(key: key);

//   @override
//   State<PersistentDrawer> createState() => _PersistentDrawerState();
// }

// class _PersistentDrawerState extends State<PersistentDrawer> {
//   late CachedNetworkImageProvider? _backgroundImageProvider;
//   late CachedNetworkImageProvider? _avatarImageProvider;
//   String number = '';

//   @override
//   void initState() {
//     super.initState();
//     _initImageProviders();
//   }

//   @override
//   void didUpdateWidget(PersistentDrawer oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.userInfo != widget.userInfo) {
//       _initImageProviders();
//     }
//   }

//   EmailService service = EmailService();
//   void _initImageProviders() async {
//     if (widget.userInfo != null) {
//       if (widget.userInfo!['bgImg'].isNotEmpty) {
//         _backgroundImageProvider = CachedNetworkImageProvider(
//           widget.userInfo!['bgImg'],
//           maxWidth: 800,
//         );
//       } else {
//         _backgroundImageProvider = null;
//       }

//       if (widget.userInfo!['userPic'].isNotEmpty) {
//         _avatarImageProvider = CachedNetworkImageProvider(
//           widget.userInfo!['userPic'],
//           maxWidth: 200,
//         );
//       } else {
//         _avatarImageProvider = null;
//       }
//     } else {
//       _backgroundImageProvider = null;
//       _avatarImageProvider = null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       backgroundColor: Colors.white,
//       child: Column(
//         children: [
//           // 顶部用户信息区域
//           Container(
//             color: Colors.white,
//             padding: EdgeInsets.only(
//               top: MediaQuery.of(context).padding.top + 16,
//               bottom: 16,
//               left: 16,
//               right: 16,
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // 头像和关闭按钮
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     CircleAvatar(
//                       radius: 20,
//                       backgroundImage:
//                           widget.userInfo != null &&
//                                   widget.userInfo!['userPic'].isNotEmpty
//                               ? _avatarImageProvider
//                               : AssetImage("lib/assets/images/userpic.jpg")
//                                   as ImageProvider,
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 16),
//                 // 用户名和ID
//                 Text(
//                   widget.userInfo != null
//                       ? widget.userInfo!['nickname']
//                       : "加载中...",
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: "Inter-Regular",
//                     color: Colors.black,
//                   ),
//                 ),
//                 SizedBox(height: 2),
//                 Text(
//                   widget.userInfo != null
//                       ? "@${widget.userInfo!['username']}"
//                       : "@加载中...",
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 15,
//                     fontFamily: "Inter-Regular",
//                   ),
//                 ),
//                 SizedBox(height: 16),
//                 // 关注信息
//                 Row(
//                   children: [
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.pop(context);
//                         Navigator.push(
//                           context,
//                           PageRouteBuilder(
//                             pageBuilder:
//                                 (context, animation, secondaryAnimation) =>
//                                     FriendsList(),
//                             transitionsBuilder: (
//                               context,
//                               animation,
//                               secondaryAnimation,
//                               child,
//                             ) {
//                               const begin = Offset(1.0, 0.0);
//                               const end = Offset.zero;
//                               const curve = Curves.ease;
//                               var tween = Tween(
//                                 begin: begin,
//                                 end: end,
//                               ).chain(CurveTween(curve: curve));
//                               return SlideTransition(
//                                 position: animation.drive(tween),
//                                 child: child,
//                               );
//                             },
//                           ),
//                         );
//                       },
//                       child: RichText(
//                         text: TextSpan(
//                           children: [
//                             TextSpan(
//                               text: "20 ",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 14,
//                                 color: Colors.black,
//                               ),
//                             ),
//                             TextSpan(
//                               text: "关注中",
//                               style: TextStyle(
//                                 color: Colors.grey[600],
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 16),
//                     RichText(
//                       text: TextSpan(
//                         children: [
//                           TextSpan(
//                             text: "30 ",
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 14,
//                               color: Colors.black,
//                             ),
//                           ),
//                           TextSpan(
//                             text: "粉丝",
//                             style: TextStyle(
//                               color: Colors.grey[600],
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           Divider(
//             height: 1,
//             thickness: 0.5,
//             color: Colors.grey.withOpacity(0.2),
//           ),
//           // 菜单区域
//           Expanded(
//             child: ListView(
//               padding: EdgeInsets.zero,
//               children: [
//                 _buildTwitterMenuItem(
//                   title: "个人信息",
//                   icon: Icons.person_outline,
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.push(
//                       context,
//                       PageRouteBuilder(
//                         pageBuilder:
//                             (context, animation, secondaryAnimation) =>
//                                 ProfilePage(),
//                         transitionsBuilder: (
//                           context,
//                           animation,
//                           secondaryAnimation,
//                           child,
//                         ) {
//                           const begin = Offset(1.0, 0.0);
//                           const end = Offset.zero;
//                           const curve = Curves.ease;
//                           var tween = Tween(
//                             begin: begin,
//                             end: end,
//                           ).chain(CurveTween(curve: curve));
//                           return SlideTransition(
//                             position: animation.drive(tween),
//                             child: child,
//                           );
//                         },
//                       ),
//                     );
//                   },
//                 ),
//                 _buildTwitterMenuItem(
//                   title: "关注列表",
//                   icon: Icons.people_outline,
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.push(
//                       context,
//                       PageRouteBuilder(
//                         pageBuilder:
//                             (context, animation, secondaryAnimation) =>
//                                 FriendsList(),
//                         transitionsBuilder: (
//                           context,
//                           animation,
//                           secondaryAnimation,
//                           child,
//                         ) {
//                           const begin = Offset(1.0, 0.0);
//                           const end = Offset.zero;
//                           const curve = Curves.ease;
//                           var tween = Tween(
//                             begin: begin,
//                             end: end,
//                           ).chain(CurveTween(curve: curve));
//                           return SlideTransition(
//                             position: animation.drive(tween),
//                             child: child,
//                           );
//                         },
//                       ),
//                     );
//                   },
//                 ),
//                 _buildTwitterMenuItem(
//                   title: "编辑个人资料",
//                   icon: Icons.edit_outlined,
//                   onTap: () async {
//                     Navigator.pop(context);
//                     final result = await Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const EditProfilePage(),
//                       ),
//                     );
//                     if (result == true || result == null) {
//                       widget.onRefreshUserInfo();
//                     }
//                   },
//                 ),
//                 _buildTwitterMenuItem(
//                   title: "设置",
//                   icon: Icons.settings_outlined,
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => settings()),
//                     );
//                   },
//                 ),

//                 Divider(
//                   height: 1,
//                   thickness: 0.5,
//                   color: Colors.grey.withOpacity(0.2),
//                 ),
//                 _buildTwitterMenuItem(
//                   title: "关于Navi",
//                   icon: Icons.info_outline,
//                   onTap: () {
//                     Navigator.pop(context);
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTwitterMenuItem({
//     required String title,
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         child: Row(
//           children: [
//             Icon(
//               icon,
//               size: 24,
//               color: const Color.fromARGB(255, 126, 121, 211),
//             ),
//             SizedBox(width: 16),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.black,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class Home extends StatefulWidget {
//   const Home({super.key});

//   @override
//   State<Home> createState() => _HomeState();
// }

// class _HomeState extends State<Home> with TickerProviderStateMixin {
//   late AnimationController _animationController;
//   final ScrollController _scrollController = ScrollController();
//   final double scrowThreshold = 50;
//   double courrtpostion = 0;
//   int _currentTabIndex = 0;
//   double _homePosition = 0.0;
//   double _chatPosition = 0.0;
//   double _peoplePosition = 0.0;
//   double _notificationPosition = 0.0;
//   final Color activeColor = Color.fromRGBO(98, 1, 231, 1.00);
//   final Color inactiveColor = Colors.grey;
//   late TabController _tabController;

//   // 添加用户信息相关变量
//   Map<String, dynamic>? _userInfo;
//   bool _isLoading = true;

//   // 添加聊天相关变量
//   ChatService? _chatService;
//   bool _isChatInitialized = false;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);

//     _animationController = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 200),
//     );
//     _scrollController.addListener(scrolllistener);

//     // 修改监听方式，添加动画监听
//     _homePosition = 1.0;
//     _tabController.addListener(_handleTabAnimation);
//     _tabController.animation!.addListener(_handleTabControllerAnimationTick);
//     _loadUserInfo();
//     _getnotifitionlison();
//   }

//   void _getnotifitionlison() {
//     _checkAndRequestNotificationPermission();
//   }

//   Future<void> _checkAndRequestNotificationPermission() async {
//     try {
//       // 检查通知权限状态
//       final status = await Permission.notification.status;

//       if (status.isDenied || status.isPermanentlyDenied) {
//         // 如果权限被拒绝，显示对话框提示用户
//         if (mounted) {
//           showDialog(
//             context: context,
//             builder: (BuildContext context) {
//               return AlertDialog(
//                 title: Text('开启通知权限'),
//                 content: Text('为了及时接收私信消息，请允许Navi发送通知'),
//                 actions: [
//                   TextButton(
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                     },
//                     child: Text('稍后再说'),
//                   ),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color.fromARGB(255, 126, 121, 211),
//                     ),
//                     onPressed: () async {
//                       Navigator.of(context).pop();
//                       // 打开应用设置页面，让用户手动开启权限
//                       await openAppSettings();
//                     },
//                     child: Text('去设置'),
//                   ),
//                 ],
//               );
//             },
//           );
//         }
//       } else if (status.isLimited) {
//         // 权限有限，可能需要进一步处理
//         print('通知权限受限');
//       } else if (status.isGranted) {
//         // 已授予权限，可以进行后续操作
//         print('已获得通知权限');
//       }
//     } catch (e) {
//       print('检查通知权限出错: $e');
//     }
//   }

//   // 新增动画监听函数
//   void _handleTabAnimation() {
//     if (_tabController.indexIsChanging) {
//       setState(() {
//         _currentTabIndex = _tabController.index;
//       });

//       // 当切换到聊天标签页时，确保聊天服务已初始化
//       if (_currentTabIndex == 1 && !_isChatInitialized) {
//         _initializeChatService();
//       }
//     }
//   }

//   // 初始化聊天服务
//   void _initializeChatService() {
//     // 暂时注释掉，等待正确配置CharacterRole
//     /*
//     if (_userInfo != null && !_isChatInitialized) {
//       try {
//         // 创建聊天服务
//         _chatService = ChatService(
//           serverUrl: AppConfig.serverUrl,
//           character: null, // 临时设为null，实际使用需要正确的CharacterRole对象
//           onMessageReceived: (message) {
//             // 可以添加消息通知逻辑
//             setState(() {}); // 刷新UI
//           },
//           onUsersReceived: (users) {
//             setState(() {}); // 刷新UI显示最新的在线用户
//           },
//           onError: (error) {
//             print('聊天连接错误: $error');
//           },
//         );

//         // 连接到聊天服务器
//         _chatService!.connect();
//         _isChatInitialized = true;

//         print('聊天服务初始化成功');
//       } catch (e) {
//         print('初始化聊天服务出错: $e');
//         _isChatInitialized = false;
//       }
//     }
//     */
//   }

//   // 选择用户聊天
//   void _selectCharacterToChat(dynamic character) {
//     // 跳转到聊天屏幕
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder:
//             (context) => ChatScreen(
//               initialChatCharacter: character, // 传递选中的角色作为初始聊天角色
//             ),
//       ),
//     );
//   }

//   // 新增动画变化监听函数
//   void _handleTabControllerAnimationTick() {
//     setState(() {
//       // 计算每个标签页的动画位置值（0.0-1.0之间）
//       final double animationValue = _tabController.animation!.value;

//       // 计算每个标签的激活程度
//       _homePosition = _getPositionForIndex(0, animationValue);
//       _chatPosition = _getPositionForIndex(1, animationValue);
//       _peoplePosition = _getPositionForIndex(2, animationValue);
//       _notificationPosition = _getPositionForIndex(3, animationValue);
//     });
//   }

//   // 计算特定标签页的激活值
//   double _getPositionForIndex(int index, double animationValue) {
//     // 计算当前索引与动画值之间的距离
//     final double distanceFromCurrentIndex = (index - animationValue).abs();
//     // 使用更平滑的曲线函数，采用贝塞尔曲线效果
//     if (distanceFromCurrentIndex >= 1.0) {
//       return 0.0;
//     } else {
//       // 使用缓动函数让效果更丝滑
//       final double t = 1.0 - distanceFromCurrentIndex;
//       // 使用缓入缓出函数: t*t*t*(t*(t*6-15)+10)，这是一个更平滑的Hermite曲线
//       return t * t * t * (t * (t * 6 - 15) + 10);
//     }
//   }

//   Future<void> _loadUserInfo() async {
//     try {
//       // 使用Store中的工具获取用户信息
//       final userInfo = await SharedPrefsUtils.getUserInfo();
//       print(userInfo);
//       print("VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV");
//       // Myjpush().initPlatformState(userInfo!['username']);
//       setState(() {
//         _userInfo = userInfo;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       print('加载用户信息出错: $e');
//     }
//   }

//   Future<void> _refreshUserInfo() async {
//     try {
//       final userInfo = await SharedPrefsUtils.getUserInfo();
//       // Myjpush().initPlatformState(userInfo!['username']);
//       if (mounted) {
//         setState(() {
//           _userInfo = userInfo;
//         });
//       }
//     } catch (e) {
//       print('刷新用户信息出错: $e');
//     }
//   }

//   void _navigateToSearch() {
//     Navigator.push(
//       context,
//       PageRouteBuilder(
//         pageBuilder: (context, animation, secondaryAnimation) => SearchPage(),
//         transitionsBuilder: (context, animation, secondaryAnimation, child) {
//           const begin = Offset(1.0, 0.0);
//           const end = Offset.zero;
//           const curve = Curves.ease;
//           var tween = Tween(
//             begin: begin,
//             end: end,
//           ).chain(CurveTween(curve: curve));
//           return SlideTransition(
//             position: animation.drive(tween),
//             child: child,
//           );
//         },
//       ),
//     );
//   }

//   void _navigateToPost() {
//     Navigator.push(
//       context,
//       PageRouteBuilder(
//         pageBuilder:
//             (context, animation, secondaryAnimation) =>
//                 PostPage(type: "发布", articelData: null),
//         transitionsBuilder: (context, animation, secondaryAnimation, child) {
//           const begin = Offset(0.0, 1.0);
//           const end = Offset.zero;
//           const curve = Curves.ease;
//           var tween = Tween(
//             begin: begin,
//             end: end,
//           ).chain(CurveTween(curve: curve));
//           return SlideTransition(
//             position: animation.drive(tween),
//             child: child,
//           );
//         },
//       ),
//     );
//   }

//   void scrolllistener() {
//     final nowposition = _scrollController.position.pixels;

//     if (courrtpostion > nowposition + scrowThreshold) {
//       scrowdown();
//       //每次滑动后更新初始位置
//       courrtpostion = nowposition;
//     }
//     if (courrtpostion < nowposition - scrowThreshold) {
//       scrowerup();
//       //每次滑动后更新初始位置
//       courrtpostion = nowposition;
//     }
//   }

//   void scrowerup() {
//     _animationController.forward();
//   }

//   void scrowdown() {
//     _animationController.reverse();
//   }

//   @override
//   void dispose() {
//     // 移除所有监听器
//     _tabController.animation!.removeListener(_handleTabControllerAnimationTick);
//     _tabController.removeListener(_handleTabAnimation);
//     _tabController.dispose();
//     _animationController.dispose();
//     _scrollController.dispose();

//     // 断开聊天连接
//     if (_isChatInitialized && _chatService != null) {
//       _chatService!.disconnect();
//     }

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBody: true,
//       drawer:
//           _isLoading
//               ? Drawer(child: Center(child: CircularProgressIndicator()))
//               : PersistentDrawer(
//                 userInfo: _userInfo,
//                 onRefreshUserInfo: _refreshUserInfo,
//               ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           CustomScrollView(
//             controller: _scrollController,
//             slivers: [
//               SliverAppBar(
//                 title: const Text("Inter Regular 字体测试"),
//                 centerTitle: true,
//                 toolbarHeight:
//                     kToolbarHeight * (1 - _animationController.value * 0.9),
//                 floating: true,
//                 snap: true,
//                 leading: IconButton(
//                   onPressed: () {
//                     Scaffold.of(context).openDrawer();
//                   },
//                   icon:
//                       _userInfo != null && _userInfo!['userPic'] != null
//                           ? Container(
//                             width: 28,
//                             height: 28,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               image: DecorationImage(
//                                 image: NetworkImage(_userInfo!['userPic']),
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                           )
//                           : Icon(Icons.person),
//                 ),
//                 actions: [
//                   IconButton(
//                     onPressed: _navigateToSearch,
//                     icon: SvgPicture.asset(
//                       "lib/assets/icons/adduser.svg",
//                       height: 20,
//                       width: 20,
//                     ),
//                   ),
//                 ],
//               ),
//               SliverList(
//                 delegate: SliverChildBuilderDelegate((contex, index) {
//                   return Text("${index}");
//                 }, childCount: 1000),
//               ),
//             ],
//           ),
//           Center(child: CircularProgressIndicator()),
//           ChatScreen(),
//           EmailList(),
//         ],
//       ),
//       floatingActionButton: AnimatedBuilder(
//         animation: _animationController,
//         builder: (context, child) {
//           return Transform.translate(
//             offset: Offset(0, 100 * _animationController.value),
//             child: Transform.scale(
//               scale: 1 - 1 * _animationController.value,
//               child: Opacity(
//                 opacity: 1.0 - _animationController.value,
//                 child: FloatingActionButton(
//                   onPressed: _navigateToPost,
//                   backgroundColor: Color.fromRGBO(98, 1, 231, 1.00),
//                   shape: CircleBorder(),
//                   child: SvgPicture.asset(
//                     "lib/assets/icons/postbuttonicon.svg",
//                     width: 24,
//                     height: 24,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//       bottomNavigationBar: AnimatedBuilder(
//         animation: _animationController,
//         builder: (context, child) {
//           return Transform.translate(
//             offset: Offset(0, 100 * _animationController.value),
//             child: Transform.scale(
//               scale: 1 - 1 * _animationController.value,
//               child: Opacity(
//                 opacity: 1.0 - _animationController.value,
//                 child: Theme(
//                   data: Theme.of(context).copyWith(
//                     dividerColor: Colors.transparent,
//                     dividerTheme: DividerThemeData(
//                       color: Colors.transparent,
//                       space: 0,
//                       thickness: 0,
//                     ),
//                   ),
//                   child: SizedBox(
//                     height: 50,
//                     child: TabBar(
//                       controller: _tabController,
//                       onTap: (index) {
//                         setState(() {
//                           _currentTabIndex = index;
//                         });
//                       },
//                       indicatorColor: Colors.transparent,
//                       dividerColor: Colors.transparent,
//                       indicator: const BoxDecoration(
//                         border: Border(
//                           top: BorderSide(color: Colors.transparent, width: 0),
//                         ),
//                       ),
//                       tabs: [
//                         Tab(
//                           icon: Stack(
//                             children: [
//                               // 未激活图标
//                               Opacity(
//                                 opacity: 1.0 - _homePosition,
//                                 child: SvgPicture.asset(
//                                   "lib/assets/icons/home-outline.svg",
//                                   height: 25,
//                                   width: 25,
//                                   colorFilter: ColorFilter.mode(
//                                     inactiveColor,
//                                     BlendMode.srcIn,
//                                   ),
//                                 ),
//                               ),
//                               // 激活图标
//                               Opacity(
//                                 opacity: _homePosition,
//                                 child: SvgPicture.asset(
//                                   "lib/assets/icons/home.svg",
//                                   height: 25,
//                                   width: 25,
//                                   colorFilter: ColorFilter.mode(
//                                     activeColor,
//                                     BlendMode.srcIn,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Tab(
//                           icon: Stack(
//                             children: [
//                               // 未激活图标
//                               Opacity(
//                                 opacity: 1.0 - _chatPosition,
//                                 child: SvgPicture.asset(
//                                   "lib/assets/icons/chatbubble-ellipses-outline.svg",
//                                   height: 25,
//                                   width: 25,
//                                   colorFilter: ColorFilter.mode(
//                                     inactiveColor,
//                                     BlendMode.srcIn,
//                                   ),
//                                 ),
//                               ),
//                               // 激活图标
//                               Opacity(
//                                 opacity: _chatPosition,
//                                 child: SvgPicture.asset(
//                                   "lib/assets/icons/chatbubble-ellipses.svg",
//                                   height: 25,
//                                   width: 25,
//                                   colorFilter: ColorFilter.mode(
//                                     activeColor,
//                                     BlendMode.srcIn,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Tab(
//                           icon: Stack(
//                             children: [
//                               // 未激活图标
//                               Opacity(
//                                 opacity: 1.0 - _peoplePosition,
//                                 child: SvgPicture.asset(
//                                   "lib/assets/icons/people-outline.svg",
//                                   height: 25,
//                                   width: 25,
//                                   colorFilter: ColorFilter.mode(
//                                     inactiveColor,
//                                     BlendMode.srcIn,
//                                   ),
//                                 ),
//                               ),
//                               // 激活图标
//                               Opacity(
//                                 opacity: _peoplePosition,
//                                 child: SvgPicture.asset(
//                                   "lib/assets/icons/people.svg",
//                                   height: 25,
//                                   width: 25,
//                                   colorFilter: ColorFilter.mode(
//                                     activeColor,
//                                     BlendMode.srcIn,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Tab(
//                           icon: Stack(
//                             children: [
//                               // 渐变透明度混合两个图标，而不是直接切换
//                               Stack(
//                                 children: [
//                                   // 未激活图标
//                                   Opacity(
//                                     opacity: 1.0 - _notificationPosition,
//                                     child: Container(
//                                       padding: EdgeInsets.only(
//                                         right: 10,
//                                         top: 4,
//                                       ),
//                                       child: SvgPicture.asset(
//                                         "lib/assets/icons/notifications-outline.svg",
//                                         height: 25,
//                                         width: 25,
//                                         colorFilter: ColorFilter.mode(
//                                           inactiveColor,
//                                           BlendMode.srcIn,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   // 激活图标
//                                   Opacity(
//                                     opacity: _notificationPosition,
//                                     child: Container(
//                                       padding: EdgeInsets.only(
//                                         right: 10,
//                                         top: 4,
//                                       ),
//                                       child: SvgPicture.asset(
//                                         "lib/assets/icons/notifications.svg",
//                                         height: 25,
//                                         width: 25,
//                                         colorFilter: ColorFilter.mode(
//                                           activeColor,
//                                           BlendMode.srcIn,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               Positioned(
//                                 right: 0,
//                                 top: 0,
//                                 child: Consumer<NotificationProvider>(
//                                   builder: (
//                                     context,
//                                     notificationProvider,
//                                     child,
//                                   ) {
//                                     final count =
//                                         notificationProvider
//                                             .getnotificationcount();
//                                     return count > 0
//                                         ? Container(
//                                           padding: EdgeInsets.all(2),
//                                           decoration: BoxDecoration(
//                                             color: Colors.red,
//                                             borderRadius: BorderRadius.circular(
//                                               8,
//                                             ),
//                                           ),
//                                           constraints: BoxConstraints(
//                                             minWidth: 16,
//                                             minHeight: 16,
//                                           ),
//                                           child: Text(
//                                             count.toString(),
//                                             style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 10,
//                                             ),
//                                             textAlign: TextAlign.center,
//                                           ),
//                                         )
//                                         : SizedBox.shrink();
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                       unselectedLabelColor: Colors.grey,
//                       overlayColor: MaterialStateProperty.all(
//                         Colors.transparent,
//                       ),
//                       unselectedLabelStyle: TextStyle(fontSize: 12),
//                       labelStyle: TextStyle(fontSize: 12),
//                       labelColor: Color.fromRGBO(111, 107, 204, 1.00),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:Navi/api/emailAPI.dart';
import 'package:Navi/page/Email/components/infopage.dart';
import 'package:Navi/page/Email/emailList.dart';
import 'package:Navi/page/Home/components/things.dart';
import 'package:Navi/page/UserInfo/userhomemain.dart';
import 'package:Navi/page/chat/screen/recent_chats_screen.dart';
import 'package:Navi/providers/notification_provider.dart';
import 'package:Navi/test/article/articletest.dart';
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
          preferredSize: Size.fromHeight(0),
          child: Container(color: Colors.transparent, height: 0),
        ),
      ),
      body: things(),
      floatingActionButton: FloatingActionButton(
        onPressed: onAddPostPressed,
        backgroundColor: Color.fromRGBO(98, 1, 231, 1.00),
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

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _userInfo;
  bool _isLoading = true;
  PersistentDrawer? _persistentDrawer;
  int _currentTabIndex = 0;
  late TabController _tabController;
  // 添加动画值监听的变量
  double _homePosition = 0.0;
  double _chatPosition = 0.0;
  double _peoplePosition = 0.0;
  double _notificationPosition = 0.0;
  double _personPosition = 0.0;

  // 添加聊天相关变量
  ChatService? _chatService;
  CharacterRole? _selectedCharacter;
  bool _isChatInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _tabController = TabController(length: 4, vsync: this);

    // 修改监听方式，添加动画监听
    _homePosition = 1.0;
    _tabController.addListener(_handleTabAnimation);
    _tabController.animation!.addListener(_handleTabControllerAnimationTick);
    _getnotifitionlison();
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
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('开启通知权限'),
                content: Text('为了及时接收私信消息，请允许Navi发送通知'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('稍后再说'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 126, 121, 211),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      // 打开应用设置页面，让用户手动开启权限
                      await openAppSettings();
                    },
                    child: Text('去设置'),
                  ),
                ],
              );
            },
          );
        }
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
      });

      // 当切换到聊天标签页时，确保聊天服务已初始化
      if (_currentTabIndex == 1 && !_isChatInitialized) {
        _initializeChatService();
      }
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
        builder:
            (context) => ChatScreen(
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
      _chatPosition = _getPositionForIndex(1, animationValue);
      _peoplePosition = _getPositionForIndex(2, animationValue);
      _notificationPosition = _getPositionForIndex(3, animationValue);
      _personPosition = _getPositionForIndex(4, animationValue);
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

    // 定义激活和未激活颜色
    final Color activeColor = Color.fromRGBO(98, 1, 231, 1.00);
    final Color inactiveColor = Colors.grey;

    return Scaffold(
      drawer:
          _isLoading
              ? Drawer(child: Center(child: CircularProgressIndicator()))
              : _persistentDrawer,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          dividerTheme: DividerThemeData(
            color: Colors.transparent,
            space: 0,
            thickness: 0,
          ),
        ),
        child: SizedBox(
          height: 50,
          child: TabBar(
            controller: _tabController,
            onTap: (index) {
              setState(() {
                _currentTabIndex = index;
              });

              // 当切换到聊天标签页时，确保聊天服务已初始化
              if (_currentTabIndex == 1 && !_isChatInitialized) {
                _initializeChatService();
              }
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
                    // 未激活图标
                    Opacity(
                      opacity: 1.0 - _chatPosition,
                      child: SvgPicture.asset(
                        "lib/assets/icons/chatbubble-ellipses-outline.svg",
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
                      opacity: _chatPosition,
                      child: SvgPicture.asset(
                        "lib/assets/icons/chatbubble-ellipses.svg",
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
                    // 未激活图标
                    Opacity(
                      opacity: 1.0 - _peoplePosition,
                      child: SvgPicture.asset(
                        "lib/assets/icons/people-outline.svg",
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
                      opacity: _peoplePosition,
                      child: SvgPicture.asset(
                        "lib/assets/icons/people.svg",
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
                            padding: EdgeInsets.only(right: 10, top: 4),
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
                            padding: EdgeInsets.only(right: 10, top: 4),
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
              // Tab(
              //   icon: Stack(
              //     children: [
              //       // 未激活图标
              //       Opacity(
              //         opacity: 1.0 - _personPosition,
              //         child: SvgPicture.asset(
              //           "lib/assets/icons/person-outline.svg",
              //           height: 25,
              //           width: 25,
              //           colorFilter: ColorFilter.mode(
              //             inactiveColor,
              //             BlendMode.srcIn,
              //           ),
              //         ),
              //       ),
              //       // 激活图标
              //       Opacity(
              //         opacity: _personPosition,
              //         child: SvgPicture.asset(
              //           "lib/assets/icons/person.svg",
              //           height: 25,
              //           width: 25,
              //           colorFilter: ColorFilter.mode(
              //             activeColor,
              //             BlendMode.srcIn,
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
            unselectedLabelColor: Colors.grey,
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            unselectedLabelStyle: TextStyle(fontSize: 12),
            labelStyle: TextStyle(fontSize: 12),
            labelColor: Color.fromRGBO(111, 107, 204, 1.00),
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
          ),
          _isChatInitialized && _selectedCharacter != null
              ? RecentChatsScreen(
                chatService: _chatService!,
                currentCharacter: _selectedCharacter!,
                onChatSelected: _selectCharacterToChat,
              )
              : Center(child: CircularProgressIndicator()),
          ChatScreen(),
          EmailList(),
          // UserHomeMain(),
        ],
      ),
    );
  }
}
