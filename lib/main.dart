import 'package:flutter/material.dart';
import 'package:flutterlearn2/components/articledetail.dart';
import 'package:flutterlearn2/models/like_notification.dart';
import 'package:flutterlearn2/page/Home/home.dart';
import 'package:flutterlearn2/page/Splash/splashpage.dart';
import 'package:flutterlearn2/page/chat/screen/components/friendlist.dart';
import 'package:flutterlearn2/page/login/login.dart';
import 'package:flutterlearn2/page/search/search.dart';
import 'package:flutterlearn2/utils/mydio.dart';
import '../../Store/storeutils.dart';
import 'package:jpush_flutter/jpush_flutter.dart';

void main(List<String> args) async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  await HttpClient.init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // 添加全局 navigatorKey
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // 初始状态设置为0表示正在加载
  var loginstate = 0;
  final JPush jpush = JPush(); // 添加 JPush 实例

  @override
  void initState() {
    super.initState();
    _checkToken();
    initPlatformState();
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

  Future<void> initPlatformState() async {
    try {
      jpush.setup(
        appKey: "37bb58f488aa4f8dd7e43516",
        channel: "flutterlearn2",
        production: false,
        debug: true, //是否打印debug日志
      );

      // 添加通知回调
      jpush.addEventHandler(
        onReceiveNotification: (Map<String, dynamic> message) async {
          print("收到通知: $message");
          // 通知已经由极光SDK自动处理并显示在通知栏
        },
        onOpenNotification: (Map<String, dynamic> message) async {
          print("点击通知: $message");

          // 使用 navigatorKey 进行导航
          MyApp.navigatorKey.currentState?.push(
            PageRouteBuilder(
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      Articledetail(id: "530", autoFocusComment: false),
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
        onReceiveMessage: (Map<String, dynamic> message) async {
          print("收到自定义消息: $message");
        },
        onReceiveNotificationAuthorization: (
          Map<String, dynamic> message,
        ) async {
          print("通知授权状态改变: $message");
        },
      );

      // 申请通知权限
      jpush.applyPushAuthority(
        new NotificationSettingsIOS(sound: true, alert: true, badge: true),
      );

      // 获取注册ID
      jpush.getRegistrationID().then((rid) {
        print("注册成功，极光推送 Registration ID: $rid");
      });
    } catch (e) {
      print("极光推送初始化失败: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: MyApp.navigatorKey, // 添加 navigatorKey
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
