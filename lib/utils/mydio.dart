import 'package:dio/dio.dart';
import '../Store/storeutils.dart';

class HttpClient {
  static const String baseUrl = "http://122.51.93.212:5361";
  static late Dio dio;

  static Future<void> init() async {
    dio = Dio(BaseOptions(baseUrl: baseUrl));

    // 请求拦截器
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 添加公共的请求头，如 Authorization
          final token = await SharedPrefsUtils.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers["Authorization"] = token;
            print('添加token: $token'); // 调试日志
          } else {
            print('无token'); // 调试日志
          }
          return handler.next(options);
        },
      ),
    );

    // 返回拦截器
    dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          print('响应状态码: ${response.statusCode}'); // 调试日志
          print('响应数据: ${response.data}'); // 调试日志
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print('请求错误: ${e.message}'); // 调试日志
          print('错误响应: ${e.response?.data}'); // 调试日志
          if (e.response?.statusCode == 401) {
            // token失效，清除本地token
            SharedPrefsUtils.clearToken();
          }
          return handler.next(e);
        },
      ),
    );
  }
}
