import 'package:Navi/api/articleAPI.dart';
import 'package:Navi/page/post/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../api/getarticleinfoAPI.dart'; // 导入点赞API服务
import '../Store/storeutils.dart'; // 导入用户信息存储工具
import '../page/UserInfo/userhome.dart'; // 导入用户主页

class CommentWidget extends StatefulWidget {
  final List<dynamic> comments;
  final dynamic
  uparticledata; // Consider using a specific type instead of dynamic
  const CommentWidget({Key? key, this.uparticledata, required this.comments})
    : super(key: key);

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  String username = ''; // 存储当前用户名
  Map<String, dynamic>? _currentUser; // 当前用户信息
  Map<String, bool> isLikedMap = {}; // 评论点赞状态映射
  Map<String, int> likeCountMap = {}; // 评论点赞数量映射
  Map<String, bool> isLikeLoadingMap = {}; // 点赞加载状态映射
  Map<String, List<dynamic>> commentLikersMap = {}; // 评论点赞用户列表映射
  ArticleService articleService = ArticleService();
  @override
  void initState() {
    super.initState();
    // 初始化点赞状态
    _initLikeStatus();
    // 先获取当前用户信息
    _loadCurrentUserInfo().then((_) {
      // 在获取用户信息后，为每个评论加载点赞者列表
      _loadAllCommentLikers();
    });
  }

  // 初始化所有评论的点赞状态
  void _initLikeStatus() {
    for (var comment in widget.comments) {
      if (comment != null && comment['id'] != null) {
        String commentId = comment['id'].toString();
        isLikedMap[commentId] = comment['isLiked'] ?? false;
        likeCountMap[commentId] = comment['likeCount'] ?? 0;
        isLikeLoadingMap[commentId] = false;
        // 初始化空的点赞用户列表
        commentLikersMap[commentId] = [];
      }
    }
  }

  // 加载当前用户信息
  Future<void> _loadCurrentUserInfo() async {
    try {
      final userInfo = await SharedPrefsUtils.getUserInfo();
      if (userInfo != null && userInfo['username'] != null) {
        setState(() {
          username = userInfo['username'];
          _currentUser = userInfo;
        });
        // 在获取用户信息后，检查用户是否已点赞各评论
        _checkUserLikeStatus();
      }
    } catch (e) {
      print("加载用户信息出错: $e");
    }
  }

  // 检查当前用户是否已点赞各评论
  void _checkUserLikeStatus() {
    if (username.isEmpty) return;

    for (var comment in widget.comments) {
      if (comment != null && comment['id'] != null) {
        String commentId = comment['id'].toString();
        // 检查当前评论的点赞者列表中是否包含当前用户
        if (commentLikersMap.containsKey(commentId) &&
            commentLikersMap[commentId]!.any(
              (liker) => liker['username'] == username,
            )) {
          // 如果包含，则设置为已点赞状态
          setState(() {
            isLikedMap[commentId] = true;
          });
        }
      }
    }
  }

  // 加载所有评论的点赞者列表
  void _loadAllCommentLikers() {
    for (var comment in widget.comments) {
      if (comment != null && comment['id'] != null) {
        _loadCommentLikers(comment['id'].toString());
      }
    }
  }

  // 加载单个评论的点赞者列表
  Future<void> _loadCommentLikers(String commentId) async {
    try {
      final result = await articleService.getArticlelikers(commentId);
      if (result != null && result['data'] != null) {
        setState(() {
          commentLikersMap[commentId] = result['data'];

          // 检查当前用户是否在点赞列表中
          if (username.isNotEmpty) {
            bool userLiked = commentLikersMap[commentId]!.any(
              (liker) => liker['username'] == username,
            );
            // 更新点赞状态
            isLikedMap[commentId] = userLiked;
          }
        });
      }
    } catch (e) {
      print("加载评论点赞者列表出错: $e");
    }
  }

