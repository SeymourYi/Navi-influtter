import 'package:Navi/page/UserInfo/userhome.dart';
import 'package:Navi/providers/notification_provider.dart';
import 'dart:io'
    if (dart.library.html) 'package:Navi/utils/platform_stub.dart'; // 修改导入方式
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // 添加foundation导入
import 'package:Navi/components/articledetail.dart';
import 'package:Navi/models/like_notification.dart';
import 'package:Navi/page/Home/home.dart';
import 'package:Navi/page/Splash/splashpage.dart';
import 'package:Navi/page/chat/screen/components/friendlist.dart';
import 'package:Navi/page/login/login.dart';
import 'package:Navi/page/search/search.dart';
import 'package:Navi/utils/mydio.dart';
import 'package:Navi/utils/myjpush.dart'; // 导入自定义JPush工具类
import '../../Store/storeutils.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:Navi/api/userAPI.dart'; // 添加UserService的导入
import 'package:Navi/page/chat/screen/privtschatcreen.dart'; // 添加PrivtsChatScreen的导入

// 添加生命周期事件处理类
class LifecycleEventHandler extends WidgetsBindingObserver {
  final AsyncCallback? resumeCallBack;

  LifecycleEventHandler({this.resumeCallBack});

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      if (resumeCallBack != null) {
        await resumeCallBack!();
      }
    }
  }
}

void main(List<String> args) async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  await HttpClient.init();

  // 确保字体被正确加载 - 使用kIsWeb检查是否在Web平台
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    // 启用边缘到边缘模式，让应用内容延伸到系统导航栏下方
    if (Platform.isAndroid) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
      );
    }
    
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => NotificationProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // 添加全局 NavigatorKey
  static final GlobalKey<NavigatorState> NavigatorKey =
      GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // 初始状态设置为0表示正在加载
  var loginstate = 0;
  final JPush jpush = JPush(); // 添加 JPush 实例
  final Myjpush myJPush = Myjpush(); // 创建自定义JPush工具类实例

  @override
  void initState() {
    super.initState();
    _checkToken();
    _setupNotificationDetection();
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

        // 获取用户名，用于JPush别名设置
        SharedPrefsUtils.getUsername().then((username) {
          if (username != null && username.isNotEmpty) {
            // 初始化JPush并设置别名
            myJPush.initPlatformState(username);
          }
        });
      }
    });
  }

  // 设置通知检测，用于捕获从JNotifyActivity启动的情况
  void _setupNotificationDetection() {
    // 监听应用生命周期变化
    WidgetsBinding.instance.addObserver(
      LifecycleEventHandler(
        resumeCallBack: () async {
          print("应用恢复到前台，检查是否从通知启动");
          // 当应用从后台恢复到前台时，检查是否是通过通知启动的
          // 用户点击通知后可能会导致应用从后台恢复
          try {
            // 这里直接调用myJPush中的方法获取最新通知
            final notificationData = await jpush.getLaunchAppNotification();
            if (notificationData != null) {
              print("检测到从通知恢复应用，通知数据: $notificationData");
              if (notificationData is Map<String, dynamic>) {
                // 交由MyJPush类处理
                await myJPush.processNotificationMessage(notificationData);
              }
            }
          } catch (e) {
            print("应用恢复检查通知错误: $e");
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 尝试强制刷新字体缓存 (简化处理)
    if (!kIsWeb && Platform.isWindows) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }

    return MaterialApp(
      navigatorKey: MyApp.NavigatorKey, // 添加 NavigatorKey
      title: "Navi",
      home: SplashScreen(
        x: loginstate, // 这里可以动态传入1或2
        aScreen: MyHome(), // 主页
        // aScreen: UserHome(),
        bScreen: LoginPage(), // 登录页面
        cScreen: Text("JIAAAAAAAAAAAA"),
      ),
      theme: ThemeData(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(backgroundColor: Colors.white),
      ),
    );
  }
}
