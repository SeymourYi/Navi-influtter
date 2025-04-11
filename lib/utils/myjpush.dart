import 'package:flutter/material.dart';
import 'package:Navi/components/articledetail.dart';
import 'package:Navi/main.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:Navi/page/chat/screen/chat_screen.dart';

class Myjpush {
  final JPush jpush = JPush(); // 添加 JPush 实例

  // 示例方法：发送聊天通知
  Future<void> sendChatNotification({
    required String targetUsername, // 接收通知的用户名
    required String senderUsername, // 发送者用户名
    required String senderNickname, // 发送者昵称
    String? senderAvatar, // 发送者头像
    String? senderBio, // 发送者简介
    required String message, // 消息内容
  }) async {
    // 注意：这个方法仅作为示例，实际应用中聊天通知应由服务端发送
    // 这里仅演示通知的数据格式，实际无法直接从客户端发送给其他用户

    print("模拟发送聊天通知到用户: $targetUsername");
    print("发送者: $senderUsername ($senderNickname)");
    print("消息内容: $message");
    print("通知数据格式示例:");

    // 构建通知数据示例
    Map<String, dynamic> extras = {
      'type': 'chat',
      'username': senderUsername,
      'nickname': senderNickname,
      'userPic': senderAvatar ?? '',
      'bio': senderBio ?? '',
      'message': message,
    };

    print(extras);

    // 在实际应用中，服务端会使用类似格式发送通知
  }

  Future<void> initPlatformState(String username) async {
    try {
      jpush.setup(
        appKey: "8b8a7faafb8dbceffabf0bdb",
        channel: "Navi",
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

          // 收到通知时可以播放提示音或进行其他处理
          // 例如可以在这里更新未读消息数量等
          try {
            if (message.containsKey('extras')) {
              var extras = message['extras'];
              var notificationType = extras['type'] as String?;

              // 收到聊天通知时更新相关UI状态
              if (notificationType == 'chat') {
                // 在这里可以更新聊天列表中的未读消息状态等
              }
            }
          } catch (e) {
            print("处理接收通知出错: $e");
          }
        },
        onOpenNotification: (Map<String, dynamic> message) async {
          print("点击通知: $message");

          // 解析通知类型和参数
          try {
            if (message.containsKey('extras')) {
              var extras = message['extras'];
              var notificationType = extras['type'] as String?;

              // 如果是私聊通知
              if (notificationType == 'chat') {
                var senderUsername = extras['username'] as String?;
                var senderNickname = extras['nickname'] as String?;
                var senderAvatar = extras['userPic'] as String?;
                var senderBio = extras['bio'] as String?;

                if (senderUsername != null && senderNickname != null) {
                  print("跳转到与 $senderNickname 的私聊");

                  // 使用 NavigatorKey 导航到聊天界面
                  final currentContext = MyApp.NavigatorKey.currentContext;
                  if (currentContext != null) {
                    // 查看当前是否已经在聊天界面
                    final currentRoute = ModalRoute.of(currentContext);
                    final isInChatScreen =
                        currentRoute?.settings.name == '/chat' ||
                        currentRoute?.settings.arguments is ChatScreen;

                    if (isInChatScreen) {
                      // TODO: 如果已经在聊天界面，可以尝试找到ChatScreen实例并调用其方法切换聊天对象
                      // 这需要聊天页面提供相应的方法。为简单起见，这里仍然创建新页面
                      print("已经在聊天界面，创建新页面");
                    }

                    MyApp.NavigatorKey.currentState?.push(
                      MaterialPageRoute(
                        settings: RouteSettings(name: '/chat'),
                        builder:
                            (context) => ChatScreen(
                              initialChatUsername: senderUsername,
                              initialChatName: senderNickname,
                              initialChatAvatar: senderAvatar ?? '',
                              initialChatBio: senderBio ?? '',
                            ),
                      ),
                    );
                  }
                  return;
                }
              }
              // 如果是文章通知
              else if (notificationType == 'article') {
                var articleId = extras['articleId'] as String?;

                if (articleId != null) {
                  // 使用 NavigatorKey 导航到文章详情
                  MyApp.NavigatorKey.currentState?.push(
                    MaterialPageRoute(
                      builder: (context) => Articledetail(articleData: null),
                    ),
                  );
                  return;
                }
              }
            }

            // 默认跳转(如果没有匹配到特定类型或信息不完整)
            MyApp.NavigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => Articledetail(articleData: null),
              ),
            );
          } catch (e) {
            print("处理推送通知跳转出错: $e");
            // 发生错误时使用默认跳转
            MyApp.NavigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => Articledetail(articleData: null),
              ),
            );
          }
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
