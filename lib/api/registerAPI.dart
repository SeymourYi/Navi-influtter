import 'package:dio/dio.dart';
import '../utils/mydio.dart';

class RegisterService {
  Future<Map<String, dynamic>> register(String phone, String password) async {
    try {
      var response = await HttpClient.dio.post(
        "/user/register?phoneNumber=${phone}&password=${password}",
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to load articles: $e');
    }
  }
}
