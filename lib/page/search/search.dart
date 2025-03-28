import 'package:flutter/material.dart';
import 'package:flutterlearn2/Store/storeutils.dart';
import 'package:flutterlearn2/api/searchsomeAPI.dart';

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
      body: _showSearchResults ? _buildSearchResults() : _buildExploreContent(),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: '搜索用户、话题或关键词',
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

  Widget _buildExploreContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('热门话题'),
          _buildTrendingTopic('世界杯', '体育·热门', '1,234 推文'),
          _buildTrendingTopic('科技大会', '科技·趋势', '5,678 推文'),
          _buildTrendingTopic('新电影', '娱乐·趋势', '9,012 推文'),
          const SizedBox(height: 16),
          _buildSectionTitle('为你推荐'),
          _buildRecommendedUser(
            '张三',
            '@zhangsan',
            'lib/assets/avatars/user1.jpg',
          ),
          _buildRecommendedUser('李四', '@lisi', 'lib/assets/avatars/user2.jpg'),
          _buildRecommendedUser(
            '王五',
            '@wangwu',
            'lib/assets/avatars/user3.jpg',
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
              '没有找到相关结果',
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
        // 根据返回的数据格式，这些是用户类型的结果
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
      trailing: _buildFollowButton(),
      onTap: () {
        // 处理用户点击事件
        print('点击了用户: $nickname');
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
  }

  Widget _buildTrendingTopic(String topic, String category, String tweets) {
    return ListTile(
      title: Text(topic, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('$category · $tweets'),
      trailing: const Icon(Icons.more_vert),
      onTap: () {
        _searchController.text = topic;
        _fetchSearchResults();
      },
    );
  }

  Widget _buildRecommendedUser(String name, String handle, String avatarPath) {
    return ListTile(
      leading: CircleAvatar(backgroundImage: AssetImage(avatarPath)),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(handle),
      trailing: _buildFollowButton(),
      onTap: () {
        _searchController.text = handle;
        _fetchSearchResults();
      },
    );
  }

  Widget _buildSearchResultItem(
    String type,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: type == '用户' ? _buildFollowButton() : null,
      onTap: () {
        // 处理结果项点击事件
      },
    );
  }

  Widget _buildFollowButton() {
    return ElevatedButton(
      onPressed: () {
        // 处理关注/取消关注逻辑
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      child: const Text('关注', style: TextStyle(color: Colors.white)),
    );
  }
}
