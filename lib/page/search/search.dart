// search_page.dart
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchResults = false;

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
        // 处理搜索提交
      },
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
    return ListView(
      children: [
        _buildSearchResultItem('用户', '张三', '@zhangsan', Icons.person),
        _buildSearchResultItem('话题', '世界杯', '1,234 推文', Icons.tag),
        _buildSearchResultItem('用户', '李四', '@lisi', Icons.person),
        _buildSearchResultItem('话题', '科技大会', '5,678 推文', Icons.tag),
      ],
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
        // 跳转到话题页面
      },
    );
  }

  Widget _buildRecommendedUser(String name, String handle, String avatarPath) {
    return ListTile(
      leading: CircleAvatar(backgroundImage: AssetImage(avatarPath)),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(handle),
      trailing: ElevatedButton(
        onPressed: () {
          // 关注用户
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text('关注'),
      ),
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
      trailing:
          type == '用户'
              ? ElevatedButton(
                onPressed: () {},
                child: const Text('关注'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              )
              : null,
    );
  }
}
