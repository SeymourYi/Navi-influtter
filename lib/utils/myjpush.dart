import 'package:flutter/material.dart';
import 'package:Navi/components/articledetail.dart';
import 'package:Navi/main.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:Navi/page/chat/screen/chat_screen.dart';
import 'package:Navi/page/chat/screen/privtschatcreen.dart';
import 'package:Navi/api/userAPI.dart';
import 'package:Navi/api/getfriendlist.dart'; // 导入好友列表服务
import 'package:Navi/Store/storeutils.dart'; // 导入SharedPrefsUtils
import 'package:flutter/services.dart';

class Myjpush {
  final JPush jpush = JPush(); // 添加 JPush 实例
  final UserService userService = UserService(); // 添加用户服务实例
  final GetFriendListService friendListService =
      GetFriendListService(); // 添加好友列表服务

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
      print("初始化极光推送...");

      // 首先设置事件处理器，这样可以捕获所有事件
      jpush.addEventHandler(
        onReceiveNotification: (Map<String, dynamic> message) async {
          print("收到通知: $message");

          // 收到通知时可以播放提示音或进行其他处理
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
          print("----------- 通知数据 -----------");
          print(message.entries);
          print("--------------------------------");

          // 调用统一处理方法
          await processNotificationMessage(message);
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

      // 然后进行JPush初始化
      jpush.setup(
        appKey: "8b8a7faafb8dbceffabf0bdb",
        channel: "Navi",
        production: false,
        debug: true, //是否打印debug日志
      );

      // 申请通知权限
      jpush.applyPushAuthority(
        new NotificationSettingsIOS(sound: true, alert: true, badge: true),
      );

      // 获取注册ID
      jpush.getRegistrationID().then((rid) {
        print("极光推送RegistrationID: $rid");
        // 将rid发送到你的服务器，与用户ID关联
      });

      // 设置别名（通常使用用户ID）
      jpush.setAlias(username).then((map) {
        print("设置别名结果: $map");
      });

      // 处理可能从通知启动的应用
      // 延迟一点执行，确保JPush已完全初始化
      Future.delayed(Duration(milliseconds: 500), () {
        checkLaunchNotification();
      });

      print("极光推送初始化完成");
    } catch (e) {
      print("极光推送初始化失败: $e");
    }
  }

  // 检查应用是否是从通知启动的
  Future<void> checkLaunchNotification() async {
    try {
      print("检查应用是否从通知启动...");
      final dynamic launchDetails = await jpush.getLaunchAppNotification();
      print("启动数据: $launchDetails");

      if (launchDetails != null && launchDetails is Map<String, dynamic>) {
        print("应用从通知启动，启动数据: $launchDetails");

        // 延迟处理以确保应用已完全初始化
        Future.delayed(Duration(seconds: 1), () {
          processNotificationMessage(launchDetails);
        });
      } else {
        print("未检测到标准极光通知启动数据，尝试检查是否是从JNotifyActivity启动");

        // 尝试从Android原生获取启动意图数据
        await _getInitialNotificationFromNative(retryCount: 0);
      }
    } catch (e) {
      print("获取启动通知数据错误: $e");
      // 出错时也尝试从原生获取
      await _getInitialNotificationFromNative(retryCount: 0);
    }
  }

  // 尝试从Android原生获取启动通知数据
  Future<void> _getInitialNotificationFromNative({int retryCount = 0}) async {
    try {
      print("尝试从原生获取启动通知数据，尝试次数: $retryCount");
      const MethodChannel channel = MethodChannel('com.Navi/push_notification');
      final Map<dynamic, dynamic>? notificationData = await channel
          .invokeMethod('getInitialNotification');

      if (notificationData != null && notificationData.isNotEmpty) {
        print("从原生获取到启动通知数据: $notificationData");
        Future.delayed(Duration(milliseconds: 500), () {
          processNotificationMessage(
            Map<String, dynamic>.from(notificationData),
          );
        });
        return;
      } else if (retryCount < 3) {
        // 如果没有数据但尝试次数小于3，延迟后重试
        print("未获取到通知数据，将在500ms后重试 (${retryCount + 1}/3)");
        Future.delayed(Duration(milliseconds: 500), () {
          _getInitialNotificationFromNative(retryCount: retryCount + 1);
        });
      } else {
        print("重试3次后仍无法检测到通知启动数据");
      }
    } catch (e) {
      print("尝试获取原生启动数据出错: $e");
      if (retryCount < 3) {
        // 出错但尝试次数小于3，延迟后重试
        print("获取数据出错，将在500ms后重试 (${retryCount + 1}/3)");
        Future.delayed(Duration(milliseconds: 500), () {
          _getInitialNotificationFromNative(retryCount: retryCount + 1);
        });
      }
    }
  }

