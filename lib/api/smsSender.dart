import 'package:dio/dio.dart';
import '../utils/mydio.dart';

class SmsSenderService {
  Future<Map<String, dynamic>> smsSender(String phone, String code) async {
    try {
      var response = await HttpClient.dio.post(
        "/user/SmsSender",
        data: {"phoneNumber": phone, "code": code},
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to load articles: $e');
    }
  }
}
