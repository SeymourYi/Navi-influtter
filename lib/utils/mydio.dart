import 'package:dio/dio.dart';
import '../Store/storeutils.dart';

/// HTTP客户端配置
/// 参考 capacitor 项目的 request.js 和 new_request.js 实现
class HttpClient {
  // static const String baseUrl = "http://122.51.93.212:5361";
  // 使用固定域名，参考 capacitor 项目的配置
  static const String baseUrl = "https://qianxunweimeng.cn";
  // 如果需要使用带端口的版本，可以使用: "https://qianxunweimeng.cn:5361"
  static late Dio dio;

  static Future<void> init() async {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        // 设置超时时间，参考 new_request.js 的 30000ms
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        // 默认请求头，参考 capacitor 项目的配置
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache',
        },
      ),
    );

    // 请求拦截器
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 添加公共的请求头，如 Authorization
          final token = await SharedPrefsUtils.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers["Authorization"] = token;
            print('✅ 已添加Authorization到请求头: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
          } else {
            print('⚠️ 没有找到token');
          }

          // 打印请求信息（调试用）
          print('发送请求 (Dio): ${options.method} ${options.uri}');

          return handler.next(options);
        },
      ),
    );

    // 响应拦截器
    dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          // 打印响应信息（调试用）
          print('响应数据 (Dio): ${response.statusCode} ${response.statusMessage}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          // 打印错误信息（调试用）
          print('响应错误 (Dio): ${e.message}');
          if (e.response != null) {
            print('错误状态码: ${e.response?.statusCode}');
            print('错误数据: ${e.response?.data}');
          }

          // 处理401未授权错误
          if (e.response?.statusCode == 401) {
            // token失效，清除本地token
            SharedPrefsUtils.clearToken();
          }

          // 提供更友好的错误信息（记录在日志中，供调试使用）
          String friendlyMessage = e.message ?? '网络请求失败';
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.sendTimeout) {
            friendlyMessage = '网络连接超时，请检查网络连接';
          } else if (e.type == DioExceptionType.connectionError) {
            friendlyMessage = '网络连接失败，请检查网络连接或服务器状态';
          } else if (e.response?.statusCode == 403) {
            friendlyMessage = '服务器拒绝访问 (403 Forbidden)，可能是权限问题';
          } else if (e.response?.statusCode == 404) {
            friendlyMessage = '请求的资源不存在 (404 Not Found)';
          } else if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
            friendlyMessage = '服务器内部错误，请稍后重试';
          }

          // 记录友好错误提示（供调试使用）
          print('友好错误提示: $friendlyMessage');

          // 直接传递原始异常，上层代码可以通过 e.message 或 e.response 获取详细信息
          return handler.next(e);
        },
      ),
    );
  }
}
