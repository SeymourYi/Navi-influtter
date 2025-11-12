import 'package:Navi/Store/storeutils.dart';
import 'package:Navi/api/userAPI.dart';
import 'package:Navi/components/full_screen_image_view.dart';
import 'package:Navi/page/UserInfo/components/userpage.dart';
import 'package:Navi/page/chat/screen/chat_screen.dart';
import 'package:Navi/page/chat/screen/privtschatcreen.dart';
import 'package:Navi/utils/route_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:Navi/utils/image_utils.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key, required this.userId});
  final String userId;

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  dynamic _userinfo = {};
  bool _isLoading = true;
  UserService server = UserService();
  static final Map<String, dynamic> _dataCache = {}; // 静态数据缓存

  /// 从缓存加载用户信息
  void _loadUserInfoFromCache() {
    if (_dataCache.containsKey(widget.userId)) {
      setState(() {
        _userinfo = _dataCache[widget.userId];
        _isLoading = false;
      });
      // 后台刷新数据
      _fetchUserInfo();
      return;
    }
    
    // 缓存中没有数据，正常加载
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    try {
    var res = await server.getsomeUserinfo(widget.userId);
    setState(() {
      _userinfo = res["data"];
        _isLoading = false;
      });
      // 更新缓存
      _dataCache[widget.userId] = res["data"];
    } catch (e) {
      print('加载用户信息出错: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '未知';
    }
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.year}年${date.month}月${date.day}日加入';
    } catch (e) {
      return dateString;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserInfoFromCache(); // 先从缓存加载
  }

  void _navigateToPosts() {
    Navigator.push(
      context,
      RouteUtils.slideFromRight(ProfilePage(username: _userinfo["username"])),
    );
  }

  void _navigateToChat() {
    Navigator.push(
      context,
      RouteUtils.slideFromRight(PrivtsChatScreen(character: _userinfo)),
    );
  }

  void _navigateToFullScreenImage() {
    Navigator.push(
      context,
      RouteUtils.slideFromRight(FullScreenImageView(
        imageUrls: [_userinfo["userPic"] ?? ""],
        initialIndex: 0,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // Profile Header
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner Image
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            height: 150,
                            width: double.infinity,
            decoration: BoxDecoration(
                              color: Colors.grey[200],
                            ),
                            child: _userinfo["bgImg"] != null &&
                                    _userinfo["bgImg"].toString().isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: ImageUrlUtils.optimize(_userinfo["bgImg"]),
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.image,
                                        size: 30,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.green[100]!,
                                          Colors.orange[100]!,
                                          Colors.yellow[100]!,
                                        ],
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.landscape,
                                      size: 30,
                                      color: Colors.grey,
                                    ),
                                  ),
                          ),
                          // 返回按钮 - 左上角
                          SafeArea(
                            child: Positioned(
                              top: 8,
                              left: 8,
                              child: Material(
                                color: Colors.black.withOpacity(0.5),
                                shape: const CircleBorder(),
                                child: InkWell(
                                  onTap: () => Navigator.pop(context),
                                  borderRadius: BorderRadius.circular(20),
                      child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_back,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Profile Picture overlapping banner - 方形圆角
                          Positioned(
                            left: 16,
                            bottom: -40,
                            child: GestureDetector(
                              onTap: _navigateToFullScreenImage,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  width: 65,
                                  height: 65,
                        decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: _userinfo["userPic"] != null &&
                                          _userinfo["userPic"]
                                              .toString()
                                              .isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: ImageUrlUtils.optimize(_userinfo["userPic"]),
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              const CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              const Icon(
                                            Icons.person,
                                            size: 32,
                                            color: Colors.grey,
                                          ),
                                        )
                                      : Container(
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.person,
                                            size: 32,
                                            color: Colors.grey,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // User Info Section - 推特风格
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 50, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 用户名和认证
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _userinfo["nickname"] ?? '用户',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                if (_userinfo["isVerified"] == true)
                                  Icon(
                                    Icons.verified,
                                    size: 18,
                                    color: Color(0xFF6201E7),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "@${_userinfo["username"] ?? ''}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // 个人简介
                            if (_userinfo["bio"] != null &&
                                _userinfo["bio"].toString().isNotEmpty)
                              Text(
                                _userinfo["bio"],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            if (_userinfo["bio"] != null &&
                                _userinfo["bio"].toString().isNotEmpty)
                              const SizedBox(height: 12),

                            // 地点和加入日期
                            Wrap(
                              spacing: 16,
                              runSpacing: 8,
                                children: [
                                if (_userinfo["location"] != null &&
                                    _userinfo["location"].toString().isNotEmpty)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _userinfo["location"],
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                if (_userinfo["profession"] != null &&
                                    _userinfo["profession"].toString().isNotEmpty)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.work_outline,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                  Text(
                                        _userinfo["profession"],
                                    style: TextStyle(
                                          fontSize: 11,
                                      color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                if (_userinfo["createTime"] != null)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                  Text(
                                        _formatDate(_userinfo["createTime"]),
                                    style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Menu Options
                            _buildMenuOption(
                              '贴文',
                              Icons.article_outlined,
                              _navigateToPosts,
                            ),
                            _buildMenuOption(
                              '发消息',
                              Icons.chat_bubble_outline,
                              _navigateToChat,
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMenuOption(
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
                      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
              color: Colors.grey[200]!,
              width: 0.5,
                          ),
                        ),
                          ),
                          child: Row(
                            children: [
                              Icon(
              icon,
                                size: 20,
              color: Colors.grey[700],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: Colors.grey[400],
          ),
          ],
        ),
      ),
    );
  }
}
