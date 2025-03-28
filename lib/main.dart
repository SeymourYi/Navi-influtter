import 'package:flutter/material.dart';
import 'package:flutterlearn2/page/Home/home.dart';
import 'package:flutterlearn2/page/Splash/splashpage.dart';
import 'package:flutterlearn2/page/login/login.dart';
import 'package:flutterlearn2/utils/mydio.dart';
import '../../Store/storeutils.dart';

void main(List<String> args) {
  HttpClient.init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // 初始状态设置为0表示正在加载
  var loginstate = 0;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    var token = await SharedPrefsUtils.getString("token");
    setState(() {
      if (token == '') {
        //未登录
        loginstate = 2;
      } else {
        //已登陆
        loginstate = 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Navi",
      home: SplashScreen(
        x: loginstate, // 这里可以动态传入1或2
        aScreen: MyHome(), // 替换为你的A界面
        bScreen: LoginPage(), // 替换为你的B界面
        cScreen: Text("JIAAAAAAAAAAAA"),
      ),
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 255, 255, 255),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(backgroundColor: Colors.white),
      ),
    );
  }
}
