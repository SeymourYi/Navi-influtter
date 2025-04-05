import 'package:dio/dio.dart';
import '../utils/mydio.dart';

class SmsLoginService {
  Future<Map<String, dynamic>> smsLogin(String phone) async {
    print(phone + "AAAAAAAAAAAAAAAAAAAARR");
    try {
      var response = await HttpClient.dio.post(
        "/user/login?username=$phone&phoneNumber=$phone",
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to load articles: $e');
    }
  }
}
