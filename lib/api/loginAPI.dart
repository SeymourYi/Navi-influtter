import 'package:dio/dio.dart';
import '../utils/mydio.dart';
import 'dart:convert';

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

  // 处理极光一键登录token验证的方法
  Future<Map<String, dynamic>> verifyJVerifyToken(String loginToken) async {
    try {
      // 1. 正确构建认证信息
      final appKey = '8b8a7faafb8dbceffabf0bdb'; // 你的AppKey
      // 尝试使用API DevSecret替代Master Secret
      final masterSecret = 'cbd5388077b22bdadde5e9fd'; // API DevSecret

      // 2. Base64编码认证信息
      final authorization =
          'Basic ${base64Encode(utf8.encode('$appKey:$masterSecret'))}';

      // 3. 打印认证头用于调试
      print('认证头: $authorization');
      print('请求URL: https://api.verification.jpush.cn/v1/web/loginTokenVerify');
      print('请求体: {"loginToken": "$loginToken"}');

      try {
        // 4. 构建正确的请求
        var dio = Dio(); // 使用新的Dio实例避免与应用其他部分冲突
        var response = await dio.post(
          'https://api.verification.jpush.cn/v1/web/loginTokenVerify',
          data: json.encode({"loginToken": loginToken}),
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Authorization': authorization,
            },
            // 5. 修改validateStatus允许接收任何状态码方便调试
            validateStatus: (status) => true,
          ),
        );

        // 6. 打印详细响应内容用于调试
        print('响应状态码: ${response.statusCode}');
        print('响应头: ${response.headers}');
        print('响应体: ${response.data}');
        print('完整响应: $response');

        if (response.statusCode == 200) {
          return response.data;
        } else {
          throw Exception(
            'API调用失败，状态码: ${response.statusCode}, 响应: ${response.data}',
          );
        }
      } catch (e) {
        print('调用极光API出错详情: $e');
        if (e is DioException) {
          print('是DioException错误');
          print('请求: ${e.requestOptions?.uri}');
          print('请求头: ${e.requestOptions?.headers}');
          print('请求数据: ${e.requestOptions?.data}');
          print('响应: ${e.response}');
          print('错误类型: ${e.type}');
          print('错误消息: ${e.message}');
        }
        throw Exception('极光一键登录验证失败: $e');
      }
    } catch (e) {
      print('调用极光API出错: $e');
      throw Exception('极光一键登录验证失败: $e');
    }
  }
}
