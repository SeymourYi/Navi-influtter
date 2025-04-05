import 'package:dio/dio.dart';
import '../utils/mydio.dart';

class UserRegisterService {
  Future<Map<String, dynamic>> register(String username) async {
    try {
      var response = await HttpClient.dio.post(
        "/user/Deregister?username=${username}",
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to load articles: $e');
    }
  }
}