  // 统一处理通知消息的方法
  Future<void> processNotificationMessage(Map<String, dynamic> message) async {
    try {
      print("处理通知消息: $message");

      // 将完整消息结构打印出来以便调试
      message.forEach((key, value) {
        print("通知字段 $key: $value");
        if (value is Map) {
          value.forEach((k, v) {
            print("  子字段 $k: $v");
          });
        }
      });

      // 检查直接映射的字段
      String? senderId;

      // 方法1: 直接检查senderId字段
      if (message.containsKey('senderId')) {
        senderId = message['senderId'].toString();
        print("方法1: 直接找到发送者ID: $senderId");
        await navigateToChatScreen(senderId);
        return;
      }

      // 方法2: 检查username字段
      if (message.containsKey('username')) {
        senderId = message['username'].toString();
        print("方法2: 从username找到发送者ID: $senderId");
        await navigateToChatScreen(senderId);
        return;
      }

      // 方法3: 检查极光推送标准字段
      if (message.containsKey('cn.jpush.android.EXTRA')) {
        var extra = message['cn.jpush.android.EXTRA'];
        if (extra is Map) {
          // Map形式
          if (extra.containsKey('senderId')) {
            senderId = extra['senderId'].toString();
            print("方法3.1: 从EXTRA Map中找到发送者ID: $senderId");
            await navigateToChatScreen(senderId);
            return;
          } else if (extra.containsKey('username')) {
            senderId = extra['username'].toString();
            print("方法3.2: 从EXTRA Map中找到username: $senderId");
            await navigateToChatScreen(senderId);
            return;
          }
        } else if (extra is String) {
          // 尝试从字符串中提取
          final senderIdRegex = RegExp(r'"senderId"\s*:\s*"([^"]+)"');
          final match = senderIdRegex.firstMatch(extra);
          if (match != null && match.groupCount >= 1) {
            senderId = match.group(1);
            if (senderId != null) {
              print("方法3.3: 从EXTRA字符串中提取到发送者ID: $senderId");
              await navigateToChatScreen(senderId);
              return;
            }
          }

          // 尝试提取username
          final usernameRegex = RegExp(r'"username"\s*:\s*"([^"]+)"');
          final usernameMatch = usernameRegex.firstMatch(extra);
          if (usernameMatch != null && usernameMatch.groupCount >= 1) {
            senderId = usernameMatch.group(1);
            if (senderId != null) {
              print("方法3.4: 从EXTRA字符串中提取到username: $senderId");
              await navigateToChatScreen(senderId);
              return;
            }
          }
        }
      }

      // 方法4: 检查MESSAGE字段
      if (message.containsKey('cn.jpush.android.MESSAGE')) {
        var msg = message['cn.jpush.android.MESSAGE'];
        if (msg is String) {
          // 从字符串中提取
          final senderIdRegex = RegExp(r'"senderId"\s*:\s*"([^"]+)"');
          final match = senderIdRegex.firstMatch(msg);
          if (match != null && match.groupCount >= 1) {
            senderId = match.group(1);
            if (senderId != null) {
              print("方法4.1: 从MESSAGE字符串中提取到发送者ID: $senderId");
              await navigateToChatScreen(senderId);
              return;
            }
          }

          // 尝试提取username
          final usernameRegex = RegExp(r'"username"\s*:\s*"([^"]+)"');
          final usernameMatch = usernameRegex.firstMatch(msg);
          if (usernameMatch != null && usernameMatch.groupCount >= 1) {
            senderId = usernameMatch.group(1);
            if (senderId != null) {
              print("方法4.2: 从MESSAGE字符串中提取到username: $senderId");
              await navigateToChatScreen(senderId);
              return;
            }
          }
        }
      }

      // 方法5: 从通知内容中提取发送者名称
      if (message.containsKey('cn.jpush.android.ALERT')) {
        String alertContent = message['cn.jpush.android.ALERT'].toString();
        print("检测到极光通知内容: $alertContent");

        // 尝试从消息内容中提取发送者名称
        final senderNameRegex = RegExp(r'^([^:：]+)[：:]');
        final match = senderNameRegex.firstMatch(alertContent);
        if (match != null && match.groupCount >= 1) {
          final senderName = match.group(1)?.trim();
          if (senderName != null && senderName.isNotEmpty) {
            print("方法5: 从通知内容解析到可能的发送者名称: $senderName");

            // 获取用户名
            String currentUsername = await SharedPrefsUtils.getUsername() ?? "";
            Map<String, dynamic> response =
                await friendListService.GetFriendList(currentUsername);

            if (response.containsKey('data') &&
                response['data'] != null &&
                response['data'] is List &&
                response['data'].isNotEmpty) {
              List<dynamic> friends = response['data'];

              // 查找匹配的好友
              for (var friend in friends) {
                if ((friend['nickname'] != null &&
                        friend['nickname'].toString().toLowerCase().contains(
                          senderName.toLowerCase(),
                        )) ||
                    (friend['username'] != null &&
                        friend['username'].toString().toLowerCase().contains(
                          senderName.toLowerCase(),
                        ))) {
                  print("找到匹配的好友: ${friend['username']}");

                  // 导航到私聊界面
                  if (MyApp.NavigatorKey.currentContext != null) {
                    Navigator.push(
                      MyApp.NavigatorKey.currentContext!,
                      MaterialPageRoute(
                        builder:
                            (context) => PrivtsChatScreen(character: friend),
                      ),
                    );
                    return;
                  }
                }
              }
            }
          }
        }
      }

      // 方法6: 从通知标题中提取发送者名称
      if (message.containsKey('cn.jpush.android.NOTIFICATION_CONTENT_TITLE')) {
        String title =
            message['cn.jpush.android.NOTIFICATION_CONTENT_TITLE'].toString();
        print("检测到极光通知标题: $title");

        // 获取用户名
        String currentUsername = await SharedPrefsUtils.getUsername() ?? "";
        Map<String, dynamic> response = await friendListService.GetFriendList(
          currentUsername,
        );

        if (response.containsKey('data') &&
            response['data'] != null &&
            response['data'] is List &&
            response['data'].isNotEmpty) {
          List<dynamic> friends = response['data'];

          // 查找匹配的好友
          for (var friend in friends) {
            if ((friend['nickname'] != null &&
                    friend['nickname'].toString().toLowerCase() ==
                        title.toLowerCase()) ||
                (friend['username'] != null &&
                    friend['username'].toString().toLowerCase() ==
                        title.toLowerCase())) {
              print("方法6: 从标题匹配到好友: ${friend['username']}");

              // 导航到私聊界面
              if (MyApp.NavigatorKey.currentContext != null) {
                Navigator.push(
                  MyApp.NavigatorKey.currentContext!,
                  MaterialPageRoute(
                    builder: (context) => PrivtsChatScreen(character: friend),
                  ),
                );
                return;
              }
            }
          }
        }
      }

      // 无法识别聊天发送者，跳转到聊天列表页面
      print("无法识别聊天发送者，跳转到聊天列表页面");
      if (MyApp.NavigatorKey.currentContext != null) {
        Navigator.push(
          MyApp.NavigatorKey.currentContext!,
          MaterialPageRoute(builder: (context) => ChatScreen()),
        );
      }
    } catch (e) {
      print("处理通知消息出错: $e");
    }
  }

  // 导航到聊天界面
  Future<void> navigateToChatScreen(String senderId) async {
    print("准备导航到与用户 $senderId 的聊天界面");

    try {
      // 获取用户信息
      Map<String, dynamic> userInfoResponse = await userService.getsomeUserinfo(
        senderId,
      );

      if (userInfoResponse.containsKey('data') &&
          userInfoResponse['data'] != null) {
        var userData = userInfoResponse['data'];
        print("获取到用户信息: ${userData['nickname'] ?? userData['username']}");

        // 导航到私聊界面
        if (MyApp.NavigatorKey.currentContext != null) {
          Navigator.push(
            MyApp.NavigatorKey.currentContext!,
            MaterialPageRoute(
              builder: (context) => PrivtsChatScreen(character: userData),
            ),
          );
        } else {
          print("无法获取当前上下文，无法导航到私聊界面");
        }
      } else {
        print("获取用户信息失败: $userInfoResponse");
      }
    } catch (e) {
      print("导航到聊天界面错误: $e");
    }
  }
}
