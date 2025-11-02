import 'package:dio/dio.dart';
import '../utils/mydio.dart';

/// 通知相关API服务
/// 参考 capacitor 项目的 notice.js 实现
class NoticeService {
  /// 获得通知列表
  /// [username] 用户名
  Future<Map<String, dynamic>> getNotifications(String username) async {
    try {
      var response = await HttpClient.dio.get(
        "/user/getnotifications?username=${username}",
      );
      return response.data;
    } catch (e) {
      throw Exception('获取通知列表失败: $e');
    }
  }

  /// 已读某个通知
  /// [receiverId] 接收者ID
  /// [notificationId] 通知ID
  Future<Map<String, dynamic>> readNotification({
    required String receiverId,
    required String notificationId,
  }) async {
    try {
      var response = await HttpClient.dio.post(
        "/user/readsomeonenotification?receiverId=${receiverId}&notificationId=${notificationId}",
      );
      return response.data;
    } catch (e) {
      throw Exception('标记通知已读失败: $e');
    }
  }

  /// 已读所有通知
  /// [receiverId] 接收者ID
  Future<Map<String, dynamic>> readAllNotifications(String receiverId) async {
    try {
      var response = await HttpClient.dio.post(
        "/user/readallnotification?receiverId=${receiverId}",
      );
      return response.data;
    } catch (e) {
      throw Exception('标记所有通知已读失败: $e');
    }
  }

  /// 获得通知个数
  /// [username] 用户名
  Future<Map<String, dynamic>> getNotificationsNumber(String username) async {
    try {
      var response = await HttpClient.dio.get(
        "/user/getnotificationsNumber?username=${username}",
      );
      return response.data;
    } catch (e) {
      throw Exception('获取通知个数失败: $e');
    }
  }
}

