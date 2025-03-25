import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "222",
      theme: ThemeData(primaryColor: Colors.blueAccent),
      home: MyHome(),
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
          title: Text(
            "Navi",
            style: TextStyle(
              color: Colors.blueAccent,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [IconButton(onPressed: () {}, icon: Icon(Icons.search))],
        ),
        bottomNavigationBar: TabBar(
          tabs: [
            Tab(text: "主界面", icon: Icon(Icons.home)),
            Tab(text: "消息", icon: Icon(Icons.email)),
          ],
        ),
        body: TabBarView(children: [Text("12323"), Text("3333")]),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.all(0),
            children: [
              UserAccountsDrawerHeader(
                accountName: Text("ddd"),
                accountEmail: Text("cccc"),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://pica.zhimg.com/v2-3baea6dfc2d4acacd74b5e907278f94a_1440w.jpg',
                  ),
                ),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://wy-static.wenxiaobai.com/aigc-online/delogo_df191513-1459-4102-96bb-42fe03b6b639.webp',
                    ),
                  ),
                ),
              ),
              ListTile(
                title: Text("123"),
                trailing: Icon(Icons.add_a_photo_rounded),
              ),
              ListTile(
                title: Text("123"),
                trailing: Icon(Icons.add_a_photo_rounded),
              ),
              ListTile(
                title: Text("123"),
                trailing: Icon(Icons.add_a_photo_rounded),
              ),
              Divider(),
              ListTile(
                title: Text("123"),
                trailing: Icon(Icons.add_a_photo_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
