import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Navi/Store/storeutils.dart';
import 'package:Navi/utils/route_utils.dart';
import 'package:Navi/page/Setting/settings.dart';
import 'package:Navi/page/friends/friendspage.dart';
import 'package:Navi/page/UserInfo/components/userpage.dart';
import 'package:Navi/page/post/post.dart';

class MePage extends StatefulWidget {
  const MePage({super.key});

  @override
  State<MePage> createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  Map<String, dynamic>? _userInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final userInfo = await SharedPrefsUtils.getUserInfo();
      setState(() {
        _userInfo = userInfo;
        _isLoading = false;
      });
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
      // 假设日期格式为 "2025-10-26" 或其他格式
      DateTime date = DateTime.parse(dateString);
      return '${date.year}年${date.month}月${date.day}日加入';
    } catch (e) {
      return dateString;
    }
  }

  void _navigateToMyPosts() async {
    if (_userInfo == null) return;
    final username = _userInfo!['username'];
    if (username == null) return;

    Navigator.push(
      context,
      RouteUtils.slideFromRight(ProfilePage(username: username)),
    );
  }

  void _navigateToFollowing() {
    Navigator.push(
      context,
      RouteUtils.slideFromRight(const FriendsList()),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      RouteUtils.slideFromRight(const settings()),
    );
  }

  void _navigateToPost() {
    Navigator.push(
      context,
      RouteUtils.slideFromBottom(PostPage(type: "发布", articelData: null)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color.fromRGBO(111, 107, 204, 1.00);
    final Color pinkColor = const Color(0xFFFFB6C1);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
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
                            child: _userInfo != null &&
                                    _userInfo!['bgImg'] != null &&
                                    _userInfo!['bgImg'].toString().isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: _userInfo!['bgImg'],
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
                          // Profile Picture overlapping banner - 方形圆角
                          Positioned(
                            left: 16,
                            bottom: -40,
                            child: GestureDetector(
                              onTap: () {
                                // 可以添加查看大图的功能
                              },
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
                                  child: _userInfo != null &&
                                          _userInfo!['userPic'] != null &&
                                          _userInfo!['userPic']
                                              .toString()
                                              .isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: _userInfo!['userPic'],
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
                                    _userInfo?['nickname'] ?? '用户',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                if (_userInfo != null &&
                                    _userInfo!['isVerified'] == true)
                                  Icon(
                                    Icons.verified,
                                    size: 18,
                                    color: Color(0xFF6201E7),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _userInfo != null
                                  ? "@${_userInfo!['username'] ?? ''}"
                                  : "@用户",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // 个人简介
                            if (_userInfo != null &&
                                _userInfo!['bio'] != null &&
                                _userInfo!['bio'].toString().isNotEmpty)
                              Text(
                                _userInfo!['bio'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            if (_userInfo != null &&
                                _userInfo!['bio'] != null &&
                                _userInfo!['bio'].toString().isNotEmpty)
                              const SizedBox(height: 12),

                            // 地点和加入日期
                            Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: [
                                if (_userInfo != null &&
                                    _userInfo!['location'] != null &&
                                    _userInfo!['location'].toString().isNotEmpty)
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
                                        _userInfo!['location'],
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                if (_userInfo != null &&
                                    _userInfo!['profession'] != null &&
                                    _userInfo!['profession'].toString().isNotEmpty)
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
                                        _userInfo!['profession'],
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                if (_userInfo != null &&
                                    _userInfo!['createTime'] != null)
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
                                        _formatDate(_userInfo!['createTime']),
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
                              '我的帖子',
                              Icons.article_outlined,
                              _navigateToMyPosts,
                            ),
                            _buildMenuOption(
                              '关注列表',
                              Icons.people_outline,
                              _navigateToFollowing,
                            ),
                            _buildMenuOption(
                              '设置',
                              Icons.settings_outlined,
                              _navigateToSettings,
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
