import 'package:flutter/material.dart';
import 'package:flutterlearn2/api/articleAPI.dart';
import 'package:flutterlearn2/components/article.dart';

class Articlelist extends StatefulWidget {
  const Articlelist({super.key});

  @override
  State<Articlelist> createState() => _ArticlelistState();
}

class _ArticlelistState extends State<Articlelist> {
  List<dynamic> articleList = [];

  Future<void> _fetchArticleList() async {
    ArticleService service = ArticleService();
    try {
      var result = await service.getArticleList(1);
      setState(() {
        articleList = result['data'];
      });
    } catch (e) {
      print('Error fetching articles: $e');
    }
  }

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
        itemCount: articleList.length,
        itemBuilder: (BuildContext ctx, int i) {
          return Article(articleData: articleList[i]);
        },
      ),
    );
  }
}
