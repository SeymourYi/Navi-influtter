// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: "Navi",
//       theme: ThemeData(
//         primaryColor: Color.fromARGB(255, 255, 255, 255),
//         scaffoldBackgroundColor: Colors.white,
//         appBarTheme: AppBarTheme(
//           backgroundColor: Colors.white,
//           elevation: 0,
//           iconTheme: IconThemeData(color: Color(0xFF6000E6)),
//         ),
//       ),
//       home: MyHome(),
//     );
//   }
// }

// class MyHome extends StatelessWidget {
//   const MyHome({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(
//             "Navi",
//             style: TextStyle(
//               color: Color(0xFFCDC7E8),
//               fontSize: 24,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           centerTitle: true,
//           actions: [
//             IconButton(
//               onPressed: () {},
//               icon: SvgPicture.asset(
//                 "lib/assets/icons/adduser.svg",
//                 width: 20,
//                 height: 20,
//               ),
//             ),
//           ],
//           leading: Builder(
//             builder:
//                 (context) => IconButton(
//                   onPressed: () {
//                     Scaffold.of(context).openDrawer();
//                   },
//                   icon: Container(
//                     padding: EdgeInsetsDirectional.only(top: 10),
//                     child: CircleAvatar(
//                       backgroundImage: AssetImage(
//                         "lib/assets/images/userpic.jpg",
//                       ),
//                       radius: 15,
//                     ),
//                   ),
//                 ),
//           ),
//           bottom: PreferredSize(
//             preferredSize: Size.fromHeight(1.0),
//             child: Container(
//               color: Color.fromARGB(255, 255, 255, 255),
//               height: 0.3,
//             ),
//           ),
//         ),
//         bottomNavigationBar: Container(
//           child: SizedBox(
//             height: 50,
//             child: TabBar(
//               overlayColor: MaterialStateProperty.all(Colors.transparent),
//               indicatorColor: Colors.transparent,
//               labelColor: Color(0xFF6000E6),
//               unselectedLabelColor: Colors.grey,
//               labelStyle: TextStyle(fontSize: 12),
//               unselectedLabelStyle: TextStyle(fontSize: 12),
//               tabs: [
//                 Tab(icon: Icon(Icons.home, size: 20), text: "主界面"),
//                 Tab(icon: Icon(Icons.email, size: 20), text: "消息"),
//               ],
//             ),
//           ),
//         ),
//         body: TabBarView(
//           children: [Center(child: Text("主界面内容")), Center(child: Text("消息内容"))],
//         ),

//         drawer: Theme(
//           data: Theme.of(context).copyWith(
//             dividerTheme: DividerThemeData(
//               color: const Color.fromARGB(0, 164, 20, 20),
//             ),
//           ),
//           child: Drawer(
//             backgroundColor: Colors.white,
//             child: Column(
//               children: [
//                 Expanded(
//                   child: ListView(
//                     padding: EdgeInsets.zero,
//                     children: [
//                       UserAccountsDrawerHeader(
//                         margin: EdgeInsets.zero,
//                         decoration: BoxDecoration(color: Colors.white),
//                         accountName: Text(
//                           "霸气小肥鹅",
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             fontFamily: "Inter-Regular",
//                             color: Colors.black,
//                           ),
//                         ),
//                         accountEmail: Text(
//                           "@11111",
//                           style: TextStyle(color: Colors.grey[600]),
//                         ),
//                         currentAccountPicture: CircleAvatar(
//                           radius: 30,
//                           backgroundImage: NetworkImage(
//                             'https://pica.zhimg.com/v2-3baea6dfc2d4acacd74b5e907278f94a_1440w.jpg',
//                           ),
//                         ),
//                       ),
//                       ListTile(
//                         leading: SvgPicture.asset(
//                           'lib/assets/icons/Profile.svg',
//                           width: 24,
//                           height: 24,
//                         ),
//                         title: Text(
//                           "个人资料",
//                           style: TextStyle(
//                             color: const Color.fromARGB(255, 117, 113, 206),
//                             fontFamily: "Inter-Regular",
//                           ),
//                         ),
//                         onTap: () {},
//                       ),
//                       ListTile(
//                         leading: SvgPicture.asset(
//                           'lib/assets/icons/Vector1.svg',
//                           width: 24,
//                           height: 24,
//                         ),
//                         title: Text(
//                           "关注列表",
//                           style: TextStyle(
//                             color: const Color.fromARGB(255, 117, 113, 206),
//                             fontFamily: "Inter-Regular",
//                           ),
//                         ),
//                         onTap: () {},
//                       ),
//                       ListTile(
//                         leading: SvgPicture.asset(
//                           'lib/assets/icons/Vector.svg',
//                           width: 24,
//                           height: 24,
//                         ),
//                         title: Text(
//                           "编辑个人资料",
//                           style: TextStyle(
//                             color: const Color.fromARGB(255, 117, 113, 206),
//                             fontFamily: "Inter-Regular",
//                           ),
//                         ),
//                         onTap: () {},
//                       ),
//                       Divider(height: 1, color: Colors.grey[300]),
//                       ListTile(
//                         leading: SvgPicture.asset(
//                           'lib/assets/icons/information.svg',
//                           width: 24,
//                           height: 24,
//                         ),
//                         title: Text(
//                           "关于Navi",
//                           style: TextStyle(
//                             color: const Color.fromARGB(255, 117, 113, 206),
//                             fontFamily: "Inter-Regular",
//                           ),
//                         ),
//                         onTap: () {},
//                       ),
//                     ],
//                   ),
//                 ),
//                 // Bottom buttons row
//                 Padding(
//                   padding: EdgeInsets.all(16.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       TextButton(
//                         onPressed: () {
//                           // Settings action
//                         },
//                         child: Text(
//                           "退出",
//                           style: TextStyle(
//                             color: const Color.fromARGB(255, 117, 113, 206),
//                             fontFamily: "Inter-Regular",
//                           ),
//                         ),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           // Logout action
//                         },
//                         child: Text(
//                           "设置",
//                           style: TextStyle(
//                             color: const Color.fromARGB(255, 117, 113, 206),
//                             fontFamily: "Inter-Regular",
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
