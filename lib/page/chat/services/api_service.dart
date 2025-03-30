import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ApiService {
  static Future<bool> testConnection() async {
    try {
      final response = await http
          .get(Uri.parse('${AppConfig.httpUrl}/api/status'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == 'online';
      }
      return false;
    } catch (e) {
      print('连接测试错误: $e');
      return false;
    }
  }
}
