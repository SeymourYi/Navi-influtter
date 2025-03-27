import 'package:dio/dio.dart';

class HttpClient {
  static const String baseUrl = "http://122.51.93.212:5361";
  static Dio dio = Dio(BaseOptions(baseUrl: baseUrl));
  static void init() {
    // 请求拦截器
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // 添加公共的请求头，如 Authorization
          options.headers["Authorization"] =
              "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJjbGFpbXMiOnsicGhvbmVOdW1iZXIiOiIxOTEzNzA1NjE2NSIsImlkIjoxLCJ1c2VybmFtZSI6IjExMTEifX0.5yWOXiEDh8McMC49fmnczQBbzgmOFm_6hYRwqPwFdAs";

          return handler.next(options);
        },
      ),
    );

    // 返回拦截器
    dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          // 可以在这里对返回的数据进行统一处理
          return handler.next(response..data["data"]);
        },
        onError: (DioException e, handler) {
          // 可以在这里对错误进行统一处理
          return handler.next(e);
        },
      ),
    );
  }
}
