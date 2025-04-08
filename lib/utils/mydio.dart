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
          return handler.next(response);
        },
        onError: (DioException e, handler) {
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
