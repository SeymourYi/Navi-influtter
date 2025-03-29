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
                  const Text(
                    "24 replies",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildReplyItem(
                    avatar: "assets/images/user_avatar.png",
                    name: "张三",
                    handle: "@zhangsan",
                    content: "这篇文章很有启发！独立开发确实需要坚持",
                    time: "2m",
                    likes: "12",
                  ),
                  _buildReplyItem(
                    avatar: "assets/images/user_avatar.png",
                    name: "李四",
                    handle: "@lisi",
                    content: "期待后续的分享！希望能看到更多这样的内容",
                    time: "10m",
                    likes: "8",
                  ),
                  _buildReplyItem(
                    avatar: "assets/images/user_avatar.png",
                    name: "王五",
                    handle: "@wangwu",
                    content: "已经分享给我的团队了，大家都很受启发",
                    time: "30m",
                    likes: "24",
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
              const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage("assets/images/user_avatar.png"),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Tweet your reply",
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
    required String avatar,
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
          CircleAvatar(
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
}
