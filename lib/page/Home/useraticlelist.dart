import 'package:flutter/material.dart';
import 'package:Navi/api/articleAPI.dart';
import 'package:Navi/components/article.dart';
import 'package:Navi/Store/storeutils.dart';

class Articlelist extends StatefulWidget {
  const Articlelist({super.key});

  @override
  State<Articlelist> createState() => _ArticlelistState();
}

class _ArticlelistState extends State<Articlelist>
    with AutomaticKeepAliveClientMixin {
  List<dynamic> articleList = [];

  Future<void> _fetchArticleList() async {
    ArticleService service = ArticleService();
    try {
      // 获取当前登录用户的ID
      final userInfo = await SharedPrefsUtils.getUserInfo();
      final userId = userInfo != null && userInfo['id'] != null 
          ? userInfo['id'] as int 
          : 1;
      var result = await service.getallArticleList(userId);
      setState(() {
        articleList = result['data'];
      });
    } catch (e) {
      print('Error fetching articles: $e');
    }
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
    return SizedBox(
      height: 700, // specify a height
      child: ListView.builder(
        // 优化 cacheExtent：设置为屏幕高度的2倍，优先加载视口附近的图片
        cacheExtent: MediaQuery.of(context).size.height * 2,
        itemCount: articleList.length,
        itemBuilder: (BuildContext ctx, int i) {
          return Article(articleData: articleList[i]);
        },
      ),
    );
  }
}
