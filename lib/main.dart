import 'package:flutter/material.dart';
import 'package:flutterlearn2/page/Home/home.dart';
import 'package:flutterlearn2/page/Splash/splashpage.dart';
import 'package:flutterlearn2/page/login/login.dart';
import 'package:flutterlearn2/utils/mydio.dart';
import '../../Store/storeutils.dart';

void main(List<String> args) async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  await HttpClient.init();
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
    // 使用正确的_tokenKey常量与getToken方法
    var token = await SharedPrefsUtils.getToken();
    // 使用isLoggedIn方法检查登录状态
    var isLoggedIn = await SharedPrefsUtils.isLoggedIn();

    setState(() {
      if (token == null || token.isEmpty || !isLoggedIn) {
        // 未登录
        loginstate = 2; // 到登录页面
      } else {
        // 已登录
        loginstate = 1; // 到主页
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Navi",
      home: SplashScreen(
        x: loginstate, // 这里可以动态传入1或2
        aScreen: MyHome(), // 主页
        bScreen: LoginPage(), // 登录页面
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
