import 'package:flutter/material.dart';
import 'package:Navi/components/article.dart';
import 'package:Navi/api/articleAPI.dart';
import 'package:Navi/utils/route_utils.dart';
import 'package:Navi/Store/storeutils.dart';

class SearchPostsPage extends StatefulWidget {
  const SearchPostsPage({Key? key}) : super(key: key);

  @override
  State<SearchPostsPage> createState() => _SearchPostsPageState();
}

class _SearchPostsPageState extends State<SearchPostsPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchResults = false;
  bool _isLoading = false;
  List<dynamic> _searchResults = [];
  List<dynamic> _recommendedPosts = [];
  String _sortType = 'relevance'; // 'relevance' 或 'time'

  @override
  void initState() {
    super.initState();
    _loadRecommendedPosts();
  }

  Future<void> _loadRecommendedPosts() async {
    // TODO: 实现推荐帖子API
    // 暂时使用写死的数据
    setState(() {
      _recommendedPosts = [
        {
          'id': '1',
          'nickname': '科技达人',
          'createUserName': '科技达人',
          'username': 'tech_guru',
          'content': '今天体验了最新的AI技术,感觉未来真的来了!人工智能正在改变我们的生活方式。',
          'userPic': '',
          'likecont': 128,
          'commentcount': 45,
          'repeatcount': 23,
          'commentcont': 45,
          'sharecont': 23,
          'uptonowTime': '656天前',
          'islike': false,
          'coverImg': '',
          'coverImgList': <String>[],
          'userShare': false,
          'isVerified': false,
          'verified': false,
        },
        {
          'id': '2',
          'nickname': '生活分享者',
          'createUserName': '生活分享者',
          'username': 'life_sharer',
          'content': '周末去了一个很棒的咖啡店,环境特别舒适,推荐给大家!',
          'userPic': '',
          'likecont': 89,
          'commentcount': 12,
          'repeatcount': 8,
          'commentcont': 12,
          'sharecont': 8,
          'uptonowTime': '657天前',
          'islike': false,
          'coverImg': '',
          'coverImgList': <String>[],
          'userShare': false,
          'isVerified': false,
          'verified': false,
        },
        {
          'id': '3',
          'nickname': '新闻猎手',
          'createUserName': '新闻猎手',
          'username': 'news_hunter',
          'content': '重大科技突破!科学家在量子计算领域取得新进展,这可能会改变整个计算行业。',
          'userPic': '',
          'likecont': 256,
          'commentcount': 78,
          'repeatcount': 156,
          'commentcont': 78,
          'sharecont': 156,
          'uptonowTime': '658天前',
          'islike': false,
          'coverImg': '',
          'coverImgList': <String>[],
          'userShare': false,
          'isVerified': false,
          'verified': false,
        },
      ];
    });
  }

  Future<void> _fetchSearchResults() async {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) {
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
      // 获取当前用户信息
      final userInfo = await SharedPrefsUtils.getUserInfo();
      if (userInfo == null || userInfo['username'] == null) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请先登录后再搜索')),
        );
        return;
      }

      final username = userInfo['username'].toString();
      
      // 调用搜索API
      final articleService = ArticleService();
      final result = await articleService.searchArticles(
        keyword: keyword,
      );

      if (result != null && result['code'] == 0) {
        setState(() {
          _searchResults = result['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result != null ? (result['msg'] ?? '搜索失败') : '搜索失败'),
          ),
        );
      }
    } catch (e) {
      print('搜索帖子出错: $e');
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('搜索失败: ${e.toString()}')),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '搜索帖子',
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
                hintText: '搜索帖子内容...',
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

          // 搜索结果标题和排序
          if (_showSearchResults && _searchResults.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '找到${_searchResults.length}条结果',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  Row(
                    children: [
                      _buildSortButton('相关度', 'relevance'),
                      const SizedBox(width: 8),
                      _buildSortButton('时间', 'time'),
                    ],
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // 搜索结果列表
          Expanded(
            child: _showSearchResults
                ? _buildSearchResults()
                : _buildRecommendedPosts(),
          ),
        ],
      ),
    );
  }

  Widget _buildSortButton(String label, String value) {
    final bool isSelected = _sortType == value;
    return InkWell(
      onTap: () {
        setState(() {
          _sortType = value;
        });
        _fetchSearchResults();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6201E7) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF6201E7) : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendedPosts() {
    if (_recommendedPosts.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: _recommendedPosts.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        thickness: 0.5,
        color: Colors.grey.shade200,
      ),
      itemBuilder: (context, index) {
        final item = _recommendedPosts[index];
        return Article(articleData: item);
      },
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
            '输入关键词搜索帖子',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
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
              '没有找到相关帖子',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: _searchResults.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        thickness: 0.5,
        color: Colors.grey.shade200,
      ),
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        return Article(articleData: item);
      },
    );
  }
}
