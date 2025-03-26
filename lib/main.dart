import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './components/article.dart';

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
  const MyHome({super.key});

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
              onPressed: () {},
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
              Expanded(
                child: UserAccountsDrawerHeader(
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: AssetImage(
                      "lib/assets/images/userpic.jpg",
                    ),
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
              overlayColor: WidgetStatePropertyAll(Colors.transparent),
              unselectedLabelStyle: TextStyle(fontSize: 12),
              labelStyle: TextStyle(fontSize: 12),
              labelColor: const Color.fromARGB(255, 106, 75, 202),
            ),
          ),
        ),
        body: TabBarView(children: [Article(), Text("消息")]),
      ),
    );
  }
}
