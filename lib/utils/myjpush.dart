import 'package:flutter/material.dart';
import 'package:flutterlearn2/components/articledetail.dart';
import 'package:flutterlearn2/main.dart';
import 'package:jpush_flutter/jpush_flutter.dart';

class Myjpush {
  final JPush jpush = JPush(); // 添加 JPush 实例
  Future<void> initPlatformState(String username) async {
    try {
      jpush.setup(
        appKey: "37bb58f488aa4f8dd7e43516",
        channel: "flutterlearn2",
        production: false,
        debug: true, //是否打印debug日志
      );
      jpush.getRegistrationID().then((rid) {
        print("极光推送RegistrationID: $rid");
        // 将rid发送到你的服务器，与用户ID关联
      });

      // 设置别名（通常使用用户ID）
      jpush.setAlias(username).then((map) {
        print("设置别名结果: $map");
      });

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
}
