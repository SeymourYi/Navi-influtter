import 'package:dio/dio.dart';
import '../utils/mydio.dart';

class GetFriendListService {
  Future<Map<String, dynamic>> GetFriendList(String username) async {
    try {
      var response = await HttpClient.dio.get(
        "/user/myfriend?username=${username}",
        // "/user/myfriend?username=1111",
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to load articles: $e');
    }
  }
}
