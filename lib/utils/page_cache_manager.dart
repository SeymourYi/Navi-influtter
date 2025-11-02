import 'package:flutter/material.dart';
import '../page/UserInfo/components/userpage.dart';
import '../page/UserInfo/userhome.dart';

/// 页面缓存管理器 - 用于缓存页面实例，避免重复加载
class PageCacheManager {
  static final PageCacheManager _instance = PageCacheManager._internal();
  factory PageCacheManager() => _instance;
  PageCacheManager._internal();

  // 缓存 ProfilePage 实例，key 是 username
  final Map<String, ProfilePage> _profilePageCache = {};
  
  // 缓存 UserHome 实例，key 是 userId
  final Map<String, UserHome> _userHomeCache = {};
  
  // 缓存页面数据，避免重复加载
  final Map<String, Map<String, dynamic>> _profileDataCache = {};
  final Map<String, dynamic> _userHomeDataCache = {};

  /// 获取或创建 ProfilePage 实例
  ProfilePage getProfilePage({String? username}) {
    final key = username ?? 'current_user';
    
    if (!_profilePageCache.containsKey(key)) {
      _profilePageCache[key] = ProfilePage(username: username);
    }
    
    return _profilePageCache[key]!;
  }

  /// 获取或创建 UserHome 实例
  UserHome getUserHome({required String userId}) {
    if (!_userHomeCache.containsKey(userId)) {
      _userHomeCache[userId] = UserHome(userId: userId);
    }
    
    return _userHomeCache[userId]!;
  }

  /// 缓存 ProfilePage 数据
  void cacheProfileData(String key, Map<String, dynamic> data) {
    _profileDataCache[key] = data;
  }

  /// 获取缓存的 ProfilePage 数据
  Map<String, dynamic>? getCachedProfileData(String key) {
    return _profileDataCache[key];
  }

  /// 缓存 UserHome 数据
  void cacheUserHomeData(String userId, dynamic data) {
    _userHomeDataCache[userId] = data;
  }

  /// 获取缓存的 UserHome 数据
  dynamic getCachedUserHomeData(String userId) {
    return _userHomeDataCache[userId];
  }

  /// 清除指定用户的缓存
  void clearProfileCache(String? username) {
    final key = username ?? 'current_user';
    _profilePageCache.remove(key);
    _profileDataCache.remove(key);
  }

  /// 清除指定用户的 UserHome 缓存
  void clearUserHomeCache(String userId) {
    _userHomeCache.remove(userId);
    _userHomeDataCache.remove(userId);
  }

  /// 清除所有缓存
  void clearAllCache() {
    _profilePageCache.clear();
    _userHomeCache.clear();
    _profileDataCache.clear();
    _userHomeDataCache.clear();
  }
}

