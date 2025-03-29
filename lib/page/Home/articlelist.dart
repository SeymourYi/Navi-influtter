import 'package:flutter/material.dart';
import 'package:flutterlearn2/api/articleAPI.dart';
import 'package:flutterlearn2/components/article.dart';

class Articlelist extends StatefulWidget {
  const Articlelist({super.key});

  @override
  State<Articlelist> createState() => _ArticlelistState();
}

class _ArticlelistState extends State<Articlelist>
    with AutomaticKeepAliveClientMixin {
  List<dynamic> articleList = [];
  bool isLoading = false; // 加载状态控制
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  // 获取文章列表
  Future<void> _fetchArticleList() async {
    if (isLoading) return; // 防止重复加载

    setState(() {
      isLoading = true;
    });

    ArticleService service = ArticleService();
    try {
      var result = await service.getallArticleList(1);
      setState(() {
        articleList = result['data'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // 错误提示
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('获取文章失败，请检查网络连接')));
      }
    }
  }

  // 手动触发刷新
  void triggerRefresh() {
    _refreshIndicatorKey.currentState?.show();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchArticleList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用，因为使用了AutomaticKeepAliveClientMixin

    return Container(
      height: MediaQuery.of(context).size.height - 150, // 给列表一个明确的高度
      child: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _fetchArticleList,
        color: Colors.blue, // 刷新指示器颜色
        backgroundColor: Colors.white, // 刷新指示器背景颜色
        child:
            isLoading && articleList.isEmpty
                ? _buildLoadingView()
                : articleList.isEmpty
                ? _buildEmptyView()
                : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  cacheExtent: 2000, // 缓存额外 2000 像素的内容
                  itemCount: articleList.length,
                  itemBuilder: (context, index) {
                    return Article(articleData: articleList[index]);
                  },
                ),
      ),
    );
  }

  // 加载中视图
  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            '正在加载文章...',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  // 空状态视图
  Widget _buildEmptyView() {
    return Center(
      child: SingleChildScrollView(
        // 确保空状态视图也可以下拉刷新
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 80, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              '暂无文章',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              '下拉刷新试试',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: triggerRefresh,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text('刷新'),
              ),
            ),
            SizedBox(height: 100), // 添加额外空间以确保可以下拉
          ],
        ),
      ),
    );
  }
}
