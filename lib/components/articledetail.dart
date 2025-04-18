import 'package:Navi/api/articleAPI.dart';
import 'package:Navi/api/getarticleinfoAPI.dart';
import 'package:Navi/components/CommentWidget%20.dart';
import 'package:Navi/components/litarticle.dart';
import 'package:Navi/page/Home/articlelist.dart';
import 'package:Navi/page/UserInfo/components/userpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  void _navigatetoarticledetail() {
    // 检查文章ID是否存在
    // if (widget.articleData == null || widget.articleData['id'] == null) {
    //   return;
    // }
    print("111111111111111111111111111");
    print(widget.articleData['beShareArticleId']);
    print("11111122222222222211111111111");
    // String beShareArticleId = "${widget.articleData['beShareArticleId']}";
    //得到文章详情
    // final result = await ArticleService().getArticleDetail(beShareArticleId);

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => Articledetail(articleData: result['data']),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title:
            widget.articleData['categoryName'] != null &&
                    widget.articleData['categoryName'].isNotEmpty
                ? Text(
                  widget.articleData['categoryName'],
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                )
                : null,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(height: 0.5, color: Colors.grey.shade200),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 用户信息和文章内容容器
          Container(
            padding: EdgeInsets.only(top: 12, left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 用户信息行 - 更紧凑的布局
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ProfilePage(
                                  username: widget.articleData['username'],
                                ),
                          ),
                        );
                      },
                      child:
                          widget.articleData['userPic'] != null &&
                                  widget.articleData['userPic'].isNotEmpty
                              ? CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(
                                  widget.articleData['userPic'],
                                ),
                              )
                              : CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.grey[300],
                                child: Icon(
                                  Icons.person,
                                  color: Colors.grey[600],
                                ),
                              ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.articleData['nickname'] ?? '用户',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 1),
                          Row(
                            children: [
                              Text(
                                "@${widget.articleData['username'] ?? ''}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                " · ${widget.articleData['uptonowTime'] ?? ''}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      icon: Icon(
                        Icons.more_horiz,
                        size: 20,
                        color: Colors.grey[700],
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),

                // 文章内容区域 - 直接跟在用户信息下方
                Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 8),
                  child: Text(
                    widget.articleData['content'] ?? '',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.3,
                      color: Colors.black,
                    ),
                  ),
                ),

                // 分类标签（如果有）
                if (widget.articleData['categoryName'] != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      "#${widget.articleData['categoryName']}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromRGBO(29, 161, 242, 1.0),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                // 图片 - 紧贴内容
                if (widget.articleData['imageUrls'] != null &&
                    widget.articleData['imageUrls'].isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ArticleImage(
                        imageUrls: widget.articleData['imageUrls'],
                      ),
                    ),
                  ),

                if (widget.articleData['coverImg'] != "")
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ArticleImage(
                        imageUrls: ["${widget.articleData['coverImg']}"],
                      ),
                    ),
                  ),

                // 转发内容
                if (widget.articleData['userShare'] == true)
                  Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: LitArticle(articleData: widget.articleData),
                    ),
                  ),

                // 发布时间 - 更小的文字
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    "${widget.articleData['createTime'].substring(0, 4)}年${widget.articleData['createTime'].substring(5, 7)}月${widget.articleData['createTime'].substring(8, 10)}日 ${widget.articleData['createTime'].substring(11, 13)}:${widget.articleData['createTime'].substring(14, 16)}",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 0.5, color: Colors.grey.shade200),

          // 互动统计 - 更紧凑的布局
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  "${widget.articleData['commentcount'] ?? '0'}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(29, 161, 242, 1.0),
                  ),
                ),
                Text(
                  " 评论",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Text(
                  "${widget.articleData['repeatcount'] ?? '0'}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(23, 191, 99, 1.0),
                  ),
                ),
                Text(
                  " 转发",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Text(
                  "${widget.articleData['likecont'] ?? '0'}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(224, 36, 94, 1.0),
                  ),
                ),
                Text(
                  " 喜欢",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          Divider(height: 0.5, color: Colors.grey.shade200),

          // 交互按钮 - 更简洁的样式
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                icon: SvgPicture.asset(
                  'lib/assets/icons/chatbubble-ellipses-outline.svg',
                  width: 16,
                  height: 16,
                  color:
                      widget.articleData['commentcount'] > 0
                          ? Color.fromRGBO(29, 161, 242, 1.0)
                          : Colors.grey[600],
                ),
                label: "评论",
                onTap: () {
                  // 评论操作
                },
              ),
              _buildActionButton(
                icon: SvgPicture.asset(
                  'lib/assets/icons/repeat-outline.svg',
                  width: 16,
                  height: 16,
                  color:
                      widget.articleData['repeatcount'] > 0
                          ? Color.fromRGBO(23, 191, 99, 1.0)
                          : Colors.grey[600],
                ),
                label: "转发",
                onTap: () {
                  // 转发操作
                },
              ),
              _buildActionButton(
                icon: Icon(
                  widget.articleData['islike'] == true
                      ? Icons.favorite
                      : Icons.favorite_border,
                  size: 16,
                  color:
                      widget.articleData['islike'] == true
                          ? Color.fromRGBO(224, 36, 94, 1.0)
                          : Colors.grey[600],
                ),
                label: "喜欢",
                onTap: () {
                  // 喜欢操作
                },
              ),
            ],
          ),

          Divider(height: 0.5, color: Colors.grey.shade200),

          // 评论区域
          if (articleComments.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
                  child: Text(
                    "评论",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                CommentWidget(comments: articleComments),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({required Widget icon, required String count}) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 4),
        Text(count, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }
}
