import 'package:dio/dio.dart';
import '../utils/mydio.dart';

class SmsLoginService {
  Future<Map<String, dynamic>> smsLogin(String phone) async {
    try {
      var response = await HttpClient.dio.post(
        "/user/login",
        data: {"username": phone, "phoneNumber": phone},
        options: Options(
          contentType: 'application/json',
          headers: {"Content-Type": "application/json"},
        ),
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to load articles: $e');
    }
  }
}
