import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterlearn2/api/getarticleinfoAPI.dart';
import 'articleimage.dart';
import '../components/userinfo.dart';

class Articledetail extends StatefulWidget {
  final String id;

  const Articledetail({super.key, required this.id});

  @override
  State<Articledetail> createState() => _ArticledetailState();
}

class _ArticledetailState extends State<Articledetail> {
  bool _isLiked = false;
  int _likeCount = 42;
  bool _isBookmarked = false;
  var articleInfodata; // 改为不指定类型，以便适应不同的数据结构
  List<dynamic> commentsList = []; // 添加评论列表变量
  TextEditingController _commentController = TextEditingController(); // 评论输入控制器

  @override
  void initState() {
    super.initState();
    // 检查ID是否有效
    if (widget.id == null || widget.id.isEmpty) {
      // ID为空时显示错误提示
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("错误: 没有接收到文章ID"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      });
    } else {
      // ID有效时正常获取文章信息
      print("收到文章ID: ${widget.id}");
      _fetchArticleInfo();
    }
  }

  Future<void> _fetchArticleInfo() async {
    if (widget.id == null || widget.id.isEmpty) {
      print("文章ID无效，无法获取文章信息");
      return;
    }

    try {
      print("准备获取文章ID: ${widget.id}的详情");
      GetArticleInfoService service = GetArticleInfoService();
      var result = await service.getArticleInfo(int.parse(widget.id));
      var result_comments = await service.getArticlecomment(
        int.parse(widget.id),
      );
      if (result == null || result['data'] == null) {
        print("API返回数据为空");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("获取文章详情失败: 返回数据为空"),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // 打印接收到的数据类型，帮助调试
      print("API返回data类型: ${result['data'].runtimeType}");

      // 处理评论数据
      if (result_comments != null &&
          result_comments['code'] == 0 &&
          result_comments['data'] != null) {
        print("成功获取评论数据，评论数量: ${result_comments['data'].length}");
        setState(() {
          commentsList = result_comments['data'];
        });
      } else {
        print("获取评论数据失败或评论为空");
      }

      setState(() {
        articleInfodata = result['data']; // 不进行类型转换，保持原始类型
      });

      // 根据data类型选择合适的方式显示数据长度
      String dataInfo = "";
      if (articleInfodata is List) {
        dataInfo = "数据长度: ${articleInfodata.length}";
      } else if (articleInfodata is Map) {
        dataInfo = "数据字段数: ${articleInfodata.keys.length}";
      } else {
        dataInfo = "数据类型: ${articleInfodata.runtimeType}";
      }

      print("文章详情获取成功，$dataInfo");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("成功获取文章ID: ${widget.id}的详情 ($dataInfo)"),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('获取文章详情时出错: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("获取文章详情失败: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 提取文章内容，适应不同的数据结构
    String title = "";
    String content = "加载中...";
    String nickname = "用户";
    String username = "";
    String userPic = "";
    String categoryName = "";
    String coverImg = "";
    String createTime = "刚刚";
    int likecont = 0;
    bool isLike = false;
    int commentcount = 0;
    int repeatcount = 0;

    // 如果获取到了有效的文章数据，则使用API返回的数据
    if (articleInfodata != null) {
      try {
        if (articleInfodata is Map) {
          // 使用API返回的字段
          content = articleInfodata['content'] ?? content;
          nickname = articleInfodata['nickname'] ?? nickname;
          username = articleInfodata['username'] ?? username;
          userPic = articleInfodata['userPic'] ?? userPic;
          categoryName = articleInfodata['categoryName'] ?? categoryName;
          coverImg = articleInfodata['coverImg'] ?? coverImg;
          createTime = articleInfodata['createTime'] ?? createTime;
          likecont = articleInfodata['likecont'] ?? 0;
          isLike = articleInfodata['islike'] ?? false;
          commentcount = articleInfodata['commentcount'] ?? 0;
          repeatcount = articleInfodata['repeatcount'] ?? 0;
        }
      } catch (e) {
        print("解析文章数据时出错: $e");
      }
    }

    // 整理图片URL列表
    List<String> imageUrls = [];
    if (coverImg != null && coverImg.isNotEmpty) {
      imageUrls.add(coverImg);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: categoryName.isNotEmpty ? Text(categoryName) : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        MaterialPageRoute(
                          builder: (context) => const Userinfo(),
                        ),
                      );
                    },
                    child:
                        userPic.isNotEmpty
                            ? CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(userPic),
                            )
                            : CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.grey[300],
                              child: Icon(
                                Icons.person,
                                color: Colors.grey[600],
                              ),
                            ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nickname,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "@$username · ${_formatCreateTime(createTime)}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
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
              child: Text(content, style: TextStyle(fontSize: 16, height: 1.4)),
            ),

            // Images
            if (imageUrls.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ArticleImage(imageUrls: imageUrls),
              ),

            // Stats and actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(
                    createTime,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const Spacer(),
                  if (categoryName.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        categoryName,
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(
                    icon: Icons.mode_comment_outlined,
                    count: commentcount.toString(),
                    onPressed: () {},
                  ),
                  _buildActionButton(
                    icon: Icons.repeat,
                    count: repeatcount.toString(),
                    onPressed: () {},
                  ),
                  _buildActionButton(
                    icon: isLike ? Icons.favorite : Icons.favorite_border,
                    count: likecont.toString(),
                    isActive: isLike,
                    onPressed: () {
                      setState(() {
                        _isLiked = !_isLiked;
                        _likeCount += _isLiked ? 1 : -1;
                      });
                    },
                  ),
                  _buildActionButton(
                    icon:
                        _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    onPressed: () {
                      setState(() {
                        _isBookmarked = !_isBookmarked;
                      });
                    },
                    isActive: _isBookmarked,
                  ),
                  _buildActionButton(icon: Icons.share, onPressed: () {}),
                ],
              ),
            ),

            const Divider(height: 1),

            // Replies section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${commentsList.length} 条评论",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (commentsList.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "暂无评论，快来发表你的看法吧！",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    )
                  else
                    Column(
                      children:
                          commentsList.map((comment) {
                            return _buildReplyItem(
                              userPic: comment['userPic'] ?? "",
                              name: comment['nickname'] ?? "用户",
                              handle: "@${comment['username'] ?? ''}",
                              content: comment['content'] ?? "",
                              time: comment['uptonowTime'] ?? "",
                              likes: "${comment['likecont'] ?? 0}",
                            );
                          }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Reply input
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: "发表评论...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.send, color: Colors.blue),
                      onPressed: _submitComment,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    String? count,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? Colors.red : Colors.grey[600],
            ),
            if (count != null) ...[
              const SizedBox(width: 4),
              Text(
                count,
                style: TextStyle(
                  color: isActive ? Colors.red : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReplyItem({
    required String userPic,
    required String name,
    required String handle,
    required String content,
    required String time,
    required String likes,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          userPic.isNotEmpty
              ? CircleAvatar(radius: 20, backgroundImage: NetworkImage(userPic))
              : CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, color: Colors.grey[600]),
              ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    Text(handle, style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(width: 4),
                    Text("· $time", style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
                const SizedBox(height: 4),
                Text(content),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      likes,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 格式化时间方法
  String _formatCreateTime(String timeStr) {
    try {
      // 简单格式化，只返回月份和日期
      if (timeStr == null || timeStr.isEmpty) return "刚刚";

      DateTime dateTime = DateTime.parse(timeStr);
      DateTime now = DateTime.now();

      if (now.difference(dateTime).inMinutes < 60) {
        return "${now.difference(dateTime).inMinutes}分钟前";
      } else if (now.difference(dateTime).inHours < 24) {
        return "${now.difference(dateTime).inHours}小时前";
      } else if (now.difference(dateTime).inDays < 30) {
        return "${now.difference(dateTime).inDays}天前";
      } else {
        return "${dateTime.month}月${dateTime.day}日";
      }
    } catch (e) {
      print("日期格式化出错: $e");
      return timeStr;
    }
  }

  void _submitComment() {
    String commentText = _commentController.text.trim();
    if (commentText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("评论内容不能为空")));
      return;
    }

    // 这里可以添加实际的评论提交API调用
    print("提交评论: $commentText");

    // 模拟添加新评论到列表
    setState(() {
      Map<String, dynamic> newComment = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'username': 'user',
        'nickname': '当前用户',
        'userPic': '', // 这里可以设置当前用户的头像
        'content': commentText,
        'createTime': DateTime.now().toString(),
        'uptonowTime': '刚刚',
        'likecont': 0,
      };
      commentsList.insert(0, newComment); // 将新评论添加到列表顶部
    });

    // 清空输入框
    _commentController.clear();

    // 显示成功提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("评论发表成功"), backgroundColor: Colors.green),
    );
  }
}
