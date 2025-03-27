import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterlearn2/components/like_notification_list.dart';
import 'package:flutterlearn2/models/like_notification.dart';
import 'package:flutterlearn2/page/UserInfo/components/userpage.dart';
import 'package:flutterlearn2/page/edit/editpage.dart';
import 'package:flutterlearn2/page/friends/friendspage.dart';
import 'package:flutterlearn2/test/components/articledetail.dart';
import './components/article.dart';
import './page/post/post.dart';
import './page/friends/friendspage.dart';
import './page/search/search.dart';

void main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Navi",
      home: MyHome(),
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 255, 255, 255),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(backgroundColor: Colors.white),
      ),
    );
  }
}

class MyHome extends StatelessWidget {
  // 移除 const 关键字
  MyHome({super.key});

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
  Widget build(BuildContext context) {
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
        drawer: Drawer(
          backgroundColor: Colors.white,
          child: ListView(
            padding: EdgeInsets.all(0),
            children: [
              UserAccountsDrawerHeader(
                currentAccountPicture: CircleAvatar(
                  backgroundImage: AssetImage("lib/assets/images/userpic.jpg"),
                ),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://img-s.msn.cn/tenant/amp/entityid/AA1yQEG5?w=0&h=0&q=60&m=6&f=jpg&u=t',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                accountName: Text(
                  "霸气小肥鹅",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Inter-Regular",
                    color: Colors.black,
                  ),
                ),
                accountEmail: Text(
                  "@1111",
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
                          (context, animation, secondaryAnimation) =>
                              FriendsList(
                                friends: [
                                  Friend(
                                    name: '霸气小肥鹅',
                                    username: 'baqixiaofeie',
                                    avatarUrl: 'assets/images/user_avatar.png',
                                    bio: '独立开发者 | Flutter爱好者 | 分享开发经验和生活点滴',
                                    isFollowing: true,
                                    isVerified: true,
                                    followers: 12800,
                                    following: 542,
                                    showStats: true,
                                  ),
                                  Friend(
                                    name: 'Flutter官方',
                                    username: 'flutter',
                                    avatarUrl: 'assets/images/flutter_logo.png',
                                    bio: 'Flutter官方账号，分享Flutter最新动态和开发技巧',
                                    isVerified: true,
                                    followers: 250000,
                                    following: 120,
                                    showStats: true,
                                  ),
                                ],
                              ),
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
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfilePage(),
                    ),
                  );
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
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent, // 透明背景
                        elevation: 0, // 去除阴影
                      ),
                      onPressed: () {
                        // 按钮点击事件
                      },
                      icon: Icon(
                        Icons.exit_to_app, // 退出图标
                        color: Colors.red,
                        size: 20, // 图标大小
                      ), // 图标
                      label: Text(
                        "退出",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 117, 113, 206),
                          fontFamily: "Inter-Regular",
                        ),
                      ), // 文本
                    ),
                    Expanded(child: SizedBox.shrink()),
                    TextButton(
                      onPressed: () {
                        // Logout action
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
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.grey[300]!, // 线条颜色
                width: 1.0, // 线条宽度
              ),
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
            SingleChildScrollView(child: Column(children: [Article()])),
            LikeNotificationList(
              notifications: notifications,
              onFollowUser: (user) {
                // 处理关注逻辑
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
