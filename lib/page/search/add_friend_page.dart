import 'package:flutter/material.dart';
import 'package:Navi/Store/storeutils.dart';
import 'package:Navi/api/searchsomeAPI.dart';
import 'package:Navi/page/UserInfo/components/userpage.dart';
import 'package:Navi/api/userAPI.dart';
import 'package:Navi/utils/route_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({Key? key}) : super(key: key);

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchResults = false;
  bool _isLoading = false;
  List<dynamic> _searchResults = [];
  List<dynamic> _recommendedUsers = [];
  Map<String, bool> _friendStatusMap = {};
  String? _currentUsername;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser().then((_) {
      _loadRecommendedUsers();
    });
  }

  Future<void> _loadCurrentUser() async {
    try {
      final userInfo = await SharedPrefsUtils.getUserInfo();
      if (userInfo != null && userInfo['username'] != null) {
        setState(() {
          _currentUsername = userInfo['username'];
        });
      }
    } catch (e) {
      print('加载用户信息失败: $e');
    }
  }

  Future<void> _loadRecommendedUsers() async {
    // TODO: 实现推荐用户API
    // 暂时使用写死的数据
    setState(() {
      _recommendedUsers = [
        {
          'nickname': 'abc',
          'username': '5779217614734525',
          'bio': '这个人很神秘,还没有简介',
          'userPic': '',
        },
        {
          'nickname': '霸气小楼昨夜又东',
          'username': '6038917614657283',
          'bio': '这个人很神秘,还没有简介',
          'userPic': '',
        },
      ];
    });
    
    // 检查推荐用户的关注状态
    for (var user in _recommendedUsers) {
      if (user['username'] != null) {
        _checkFriendStatusForUser(user['username']);
      }
    }
  }

  Future<bool> _checkFriendStatus(String username) async {
    if (_currentUsername == null) {
      return false;
    }

    try {
      UserService userService = UserService();
      var result = await userService.whetherfriend(_currentUsername!, username);

      if (result != null && result['code'] == 0) {
        return result['data'] == "1";
      }
      return false;
    } catch (e) {
      print('检查朋友关系失败: $e');
      return false;
    }
  }

  Future<void> _fetchSearchResults() async {
    if (_searchController.text.trim().isEmpty) {
      setState(() {
        _showSearchResults = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _showSearchResults = true;
    });

    try {
      SearchSomeService service = SearchSomeService();
      var result = await service.SearchSome(_searchController.text);

      setState(() {
        if (result != null && result['code'] == 0 && result['data'] != null) {
          _searchResults = result['data'];
          _friendStatusMap.clear();

          for (var user in _searchResults) {
            if (user['username'] != null) {
              _checkFriendStatusForUser(user['username']);
            }
          }
        } else {
          _searchResults = [];
        }
        _isLoading = false;
      });
    } catch (e) {
      print('搜索出错: $e');
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('搜索失败，请稍后再试')),
      );
    }
  }

  Future<void> _checkFriendStatusForUser(String username) async {
    bool isFriend = await _checkFriendStatus(username);
    setState(() {
      _friendStatusMap[username] = isFriend;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '添加朋友',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // 搜索框
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索用户名或昵称...',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                filled: true,
                fillColor: Colors.grey.shade100,
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey.shade600),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _showSearchResults = false;
                            _searchResults = [];
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                setState(() {});
                if (value.isEmpty) {
                  setState(() {
                    _showSearchResults = false;
                    _searchResults = [];
                  });
                }
              },
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _fetchSearchResults();
                }
              },
              textInputAction: TextInputAction.search,
            ),
          ),

          // 搜索结果或推荐用户
          Expanded(
            child: _showSearchResults
                ? _buildSearchResults()
                : _buildRecommendedUsers(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              '没有找到相关用户',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResults.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        thickness: 0.5,
        color: Colors.grey.shade200,
      ),
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        return _buildUserSearchResultItem(item);
      },
    );
  }

  Widget _buildRecommendedUsers() {
    if (_recommendedUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              '暂无推荐用户',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: const Text(
            '推荐用户',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _recommendedUsers.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 0.5,
              color: Colors.grey.shade200,
            ),
            itemBuilder: (context, index) {
              final item = _recommendedUsers[index];
              return _buildUserSearchResultItem(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserSearchResultItem(Map<String, dynamic> userData) {
    final String nickname = userData['nickname'] ?? '未知用户';
    final String username = userData['username'] ?? '';
    final String bio = userData['bio'] ?? '这个人很神秘,还没有简介';
    final String userPic = userData['userPic'] ?? '';
    final bool isFriend = _friendStatusMap[username] ?? false;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          RouteUtils.slideFromRight(
            ProfilePage(username: username),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // 头像
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: userPic.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: userPic,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey.shade200,
                        child: Icon(Icons.person, color: Colors.grey.shade400),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey.shade200,
                        child: Icon(Icons.person, color: Colors.grey.shade400),
                      ),
                    )
                  : Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.person,
                        color: Colors.grey.shade400,
                        size: 30,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            // 用户信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nickname,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@$username',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    bio,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // 关注按钮
            ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isFriend ? Colors.grey.shade300 : const Color(0xFF6201E7),
                foregroundColor: isFriend ? Colors.black87 : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                elevation: 0,
              ),
              child: Text(
                isFriend ? '已关注' : '关注',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