  // 处理评论点赞
  void _handleCommentLike(Map<String, dynamic> comment) async {
    // 检查评论ID是否存在
    if (comment == null || comment['id'] == null) {
      return;
    }

    String commentId = comment['id'].toString();

    // 如果用户名为空或点赞请求正在处理中，则不执行操作
    if (username.isEmpty || isLikeLoadingMap[commentId] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(username.isEmpty ? '请先登录后再点赞' : '正在处理，请稍候...'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // 先在UI上直接反映点赞状态变化，提高响应速度
    bool newLikedState = !(isLikedMap[commentId] ?? false);
    int newLikeCount =
        (likeCountMap[commentId] ?? 0) + (newLikedState ? 1 : -1);

    // 在UI上立即应用变更
    setState(() {
      isLikedMap[commentId] = newLikedState;
      likeCountMap[commentId] = newLikeCount;
      isLikeLoadingMap[commentId] = true;
    });

    // 更新点赞用户列表
    if (!newLikedState) {
      // 取消点赞，从列表中移除当前用户
      setState(() {
        if (commentLikersMap[commentId] != null) {
          commentLikersMap[commentId]!.removeWhere(
            (user) => user["username"] == username,
          );
        }
      });
    } else {
      // 点赞，添加当前用户到列表
      if (_currentUser != null &&
          commentLikersMap[commentId] != null &&
          !commentLikersMap[commentId]!.any(
            (user) => user["username"] == username,
          )) {
        setState(() {
          commentLikersMap[commentId]!.add({
            "username": username,
            "userPic": _currentUser!["userPic"],
          });
        });
      }
    }

    try {
      // 使用API调用 - 这里使用与文章点赞相同的API调用
      // 实际项目中应根据后端接口调整为评论点赞的专用接口
      GetArticleInfoService service = GetArticleInfoService();

      var result = await service.likesomearticle(
        username,
        commentId, // 使用评论ID而不是文章ID
      );

      // 处理API响应
      if (result != null && result['code'] == 0) {
        // 更新原始数据，保证UI一致性
        if (comment != null) {
          comment['isLiked'] = newLikedState;
          comment['likeCount'] = newLikeCount;
        }

        // API成功后重新加载点赞用户列表，确保数据与服务器同步
        _loadCommentLikers(commentId);
      } else {
        // API失败，回滚状态
        setState(() {
          isLikedMap[commentId] = !newLikedState;
          likeCountMap[commentId] =
              isLikedMap[commentId]! ? newLikeCount + 1 : newLikeCount - 1;

          // 回滚点赞者列表
          if (isLikedMap[commentId]!) {
            // 重新添加用户到列表
            if (_currentUser != null &&
                commentLikersMap[commentId] != null &&
                !commentLikersMap[commentId]!.any(
                  (user) => user["username"] == username,
                )) {
              commentLikersMap[commentId]!.add({
                "username": username,
                "userPic": _currentUser!["userPic"],
              });
            }
          } else {
            // 从列表中移除用户
            if (commentLikersMap[commentId] != null) {
              commentLikersMap[commentId]!.removeWhere(
                (user) => user["username"] == username,
              );
            }
          }
        });

        // 显示错误信息
        String errorMsg = '操作失败';
        if (result != null) {
          errorMsg += ': ${result['msg'] ?? result['message'] ?? '未知错误'}';
        } else {
          errorMsg += ': 服务器无响应';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), duration: Duration(seconds: 3)),
        );
      }
    } catch (e) {
      // 处理异常，回滚状态
      setState(() {
        isLikedMap[commentId] = !newLikedState;
        likeCountMap[commentId] =
            isLikedMap[commentId]! ? newLikeCount + 1 : newLikeCount - 1;

        // 回滚点赞者列表
        if (isLikedMap[commentId]!) {
          // 重新添加用户到列表
          if (_currentUser != null &&
              commentLikersMap[commentId] != null &&
              !commentLikersMap[commentId]!.any(
                (user) => user["username"] == username,
              )) {
            commentLikersMap[commentId]!.add({
              "username": username,
              "userPic": _currentUser!["userPic"],
            });
          }
        } else {
          // 从列表中移除用户
          if (commentLikersMap[commentId] != null) {
            commentLikersMap[commentId]!.removeWhere(
              (user) => user["username"] == username,
            );
          }
        }
      });

      // 提取错误信息
      String errorMessage = e.toString();
      if (errorMessage.length > 100) {
        errorMessage = '${errorMessage.substring(0, 97)}...';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('点赞失败: $errorMessage'),
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      // 重置加载状态
      setState(() {
        isLikeLoadingMap[commentId] = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.comments.length,
      itemBuilder: (context, index) {
        final comment = widget.comments[index];
        return _buildCommentItem(comment);
      },
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    String commentId = comment['id']?.toString() ?? '';
    bool isLiked = isLikedMap[commentId] ?? false;
    int likeCount = likeCountMap[commentId] ?? 0;
    bool isLikeLoading = isLikeLoadingMap[commentId] ?? false;
    List<dynamic> commentLikers = commentLikersMap[commentId] ?? [];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Avatar
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(comment['userPic']),
              ),
              const SizedBox(width: 12),
              // Comment Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Info and Time
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline, // 基线对齐
                      textBaseline: TextBaseline.alphabetic, // 使用字母基线
                      children: [
                        Text(
                          comment['nickname'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (comment['tonickname'] != null)
                          Text(
                            "回复${comment['tonickname']}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Comment Text
                    Text(
                      comment['content'],
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    // Action Buttons
                    _buildActionButtons(comment),

                    // 点赞用户显示区域
                    if (commentLikers.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(3),
                        ),
                        width: MediaQuery.of(context).size.width * 0.8,
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.only(top: 8, bottom: 4),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.favorite_border_outlined,
                                  size: 18,
                                  color: const Color.fromARGB(64, 86, 105, 145),
                                ),
                                SizedBox(width: 5),
                                Row(
                                  children: List.generate(
                                    commentLikers.length,
                                    (index) => GestureDetector(
                                      onTap: () {
                                        // 导航到用户页面
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder:
                                                (context) => UserHome(
                                                  userId:
                                                      commentLikers[index]['username'],
                                                ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        margin: EdgeInsets.only(right: 4),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                          image: DecorationImage(
                                            image: NetworkImage(
                                              commentLikers[index]['userPic'],
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          // Show shared content if exists
        ],
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> comment) {
    String commentId = comment['id']?.toString() ?? '';
    bool isLiked = isLikedMap[commentId] ?? false;
    bool isLikeLoading = isLikeLoadingMap[commentId] ?? false;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          child: Text(
            comment["uptonowTime"],
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.normal,
            ),
          ),
        ),
        Spacer(),

        // _buildActionButton(
        //   icon: 'lib/assets/icons/repeat-outline.svg',
        //   label: '转发',
        //   showDivider: false,
        //   comment: comment,
        // ),
        _buildActionButton(
          icon: 'lib/assets/icons/chatbubble-ellipses-outline.svg',
          label: '回复',
          showDivider: true,
          comment: comment,
        ),
        _buildActionButton(
          icon: 'lib/assets/icons/Vector (9).svg',
          label: '赞',
          showDivider: true,
          comment: comment,
          isLiked: isLiked,
          isLikeLoading: isLikeLoading,
          onTap: () => _handleCommentLike(comment),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String icon,
    required String label,
    required bool showDivider,
    required Map<String, dynamic> comment,
    bool isLiked = false,
    bool isLikeLoading = false,
    VoidCallback? onTap,
  }) {
    // 设置不同按钮的颜色
    Color iconColor;
    Color textColor;

    if (label == '赞') {
      iconColor =
          isLiked ? const Color.fromRGBO(224, 36, 94, 1.0) : Colors.grey[700]!;
      textColor =
          isLiked ? const Color.fromRGBO(224, 36, 94, 1.0) : Colors.grey[700]!;
    } else if (label == '回复') {
      iconColor = Color.fromRGBO(29, 161, 242, 1.0); // 蓝色
      textColor = Colors.grey[700]!;
    } else if (label == '转发') {
      iconColor = Color.fromRGBO(23, 191, 99, 1.0); // 绿色
      textColor = Colors.grey[700]!;
    } else {
      iconColor = Colors.grey[700]!;
      textColor = Colors.grey[700]!;
    }

    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque, // 确保整个区域可点击
          onTap:
              onTap ??
              () {
                if (label == "回复") {
                  print('点击了 $label');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => PostPage(
                            type: '回复',
                            articelData: comment,
                            uparticledata: widget.uparticledata,
                          ),
                    ),
                  );
                }
              },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                if (label == '赞' && isLikeLoading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color.fromRGBO(224, 36, 94, 1.0),
                      ),
                    ),
                  )
                else
                  SvgPicture.asset(
                    icon,
                    width: 16,
                    height: 16,
                    color: iconColor,
                  ),
                SizedBox(width: 4),
                Text(label, style: TextStyle(fontSize: 12, color: textColor)),
                if (label == '赞' &&
                    (likeCountMap[comment['id']?.toString() ?? ''] ?? 0) > 0)
                  Padding(
                    padding: EdgeInsets.only(left: 2),
                    child: Text(
                      "${likeCountMap[comment['id']?.toString() ?? ''] ?? 0}",
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            isLiked
                                ? const Color.fromRGBO(224, 36, 94, 1.0)
                                : textColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4),
            height: 12,
            width: 1,
            color: Colors.grey.withOpacity(0.3),
          ),
      ],
    );
  }
}
