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
    String emailId,
    String receiverId,
  ) async {
    try {
      var response = await HttpClient.dio.post(
        "/user/readsomeonenotification?receiverId=${receiverId}&notificationId=${emailId}",
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to read email: $e');
    }
  }

  Future<Map<String, dynamic>> readAllEmail(int userId) async {
    try {
      var response = await HttpClient.dio.post(
        "/user/readallnotification?receiverId=${userId}",
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to read all email: $e');
    }
  }

  Future<Map<String, dynamic>> addemail(
    int senderId,
    int receiverId,
    String type,
    int oldarticleId, {
    int? newArticleId,
  }) async {
    try {
      String url =
          "/user/addemail?senderId=$senderId&receiverId=$receiverId&type=$type&oldarticleId=$oldarticleId";
      if (newArticleId != null) {
        url += "&newArticleId=$newArticleId";
      }

      var response = await HttpClient.dio.get(url);
      return response.data;
    } catch (e) {
      throw Exception('Failed to add email: $e');
    }
  }

  Future<Map<String, dynamic>> getEmailNumber(int userId) async {
    try {
      var response = await HttpClient.dio.get(
        "/user/getnotificationsNumber?username=${userId}",
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to get email number: $e');
    }
  }
}

//readallEmail
