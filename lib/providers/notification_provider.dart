// lib/providers/notification_provider.dart
import 'package:flutter/material.dart';

class NotificationProvider with ChangeNotifier {
  static final NotificationProvider _instance =
      NotificationProvider._internal();

  factory NotificationProvider() {
    return _instance;
  }

  NotificationProvider._internal();

  int notificationcount = 8;
  // 添加新通知
  void addNotification() {
    notificationcount += 1;
    notifyListeners();
  }

  // 标记为已读
  void markAsRead() {
    print("22222222");
    print("object之前${notificationcount}");
    notificationcount -= 1;
    print("object之后${notificationcount}");
    notifyListeners();
  }

  void setnotificationcount(int count) {
    notificationcount = count;
    notifyListeners();
  }

  // 清除所有通知
  void clearAll() {
    notificationcount = 0;
    notifyListeners();
  }

  int getnotificationcount() {
    return notificationcount;
  }
}
