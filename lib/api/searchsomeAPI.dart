import 'package:dio/dio.dart';
import '../utils/mydio.dart';

class SearchSomeService {
  Future<Map<String, dynamic>> SearchSome(String username) async {
    try {
      var response = await HttpClient.dio.get(
        "/user/searchsomeone?username=${username}",
        // "/user/myfriend?username=1111",
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to load articles: $e');
    }
  }
}
