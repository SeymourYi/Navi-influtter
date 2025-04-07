import 'package:dio/dio.dart';
import '../utils/mydio.dart';

class EmailService {
  Future<Map<String, dynamic>> getEmailList(int username) async {
    try {
      var response = await HttpClient.dio.get(
        "/user/getnotifications?username=${username}",
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to load articles: $e');
    }
  }

  //redsomeEmail
  Future<Map<String, dynamic>> readsomeonenotification(
    int emailId,
    int senderId,
  ) async {
    try {
      var response = await HttpClient.dio.get(
        "/user/readEmail?receiverId=${emailId}&notificationId=${senderId}",
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to read email: $e');
    }
  }
}

//readallEmail
Future<Map<String, dynamic>> readAllEmail(int userId) async {
  try {
    var response = await HttpClient.dio.get(
      "/user/readallnotification?receiverId=${userId}",
    );
    return response.data;
  } catch (e) {
    throw Exception('Failed to read all email: $e');
  }
}
