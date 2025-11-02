import 'package:Navi/Store/storeutils.dart';
import 'package:flutter/material.dart';
import 'package:Navi/api/articleAPI.dart';
import 'package:Navi/components/article.dart';

class FriendArticlelist extends StatefulWidget {
  final Function(double)? onScrollChanged; // 添加滚动变化回调

  const FriendArticlelist({super.key, this.onScrollChanged});

  @override
  State<FriendArticlelist> createState() => _FriendArticlelistState();
}

class _FriendArticlelistState extends State<FriendArticlelist>
    with AutomaticKeepAliveClientMixin {
  List<dynamic> articleList = [];
  bool isLoading = false; // 加载状态控制
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  late ScrollController _scrollController; // 添加 ScrollController

  Future<int> _fetchID() async {
    final userInfo = await SharedPrefsUtils.getUserInfo();
    return userInfo!['id'];
  }

  // 获取文章列表
  Future<void> _fetchArticleList() async {
    if (isLoading) return; // 防止重复加载

    setState(() {
      isLoading = true;
    });

    ArticleService service = ArticleService();
    try {
      var result = await service.getfriendArticleList(await _fetchID());
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
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _fetchArticleList();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (widget.onScrollChanged != null && _scrollController.hasClients) {
      widget.onScrollChanged!(_scrollController.position.pixels);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用，因为使用了AutomaticKeepAliveClientMixin

    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _fetchArticleList,
      color: Color(0xFF6201E7), // 主题色
      backgroundColor: Colors.white,
      child: isLoading && articleList.isEmpty
          ? _buildLoadingView()
          : articleList.isEmpty
              ? _buildEmptyView()
              : ListView.separated(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  // 优化 cacheExtent：设置为屏幕高度的2倍，优先加载视口附近的图片
                  cacheExtent: MediaQuery.of(context).size.height * 2,
                  itemCount: articleList.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    thickness: 0.5,
                    color: Colors.grey[200],
                  ),
                  itemBuilder: (context, index) {
                    return Article(articleData: articleList[index]);
                  },
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
