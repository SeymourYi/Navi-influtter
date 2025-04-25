import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Articletest extends StatefulWidget {
  const Articletest({super.key});

  @override
  State<Articletest> createState() => _ArticletestState();
}

class _ArticletestState extends State<Articletest> {
  // 静态测试数据
  final Map<String, dynamic> articleData = {
    'id': 1,
    'username': 'testuser',
    'nickname': '测试用户',
    'userPic': 'https://via.placeholder.com/100',
    'content': '这是一条测试文章内容，用于UI测试和展示。这里可以放置较长的文本以测试文本溢出和显示效果。',
    'coverImg': 'https://via.placeholder.com/400x300',
    'uptonowTime': '2小时前',
    'commentcount': 5,
    'repeatcount': 2,
    'likecont': 10,
    'islike': false,
    'userShare': false,
  };

  bool isLiked = false;
  int likeCount = 10;

  @override
  void initState() {
    super.initState();
    // 初始化静态数据的点赞状态
    isLiked = articleData['islike'] ?? false;
    likeCount = articleData['likecont'] ?? 0;
  }

  void _handleLike() {
    setState(() {
      isLiked = !isLiked;
      likeCount = isLiked ? likeCount + 1 : likeCount - 1;
    });
  }

  void _navigateToArticleDetail() {
    // 测试版本中仅显示提示信息
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('进入文章详情页'), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('文章测试')),
      body: Card(
        elevation: 0,
        margin: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
        child: InkWell(
          onTap: _navigateToArticleDetail,
          splashColor: Colors.grey.withOpacity(0.1),
          highlightColor: Colors.grey.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左侧头像
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('进入用户主页'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 22,
                    backgroundImage: CachedNetworkImageProvider(
                      articleData['userPic'],
                    ),
                  ),
                ),

                // 右侧内容部分
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 用户信息行
                        Row(
                          children: [
                            Text(
                              "${articleData['nickname']}",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "@${articleData['username']}",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              " · ${articleData['uptonowTime']}",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),

                        // 文章内容区域
                        Padding(
                          padding: const EdgeInsets.only(top: 2, bottom: 6),
                          child: Text(
                            "${articleData['content']}",
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.3,
                              color: Colors.black,
                            ),
                          ),
                        ),

                        // 文章图片
                        if (articleData['coverImg'] != "")
                          GestureDetector(
                            onTap: () {
                              // 查看大图的逻辑
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('查看大图'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                articleData['coverImg'],
                                fit: BoxFit.cover,
                                height: 200,
                                width: double.infinity,
                              ),
                            ),
                          ),

                        // 互动栏
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // 评论按钮
                              InkWell(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('发表评论'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: _buildActionButton(
                                    icon:
                                        articleData['commentcount'] != null &&
                                                articleData['commentcount'] > 0
                                            ? Icons.chat_bubble
                                            : Icons.chat_bubble_outline,
                                    count: articleData['commentcount'],
                                    color: Color.fromRGBO(29, 161, 242, 1.0),
                                  ),
                                ),
                              ),

                              // 转发按钮
                              InkWell(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('转发文章'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: _buildActionButton(
                                    icon: Icons.repeat,
                                    count: articleData['repeatcount'],
                                    color: Color.fromRGBO(23, 191, 99, 1.0),
                                  ),
                                ),
                              ),

                              // 点赞按钮
                              InkWell(
                                onTap: _handleLike,
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: _buildLikeButton(),
                                ),
                              ),

                              // 空白占位，保持按钮分布均匀
                              SizedBox(width: 8),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 构建交互按钮
  Widget _buildActionButton({
    required IconData icon,
    int? count,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: count != null && count > 0 ? color : Colors.grey[600],
        ),
        if (count != null && count > 0)
          Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text(
              "$count",
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }

  // 点赞按钮
  Widget _buildLikeButton() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isLiked ? Icons.favorite : Icons.favorite_border,
          size: 16,
          color:
              isLiked
                  ? const Color.fromRGBO(224, 36, 94, 1.0)
                  : Colors.grey[600],
        ),
        if (likeCount > 0)
          Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text(
              "$likeCount",
              style: TextStyle(
                fontSize: 13,
                color:
                    isLiked
                        ? const Color.fromRGBO(224, 36, 94, 1.0)
                        : Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }
}
