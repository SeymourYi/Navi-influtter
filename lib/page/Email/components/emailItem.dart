import 'package:Navi/Store/storeutils.dart';
import 'package:Navi/api/emailAPI.dart';
import 'package:Navi/api/getarticleinfoAPI.dart';
import 'package:Navi/page/post/post.dart';
import 'package:Navi/components/articledetail.dart';
import 'package:Navi/providers/notification_provider.dart';
import 'package:Navi/utils/route_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Navi/utils/viewport_image.dart';

class Emailitem extends StatefulWidget {
  const Emailitem({super.key, required this.email});
  final dynamic email;

  @override
  State<Emailitem> createState() => _EmailitemState();
}

class _EmailitemState extends State<Emailitem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  EmailService emailService = EmailService();
  GetArticleInfoService _articleInfoService = GetArticleInfoService();
  bool isRead = false;
  Map<String, dynamic>? _currentUser;
  bool isLikeLoading = false;
  bool isReplyLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // 初始化已读状态
    isRead = widget.email['isRead'] ?? false;

    // 获取当前用户信息
    _loadCurrentUserInfo();
  }

  // 加载当前用户信息
  Future<void> _loadCurrentUserInfo() async {
    try {
      final userInfo = await SharedPrefsUtils.getUserInfo();
      if (userInfo != null && userInfo['username'] != null) {
        setState(() {
          _currentUser = userInfo;
        });
      }
    } catch (e) {
      print('获取用户信息失败: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 播放点击动画
  void _playAnimation() async {
    await _controller.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      _controller.reverse();
    }
  }

  IconData _getTypeIcon() {
    switch (widget.email['type']) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.chat_bubble_outline;
      case 'reArticle':
        return Icons.repeat;
      default:
        return Icons.bookmark_outline;
    }
  }

  Color _getTypeColor() {
    switch (widget.email['type']) {
      case 'like':
        return Colors.red;
      case 'comment':
        return Color(0xFF6201E7);
      case 'reArticle':
        return Colors.green;
      default:
        return Colors.amber;
    }
  }

  String _getTypeText() {
    switch (widget.email['type']) {
      case 'like':
        return '赞了你的帖子';
      case 'comment':
        return '评论了你的帖子';
      case 'reArticle':
        return '转发了你的帖子';
      default:
        return '收藏了你的帖子';
    }
  }

  //阅读某一个邮件
  Future<void> _readsomeEmail() async {
    if (isRead) return; // 如果已经阅读过，不再执行

    try {
      final userInfo = await SharedPrefsUtils.getUserInfo();
      if (userInfo == null) return;

      // 调用API标记邮件为已读
      await emailService.readsomeonenotification(
        widget.email['id'].toString(),
        userInfo['username'].toString(),
      );

      // 更新本地状态
      setState(() {
        isRead = true;
        widget.email['isRead'] = true; // 更新邮件对象状态
      });

      // 更新全局通知计数
      Provider.of<NotificationProvider>(context, listen: false).markAsRead();
    } catch (e) {
      print('阅读邮件失败: $e');
    }
  }

  // 跳转到文章详情页
  void _navigateToArticleDetail() async {
    try {
      // 根据通知类型确定要跳转的文章ID
      String? articleId;
      if (widget.email['type'] == 'like' ||
          widget.email['type'] == 'reArticle') {
        // 点赞和转发通知：跳转到被操作的原文章
        articleId = widget.email['oldArticleId']?.toString();
      } else if (widget.email['type'] == 'comment') {
        // 评论通知：跳转到原文章（被评论的文章）
        articleId = widget.email['oldArticleId']?.toString();
      }

      if (articleId == null || articleId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('无法获取文章信息'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      // 获取文章详情
      final articleResult = await _articleInfoService.getArticleInfo(
        int.parse(articleId),
      );

      if (articleResult != null &&
          articleResult['code'] == 0 &&
          articleResult['data'] != null) {
        // 预加载文章中的图片，限制等待时间
        try {
          final articleData = articleResult['data'];
          List<String> imageUrls = [];
          if (articleData['coverImgList'] != null &&
              articleData['coverImgList'] is List &&
              (articleData['coverImgList'] as List).isNotEmpty) {
            imageUrls = List<String>.from(articleData['coverImgList']);
          } else if (articleData['coverImg'] != null &&
              articleData['coverImg'].toString().isNotEmpty) {
            imageUrls = [articleData['coverImg'].toString()];
          }

          if (imageUrls.isNotEmpty) {
            await Future.wait(
              imageUrls.map(
                (url) => ViewportAwareImage.precacheNetworkImage(url, context),
              ),
            ).timeout(const Duration(milliseconds: 600), onTimeout: () => []);
          }
        } catch (e) {}

        // 导航到文章详情页
        Navigator.push(
          context,
          RouteUtils.slideFromRight(
            Articledetail(articleData: articleResult['data']),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('获取文章详情失败'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('跳转到文章详情失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('跳转失败: ${e.toString()}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // 处理回复评论
  void _handleReply() async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先登录后再回复'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // 设置加载状态
    setState(() {
      isReplyLoading = true;
    });

    try {
      // 对于评论通知，newArticleId 是评论的ID，oldArticleId 是原文章的ID
      // 需要传递评论数据以便回复
      final commentData = {
        'id': widget.email['newArticleId']?.toString(),
        'content': widget.email['newArticleContent'] ?? '',
        'username': widget.email['senderId']?.toString(),
        'nickname': widget.email['senderNickName'] ?? '',
        'userPic': widget.email['senderUserPic'] ?? '',
      };

      // 导航到评论回复页面
      Navigator.push(
        context,
        RouteUtils.slideFromBottom(
          PostPage(
            type: '回复',
            articelData: commentData,
            uparticledata: {'id': widget.email['oldArticleId']?.toString()},
          ),
        ),
      );
    } catch (e) {
      print('跳转到评论页面失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('处理回复失败: ${e.toString()}'),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      // 重置加载状态
      if (mounted) {
        setState(() {
          isReplyLoading = false;
        });
      }
    }
  }

  // 处理点赞功能
  void _handleLike() async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先登录后再点赞'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // 设置加载状态
    setState(() {
      isLikeLoading = true;
    });

    try {
      String? articleId;

      // 根据通知类型确定要点赞的ID
      if (widget.email['type'] == 'like') {
        // 点赞通知：点赞原文章（可以再次点赞或取消点赞）
        articleId = widget.email['oldArticleId']?.toString();
      } else if (widget.email['type'] == 'comment') {
        // 评论通知：点赞评论本身（newArticleId 是评论ID）
        articleId = widget.email['newArticleId']?.toString();
      } else if (widget.email['type'] == 'reArticle') {
        // 转发通知：点赞原文章
        articleId = widget.email['oldArticleId']?.toString();
      }

      if (articleId == null || articleId.isEmpty) {
        throw Exception('无法获取文章ID');
      }

      // 调用API进行点赞
      final result = await _articleInfoService.likesomearticle(
        _currentUser!['username'],
        articleId,
      );

      if (result != null && result['code'] == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('操作成功'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        String errorMsg = result != null ? result['msg'] ?? '操作失败' : '操作失败';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('点赞操作失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('操作失败: ${e.toString()}'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // 重置加载状态
      if (mounted) {
        setState(() {
          isLikeLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //点击邮件 - 跳转到文章详情页并标记为已读
      onTap: () {
        _playAnimation();
        _readsomeEmail();
        _navigateToArticleDetail();
      },
      //点击邮件动画
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: isRead ? Colors.white : Colors.blue.shade50.withOpacity(0.3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 用户头像 - 方形圆角
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CachedNetworkImage(
                  imageUrl: widget.email['senderUserPic'] ?? '',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(
                        width: 40,
                        height: 40,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.person,
                          size: 20,
                          color: Colors.grey,
                        ),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        width: 40,
                        height: 40,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.person,
                          size: 20,
                          color: Colors.grey,
                        ),
                      ),
                ),
              ),
              const SizedBox(width: 12),
              // 通知内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 用户信息和操作类型
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                              children: [
                                TextSpan(
                                  text: widget.email['senderNickName'] ?? '用户',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text: ' ${_getTypeText()}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isRead)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Color(0xFF6201E7),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // 时间
                    Text(
                      widget.email['uptonow'] ?? '',
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 8),
                    // 被操作的文章内容预览 - 可点击跳转
                    GestureDetector(
                      onTap: _navigateToArticleDetail,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          widget.email['oldArticleContent'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    // 评论或转发的内容
                    if (widget.email['type'] == 'comment' ||
                        widget.email['type'] == 'reArticle')
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            widget.email['newArticleContent'] ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    // 操作按钮
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          // 回复按钮（仅评论类型显示）
                          if (widget.email['type'] == 'comment')
                            InkWell(
                              onTap: isReplyLoading ? null : _handleReply,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isReplyLoading)
                                      SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Color(0xFF6201E7),
                                              ),
                                        ),
                                      )
                                    else
                                      Icon(
                                        Icons.reply_outlined,
                                        size: 16,
                                        color: Color(0xFF6201E7),
                                      ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "回复",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF6201E7),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          // 点赞按钮（点赞通知不显示，只显示评论和转发的）
                          if (widget.email['type'] != 'like') ...[
                            if (widget.email['type'] == 'comment')
                              const SizedBox(width: 12),
                            InkWell(
                              onTap: isLikeLoading ? null : _handleLike,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isLikeLoading)
                                      SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.red,
                                              ),
                                        ),
                                      )
                                    else
                                      const Icon(
                                        Icons.favorite_border,
                                        size: 16,
                                        color: Colors.red,
                                      ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.email['type'] == 'reArticle'
                                          ? '点赞'
                                          : '喜欢',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 操作类型图标
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getTypeColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_getTypeIcon(), size: 20, color: _getTypeColor()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
