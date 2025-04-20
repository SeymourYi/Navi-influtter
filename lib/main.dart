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

void main(List<String> args) async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  await HttpClient.init();

  // 确保字体被正确加载 - 使用kIsWeb检查是否在Web平台
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
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

  // 添加一个变量存储可能从通知打开应用时的初始消息数据
  Map<String, dynamic>? initialMessage;

  @override
  void initState() {
    super.initState();
    _checkToken();
    _initPushNotification();
  }

  // 初始化推送通知并处理应用从被杀死状态启动的情况
  Future<void> _initPushNotification() async {
    // 设置监听器处理从被杀死状态启动的情况
    jpush.addEventHandler(
      onReceiveNotification: (Map<String, dynamic> message) async {
        print("收到通知 (前台): $message");
      },
      onOpenNotification: (Map<String, dynamic> message) async {
        print("点击通知 (前台/后台): $message");
        _processNotificationMessage(message);
      },
      // 接收从原生Android端传入的自定义消息
      onReceiveMessage: (Map<String, dynamic> message) async {
        print("收到自定义消息: $message");
      },
      // 检查应用启动参数，查看是否是通过通知启动的应用
      onReceiveNotificationAuthorization: (Map<String, dynamic> message) async {
        print("通知授权状态: $message");
      },
    );

    // 获取初始消息（从被杀死状态通过通知打开应用时）
    try {
      jpush.getRegistrationID().then((rid) {
        print("应用启动, RegistrationID: $rid");
      });

      // 尝试获取初始通知数据
      final dynamic launchDetails = await jpush.getLaunchAppNotification();
      if (launchDetails != null && launchDetails is Map<String, dynamic>) {
        print("应用从通知启动，启动数据: $launchDetails");
        initialMessage = launchDetails;

        // 处理从通知打开的情况 (应用被杀死的情况)
        // 延迟处理以确保应用已完全初始化
        Future.delayed(Duration(seconds: 1), () {
          _processNotificationMessage(initialMessage!);
        });
      }
    } catch (e) {
      print("获取启动通知数据错误: $e");
    }
  }

  // 统一处理通知消息
  void _processNotificationMessage(Map<String, dynamic> message) {
    // 检查是否有附加数据
    try {
      if (message.containsKey('extras') && message['extras'] is Map) {
        var extras = message['extras'];

        // 尝试解析通知类型
        if (extras.containsKey('cn.jpush.android.EXTRA') &&
            extras['cn.jpush.android.EXTRA'] is Map) {
          var extraData = extras['cn.jpush.android.EXTRA'];

          // 根据通知类型导航到不同页面
          if (extraData.containsKey('messageType')) {
            String messageType = extraData['messageType'].toString();

            // 聊天消息类型的通知
            if (messageType == 'chat' && extraData.containsKey('senderId')) {
              String senderId = extraData['senderId'].toString();
              print("处理聊天通知, 发送者ID: $senderId");

              // 导航到聊天页面
              // 先获取发送者信息，然后导航
              SharedPrefsUtils.isLoggedIn().then((isLoggedIn) {
                if (isLoggedIn) {
                  // 这里应该获取用户信息并导航到聊天页面
                  // 示例仅做参考，实际应根据你的应用逻辑调整
                  UserService userService = UserService();
                  userService.getsomeUserinfo(senderId).then((
                    userInfoResponse,
                  ) {
                    if (userInfoResponse.containsKey('data') &&
                        userInfoResponse['data'] != null) {
                      var userData = userInfoResponse['data'];
                      if (MyApp.NavigatorKey.currentState != null) {
                        MyApp.NavigatorKey.currentState!.push(
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    PrivtsChatScreen(character: userData),
                          ),
                        );
                      }
                    }
                  });
                }
              });
            }

            // 其他类型的通知可以在这里扩展处理
          }
        }
      }
    } catch (e) {
      print("处理通知消息出错: $e");
    }
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
