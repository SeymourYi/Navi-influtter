import 'package:flutter/material.dart';
import 'package:Navi/Store/storeutils.dart';
import 'package:Navi/api/searchsomeAPI.dart';
import 'package:Navi/page/UserInfo/components/userpage.dart';
import 'package:Navi/api/userAPI.dart'; // 导入用户API
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Navi/utils/route_utils.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchResults = false;
  bool _isLoading = false;
  List<dynamic> _searchResults = [];
  List<dynamic> _recommendedUsers = []; // 推荐用户列表
  bool _isLoadingRecommended = false; // 加载推荐用户状态
  Map<String, bool> _friendStatusMap = {}; // 存储朋友关系状态

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadRecommendedUsers(); // 加载推荐用户
  }

  String? _currentUsername; // 当前用户名

  // 加载当前用户信息
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

  // 检查朋友关系
  Future<bool> _checkFriendStatus(String username) async {
    if (_currentUsername == null) {
      return false;
    }

    try {
      UserService userService = UserService();
      var result = await userService.whetherfriend(_currentUsername!, username);

      if (result != null && result['code'] == 0) {
        return result['data'] == "1"; // "1"表示是朋友，"0"表示不是朋友
      }
      return false;
    } catch (e) {
      print('检查朋友关系失败: $e');
      return false;
    }
  }

  Future<void> _fetchSearchResults() async {
    if (_searchController.text.trim().isEmpty) {
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
          print('解析到的搜索结果: $_searchResults');

          // 清空之前的朋友状态
          _friendStatusMap.clear();

          // 检查每个用户的朋友状态
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

      // 显示错误提示
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('搜索失败，请稍后再试')));
    }
  }

  // 加载推荐用户
  Future<void> _loadRecommendedUsers() async {
    if (_currentUsername == null) {
      // 如果用户名还没加载，先等待
      await Future.delayed(Duration(milliseconds: 100));
      if (_currentUsername == null) return;
    }

    setState(() {
      _isLoadingRecommended = true;
    });

    try {
      UserService userService = UserService();
      var result = await userService.getRecommendFriendList(_currentUsername!);

      if (result != null && result['code'] == 0 && result['data'] != null) {
        setState(() {
          _recommendedUsers = result['data'];
        });

        // 检查每个推荐用户的朋友状态
        for (var user in _recommendedUsers) {
          if (user['username'] != null) {
            _checkFriendStatusForUser(user['username']);
          }
        }
      }
    } catch (e) {
      print('加载推荐用户失败: $e');
    } finally {
      setState(() {
        _isLoadingRecommended = false;
      });
    }
  }

  // 检查单个用户的朋友状态
  Future<void> _checkFriendStatusForUser(String username) async {
    bool isFriend = await _checkFriendStatus(username);
    setState(() {
      _friendStatusMap[username] = isFriend;
    });
  }

  // 处理关注/取关操作
  Future<void> _handleFollowAction(String username, bool isCurrentlyFollowing) async {
    if (_currentUsername == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请先登录')),
      );
      return;
    }

    // 如果是已关注状态，显示确认对话框
    if (isCurrentlyFollowing) {
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text('确认取关'),
            content: Text('确定要取消关注该用户吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('取消'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                ),
                child: Text('确定'),
              ),
            ],
          );
        },
      );

      if (confirm != true) {
        return;
      }
    }

    try {
      UserService userService = UserService();
      var result = await userService.followOrUnfollowUser(
        currentUsername: _currentUsername!,
        targetUsername: username,
      );

      if (result != null && result['code'] == 0) {
        // 更新朋友状态
        setState(() {
          _friendStatusMap[username] = !isCurrentlyFollowing;
        });

        // 更新搜索结果中的状态
        for (var user in _searchResults) {
          if (user['username'] == username) {
            user['isFriend'] = !isCurrentlyFollowing;
          }
        }

        // 更新推荐用户列表中的状态
        for (var user in _recommendedUsers) {
          if (user['username'] == username) {
            user['isFriend'] = !isCurrentlyFollowing;
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(!isCurrentlyFollowing ? '已关注' : '已取消关注'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result?['msg'] ?? '操作失败，请稍后重试')),
        );
      }
    } catch (e) {
      print('关注操作失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('操作失败: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchBar(),
        automaticallyImplyLeading: false,
      ),
      body: _showSearchResults ? _buildSearchResults() : _buildRecommendedUsers(),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: '搜索用户名',
        hintStyle: TextStyle(color: Colors.grey.shade600),
        filled: true,
        fillColor: Colors.grey.shade200,
        prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
        suffixIcon: IconButton(
          icon: Icon(Icons.clear, color: Colors.grey.shade600),
          onPressed: () {
        _searchController.clear();
        setState(() {
          _showSearchResults = false;
        });
        _loadRecommendedUsers(); // 清空搜索时重新加载推荐用户
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
      ),
      onChanged: (value) {
        setState(() {
          _showSearchResults = value.isNotEmpty;
        });
      },
      onSubmitted: (value) {
        if (value.isNotEmpty) {
          _fetchSearchResults();
        }
      },
      textInputAction: TextInputAction.search,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            '输入用户名进行搜索',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // 构建推荐用户列表
  Widget _buildRecommendedUsers() {
    if (_isLoadingRecommended) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_recommendedUsers.isEmpty) {
      return _buildEmptyState();
    }

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            '推荐用户',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        ..._recommendedUsers.map((user) => _buildUserRecommendationItem(user)),
      ],
    );
  }

  // 构建推荐用户项
  Widget _buildUserRecommendationItem(Map<String, dynamic> userData) {
    final String nickname = userData['nickname'] ?? '未知用户';
    final String username = userData['username'] ?? '';
    final String bio = userData['bio'] ?? '这个人很神秘，还没有简介';
    final String userPic = userData['userPic'] ?? '';
    bool isFriend = _friendStatusMap[username] ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                RouteUtils.slideFromRight(ProfilePage(username: username)),
              );
            },
            child: CircleAvatar(
              backgroundImage: userPic.isNotEmpty
                  ? CachedNetworkImageProvider(userPic)
                  : AssetImage('lib/assets/images/userpic.jpg') as ImageProvider,
              radius: 30,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      nickname,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '@$username',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  bio,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _handleFollowAction(username, isFriend),
            style: ElevatedButton.styleFrom(
              backgroundColor: isFriend ? Colors.grey[300] : Colors.black87,
              foregroundColor: isFriend ? Colors.black87 : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size(0, 36),
            ),
            child: Text(
              isFriend ? '已关注' : '关注',
              style: TextStyle(fontSize: 14),
            ),
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
            Icon(Icons.search_off, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '没有找到相关用户',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _fetchSearchResults,
              child: const Text('重新搜索'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        return _buildUserSearchResultItem(item);
      },
    );
  }

  Widget _buildUserSearchResultItem(Map<String, dynamic> userData) {
    final String nickname = userData['nickname'] ?? '未知用户';
    final String username = userData['username'] ?? '';
    final String bio = userData['bio'] ?? '暂无简介';
    final String userPic = userData['userPic'] ?? '';

    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
            userPic.isNotEmpty
                ? CachedNetworkImageProvider(userPic)
                : AssetImage('lib/assets/images/userpic.jpg') as ImageProvider,
        radius: 25,
      ),
      title: Row(
        children: [
          Text(nickname, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          Text(
            '@$username',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
      subtitle:
          bio.isNotEmpty
              ? Text(bio, maxLines: 2, overflow: TextOverflow.ellipsis)
              : null,
      trailing: _buildFollowButton(username),
      onTap: () {
        // 导航到用户主页
        Navigator.push(
          context,
          RouteUtils.slideFromRight(ProfilePage(username: username)),
        );
      },
    );
  }

  Widget _buildFollowButton(String username) {
    bool isFriend = _friendStatusMap[username] ?? false;

    return ElevatedButton(
      onPressed: () => _handleFollowAction(username, isFriend),
      style: ElevatedButton.styleFrom(
        backgroundColor: isFriend ? Colors.grey[300] : Colors.black87,
        foregroundColor: isFriend ? Colors.black87 : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        minimumSize: Size(0, 36),
      ),
      child: Text(
        isFriend ? '已关注' : '关注',
        style: TextStyle(fontSize: 14),
      ),
    );
  }
}
