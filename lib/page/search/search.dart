import 'package:flutter/material.dart';
import 'package:Navi/Store/storeutils.dart';
import 'package:Navi/api/searchsomeAPI.dart';
import 'package:Navi/page/UserInfo/components/userpage.dart';
import 'package:Navi/api/userAPI.dart'; // 导入用户API

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
  Map<String, bool> _friendStatusMap = {}; // 存储朋友关系状态

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
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
      print(result);

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

  // 检查单个用户的朋友状态
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
      appBar: AppBar(
        title: _buildSearchBar(),
        automaticallyImplyLeading: false,
      ),
      body: _showSearchResults ? _buildSearchResults() : _buildEmptyState(),
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
                ? NetworkImage(userPic)
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
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => ProfilePage(
                  username: username, // 传递用户名参数
                ),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;
              var tween = Tween(
                begin: begin,
                end: end,
              ).chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFollowButton(String username) {
    bool isFriend = _friendStatusMap[username] ?? false;

    return ElevatedButton(
      onPressed: null, // 按照要求不实现关注功能
      style: ElevatedButton.styleFrom(
        backgroundColor: isFriend ? Colors.grey[300] : Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      child: Text(
        isFriend ? '已关注' : '关注',
        style: TextStyle(color: isFriend ? Colors.black : Colors.white),
      ),
    );
  }
}
