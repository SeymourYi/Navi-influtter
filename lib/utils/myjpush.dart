import 'package:flutter/material.dart';
import 'package:Navi/components/articledetail.dart';
import 'package:Navi/main.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:Navi/page/chat/screen/chat_screen.dart';
import 'package:Navi/page/chat/screen/privtschatcreen.dart';
import 'package:Navi/api/userAPI.dart';

class Myjpush {
  final JPush jpush = JPush(); // 添加 JPush 实例
  final UserService userService = UserService(); // 添加用户服务实例

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
          print("-----------  VB---------------------");
          print(message.entries);
          print("--------------BV------------------");

          try {
            // 解析通知中的extras数据
            if (message.containsKey('extras') && message['extras'] is Map) {
              var extras = message['extras'];

              // 进一步解析EXTRA字段中的数据
              if (extras.containsKey('cn.jpush.android.EXTRA') &&
                  extras['cn.jpush.android.EXTRA'] is Map) {
                var extraData = extras['cn.jpush.android.EXTRA'];

                // 检查是否是聊天消息并获取senderId
                if (extraData.containsKey('messageType') &&
                    extraData['messageType'] == 'chat' &&
                    extraData.containsKey('senderId')) {
                  String senderId = extraData['senderId'].toString();
                  print("检测到聊天通知，发送者ID: $senderId");

                  // 通过senderId获取用户信息
                  Map<String, dynamic> userInfoResponse = await userService
                      .getsomeUserinfo(senderId);

                  if (userInfoResponse.containsKey('data') &&
                      userInfoResponse['data'] != null) {
                    var userData = userInfoResponse['data'];
                    print("获取到用户信息: $userData");

                    // 导航到私聊界面
                    // 使用MyApp中定义的NavigatorKey
                    if (MyApp.NavigatorKey.currentContext != null) {
                      Navigator.push(
                        MyApp.NavigatorKey.currentContext!,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  PrivtsChatScreen(character: userData),
                        ),
                      );
                    } else {
                      print("无法获取当前上下文，无法导航到私聊界面");
                    }
                  } else {
                    print("获取用户信息失败: $userInfoResponse");
                  }
                }
              }
            }
          } catch (e) {
            print("处理点击通知出错: $e");
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
