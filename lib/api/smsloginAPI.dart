import 'package:dio/dio.dart';
import '../utils/mydio.dart';

class SmsLoginService {
  Future<Map<String, dynamic>> smsLogin(String phone) async {
    try {
      var response = await HttpClient.dio.post(
        "/user/login?username=${phone}",
        // data: {"username": phone, "phoneNumber": phone},
        options: Options(
          contentType: 'application/json; charset=utf-8',
          headers: {"Content-Type": "application/json; charset=utf-8"},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('服务器响应错误: ${response.statusCode}');
      }

      return response.data;
    } on DioException catch (e) {
      print('短信登录错误详情: ${e.toString()}');
      if (e.response != null) {
        print('错误状态码: ${e.response?.statusCode}');
        print('错误数据: ${e.response?.data}');
      }
      throw Exception('短信登录失败: ${e.message}');
    } catch (e) {
      print('其他短信登录错误: $e');
      throw Exception('短信登录失败: $e');
    }
  }
}
