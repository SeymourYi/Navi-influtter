import 'package:Navi/api/articleAPI.dart';
import 'package:Navi/api/getarticleinfoAPI.dart';
import 'package:Navi/components/CommentWidget%20.dart';
import 'package:Navi/components/litarticle.dart';
import 'package:Navi/page/Home/articlelist.dart';
import 'package:flutter/material.dart';
import 'articleimage.dart';
import '../components/userinfo.dart';

class Articledetail extends StatefulWidget {
  const Articledetail({super.key, this.articleData});
  final dynamic articleData;

  @override
  State<Articledetail> createState() => _ArticledetailState();
}

class _ArticledetailState extends State<Articledetail> {
  ArticleService service = ArticleService();
  List<dynamic> articleComments = [];
  @override
  void initState() {
    super.initState();
    getarticleComments();
  }

  void getarticleComments() async {
    final result = await ArticleService().getArticleComments(
      int.parse(widget.articleData['id']),
    );
    setState(() {
      articleComments = result['data'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title:
            widget.articleData['categoryName'] != null &&
                    widget.articleData['categoryName'].isNotEmpty
                ? Text(widget.articleData['categoryName'])
                : null,
      ),
      body: ListView(
        children: [
          // User info row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Userinfo()),
                    );
                  },
                  child:
                      widget.articleData['userPic'] != null &&
                              widget.articleData['userPic'].isNotEmpty
                          ? CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(
                              widget.articleData['userPic'],
                            ),
                          )
                          : CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.grey[300],
                            child: Icon(Icons.person, color: Colors.grey[600]),
                          ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.articleData['nickname'] ?? '用户',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "@${widget.articleData['username'] ?? ''} · ${widget.articleData['uptonowTime'] ?? ''}",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Article content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              widget.articleData['content'] ?? '',
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
          ),

          // Images
          if (widget.articleData['imageUrls'] != null &&
              widget.articleData['imageUrls'].isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ArticleImage(imageUrls: widget.articleData['imageUrls']),
            ),
          widget.articleData['coverImg'] != ""
              ? ArticleImage(imageUrls: ["${widget.articleData['coverImg']}"])
              : Container(),

          widget.articleData['userShare'] == true
              ? Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05,
                ),
                child: LitArticle(articleData: widget.articleData),
              )
              : Container(),

          // Stats and actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            child: Row(
              children: [
                Text(
                  "${widget.articleData['createTime'].substring(0, 4)}年${widget.articleData['createTime'].substring(5, 7)}月${widget.articleData['createTime'].substring(8, 10)}日,${widget.articleData['createTime'].substring(11, 13)}:${widget.articleData['createTime'].substring(14, 16)}:${widget.articleData['createTime'].substring(17, 19)}",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontFamily: "Inter",
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 0.5, color: Color.fromARGB(69, 158, 158, 158)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: Row(
              children: [
                Text(
                  " ${widget.articleData['commentcount']?.toString() ?? '0'}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color.fromRGBO(255, 203, 107, 1.00),
                  ),
                ),
                Text(
                  "评论",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(width: 6),
                Text(
                  " ${widget.articleData['repeatcount']?.toString() ?? '0'}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color.fromRGBO(255, 203, 107, 1.00),
                  ),
                ),
                Text(
                  "转载",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(width: 6),
                Text(
                  " ${widget.articleData['likecont']?.toString() ?? '0'}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color.fromRGBO(255, 203, 107, 1.00),
                  ),
                ),
                Text(
                  "喜欢",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          const Divider(height: 0.5, color: Color.fromARGB(69, 158, 158, 158)),
          // Stats display (without interactive buttons)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.mode_comment_outlined,
                  count: widget.articleData['commentcount']?.toString() ?? '0',
                ),
                _buildStatItem(
                  icon: Icons.repeat,
                  count: widget.articleData['repeatcount']?.toString() ?? '0',
                ),
                _buildStatItem(
                  icon: Icons.favorite_border,
                  count: widget.articleData['likecont']?.toString() ?? '0',
                ),
              ],
            ),
          ),
          const Divider(height: 0.5, color: Color.fromARGB(69, 158, 158, 158)),
          if (articleComments.isNotEmpty)
            CommentWidget(comments: articleComments),
        ],
      ),
    );
  }

  Widget _buildStatItem({required IconData icon, required String count}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(count, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }
}
