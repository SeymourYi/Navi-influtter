import 'package:dio/dio.dart';
import '../utils/mydio.dart';

class RegisterService {
  Future<Map<String, dynamic>> register(String phone, String password) async {
    try {
      // 生成一个唯一的用户名，这里简单地使用 "user_" 前缀加上时间戳
      String uniqueUsername = "user_${DateTime.now().millisecondsSinceEpoch}";

      var response = await HttpClient.dio.post(
        "/user/register?phoneNumber=${phone}&password=${password}&username=${uniqueUsername}",
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to load articles: $e');
    }
  }
}
