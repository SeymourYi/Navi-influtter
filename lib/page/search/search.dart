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
      trailing: _buildFollowButton(),
      onTap: () {
        print('点击了用户: $nickname');
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
