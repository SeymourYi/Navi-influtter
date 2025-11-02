import 'package:Navi/Store/storeutils.dart';
import 'package:Navi/api/emailAPI.dart';
import 'package:Navi/components/userinfo.dart';
import 'package:Navi/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:Navi/api/articleAPI.dart';
import 'package:Navi/components/article.dart';
import 'package:provider/provider.dart';
import 'package:Navi/utils/viewport_image.dart';
import 'dart:async';

class Articlelist extends StatefulWidget {
  final Function(double)? onScrollChanged; // 添加滚动变化回调

  const Articlelist({super.key, this.onScrollChanged});

  @override
  State<Articlelist> createState() => _ArticlelistState();
}

class _ArticlelistState extends State<Articlelist>
    with AutomaticKeepAliveClientMixin {
  List<dynamic> articleList = [];
  bool isLoading = false; // 加载状态控制
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  ArticleService service = ArticleService();
  EmailService emailService = EmailService();
  String number = '';
  bool initialLoad = true; // 添加标记以跟踪初始加载
  late ScrollController _scrollController; // 添加 ScrollController
  Timer? _preloadTimer; // 预加载定时器，用于防抖
  final Set<String> _preloadedUrls = {}; // 已预加载的图片URL集合

  // 获取文章列表
  Future<void> _fetchArticleList() async {
    if (isLoading) return; // 防止重复加载

    setState(() {
      isLoading = true;
    });

    // 获取用户信息
    final userInfo = await SharedPrefsUtils.getUserInfo();
    
    // 只在初始加载时获取未读邮件数量并设置通知计数
    if (initialLoad && userInfo != null) {
      var result1 = await emailService.getEmailNumber(
        int.parse(userInfo['username']),
      );
      number = result1['data'];

      Provider.of<NotificationProvider>(
        context,
        listen: false,
      ).setnotificationcount(int.parse(number));

      initialLoad = false; // 标记初始加载已完成
    }

    try {
      // 使用当前登录用户的ID，如果没有登录则使用默认值1（游客模式）
      final userId = userInfo != null && userInfo['id'] != null 
          ? userInfo['id'] as int 
          : 1;
      var result = await service.getallArticleList(userId);
      setState(() {
        articleList = result['data'];
        isLoading = false;
      });
      
      // 列表加载完成后，预加载首屏图片
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && articleList.isNotEmpty) {
          _preloadImagesForCurrentViewport();
        }
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
    _preloadTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (widget.onScrollChanged != null && _scrollController.hasClients) {
      widget.onScrollChanged!(_scrollController.position.pixels);
    }
    // 预加载即将进入视口的图片
    _preloadImagesForCurrentViewport();
  }

  /// 预加载当前视口附近的图片
  void _preloadImagesForCurrentViewport() {
    if (!_scrollController.hasClients || articleList.isEmpty) return;

    // 防抖处理，避免频繁预加载
    _preloadTimer?.cancel();
    _preloadTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      final ScrollPosition position = _scrollController.position;
      final double viewportHeight = position.viewportDimension;
      final double scrollOffset = position.pixels;
      
      // 预加载范围：上下各扩展一个屏幕高度
      final double preloadTop = scrollOffset - viewportHeight;
      final double preloadBottom = scrollOffset + viewportHeight * 2;

      // 估算每个文章项的平均高度（可以根据实际情况调整）
      const double estimatedItemHeight = 300.0;

      // 计算需要预加载的索引范围
      final int startIndex = ((preloadTop / estimatedItemHeight).floor()).clamp(0, articleList.length);
      final int endIndex = ((preloadBottom / estimatedItemHeight).ceil()).clamp(0, articleList.length);

      // 预加载范围内的图片
      for (int i = startIndex; i < endIndex; i++) {
        if (i >= articleList.length) break;
        _preloadArticleImages(articleList[i]);
      }
    });
  }

  /// 预加载单个文章的所有图片
  void _preloadArticleImages(dynamic articleData) {
    if (articleData == null) return;

    // 获取文章的图片列表
    List<String> imageUrls = [];
    
    if (articleData['coverImg'] != null && 
        articleData['coverImg'].toString().isNotEmpty) {
      if (articleData['coverImgList'] != null &&
          articleData['coverImgList'] is List &&
          (articleData['coverImgList'] as List).isNotEmpty) {
        imageUrls = List<String>.from(articleData['coverImgList']);
      } else {
        imageUrls = [articleData['coverImg'].toString()];
      }
    }

    // 预加载每张图片（异步，不阻塞UI）
    for (final String imageUrl in imageUrls) {
      if (!_preloadedUrls.contains(imageUrl)) {
        _preloadedUrls.add(imageUrl);
        _preloadSingleImage(imageUrl);
      }
    }
  }

  /// 预加载单张图片
  Future<void> _preloadSingleImage(String imageUrl) async {
    if (!mounted) return;
    
    try {
      // 使用 ViewportAwareImage 的预加载方法
      await ViewportAwareImage.precacheNetworkImage(imageUrl, context);
    } catch (e) {
      // 预加载失败，从集合中移除以便重试
      _preloadedUrls.remove(imageUrl);
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
