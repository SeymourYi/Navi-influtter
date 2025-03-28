import 'package:dio/dio.dart';
import '../utils/mydio.dart';

class UserService {
  Future<Map<String, dynamic>> getUserinfo() async {
    try {
      var response = await HttpClient.dio.get("/user/userinfo");
      return response.data;
    } catch (e) {
      throw Exception('Failed to load articles: $e');
    }
  }
}
