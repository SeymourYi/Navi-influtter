import 'package:dio/dio.dart';
import '../utils/mydio.dart';

class LoginService {
  Future<Map<String, dynamic>> Login(String number, String password) async {
    try {
      var response = await HttpClient.dio.post(
        "/user/login?username=${number}&password=${password}",
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to load articles: $e');
    }
  }
}
