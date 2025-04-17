import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';
import './chat_service.dart';
import '../screen/role_selection_screen.dart';

class StorageService {
  static const String _chatHistoryPrefix = 'chat_history_';
  static const String _recentChatsKey = 'recent_chats';
  static const String _sessionIdKey = 'session_id';

  // 保存私聊会话
  static Future<bool> savePrivateChats(
    String userId,
    Map<String, PrivateChat> chats,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 转换私聊会话为可存储的格式
      final Map<String, dynamic> storedChats = {};
      chats.forEach((chatUserId, chat) {
        // 跳过空会话
        if (chat.messages.isEmpty) return;

        storedChats[chatUserId] = {
          'userId': chat.userId,
          'userName': chat.userName,
          'userRole': chat.userRole,
          'unreadCount': chat.unreadCount,
          'messages': chat.messages.map((msg) => msg.toJson()).toList(),
        };
      });

      // 将数据保存到本地存储
      final String key = '$_chatHistoryPrefix$userId';
      final String jsonData = jsonEncode(storedChats);

      print('保存私聊会话: ${storedChats.length}个会话, 大小: ${jsonData.length}字节');
      return await prefs.setString(key, jsonData);
    } catch (e) {
      print('保存私聊会话失败: $e');
      return false;
    }
  }

  // 加载私聊会话
  static Future<Map<String, PrivateChat>> loadPrivateChats(
    String userId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String key = '$_chatHistoryPrefix$userId';

      if (!prefs.containsKey(key)) {
        print('没有找到用户 $userId 的私聊会话记录');
        return {};
      }

      final String? jsonData = prefs.getString(key);
      if (jsonData == null || jsonData.isEmpty) {
        return {};
      }

      // 解析JSON数据
      final Map<String, dynamic> storedChats = jsonDecode(jsonData);
      final Map<String, PrivateChat> chats = {};

      storedChats.forEach((chatUserId, chatData) {
        // 解析消息列表
        List<ChatMessage> messages = [];
        if (chatData['messages'] != null) {
          for (var msgJson in chatData['messages']) {
            messages.add(ChatMessage.fromJson(msgJson));
          }
        }

        // 创建私聊会话对象
        chats[chatUserId] = PrivateChat(
          userId: chatData['userId'],
          userName: chatData['userName'],
          userRole: chatData['userRole'],
          messages: messages,
          unreadCount: chatData['unreadCount'] ?? 0,
        );
      });

      print('加载私聊会话: ${chats.length}个会话');
      return chats;
    } catch (e) {
      print('加载私聊会话失败: $e');
      return {};
    }
  }

  // 保存会话ID
  static Future<bool> saveSessionId(String userId, String? sessionId) async {
    try {
      if (sessionId == null) return false;

      final prefs = await SharedPreferences.getInstance();
      final Map<String, String> sessionMap =
          prefs.getString(_sessionIdKey) != null
              ? Map<String, String>.from(
                jsonDecode(prefs.getString(_sessionIdKey)!),
              )
              : {};

      sessionMap[userId] = sessionId;
      return await prefs.setString(_sessionIdKey, jsonEncode(sessionMap));
    } catch (e) {
      print('保存会话ID失败: $e');
      return false;
    }
  }

  // 加载会话ID
  static Future<String?> loadSessionId(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonData = prefs.getString(_sessionIdKey);

      if (jsonData == null || jsonData.isEmpty) return null;

      final Map<String, dynamic> sessionMap = jsonDecode(jsonData);
      return sessionMap[userId] as String?;
    } catch (e) {
      print('加载会话ID失败: $e');
      return null;
    }
  }

  // 清除指定用户的所有数据
  static Future<bool> clearUserData(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String key = '$_chatHistoryPrefix$userId';

      // 清除私聊会话
      if (prefs.containsKey(key)) {
        await prefs.remove(key);
      }

      // 清除会话ID
      final String? jsonData = prefs.getString(_sessionIdKey);
      if (jsonData != null && jsonData.isNotEmpty) {
        final Map<String, dynamic> sessionMap = jsonDecode(jsonData);
        if (sessionMap.containsKey(userId)) {
          sessionMap.remove(userId);
          await prefs.setString(_sessionIdKey, jsonEncode(sessionMap));
        }
      }

      return true;
    } catch (e) {
      print('清除用户数据失败: $e');
      return false;
    }
  }
}
