import 'package:Navi/Store/storeutils.dart';
import 'package:Navi/api/emailAPI.dart';
import 'package:Navi/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool isRead = false;

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
        return Icons.favorite_rounded;
      case 'comment':
        return Icons.chat_bubble_rounded;
      case 'reArticle':
        return Icons.repeat_rounded;
      default:
        return Icons.bookmark_rounded;
    }
  }

  Color _getTypeColor() {
    switch (widget.email['type']) {
      case 'like':
        return Colors.redAccent;
      case 'comment':
        return Colors.blueAccent;
      case 'reArticle':
        return Colors.greenAccent.shade700;
      default:
        return Colors.amberAccent.shade700;
    }
  }

  String _getTypeText() {
    switch (widget.email['type']) {
      case 'like':
        return ' 被喜欢了';
      case 'comment':
        return ' 被评论了';
      case 'reArticle':
        return ' 被转发了';
      default:
        return ' 被收藏了';
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

  //阅读所有邮件
  Future<void> _readallEmail() async {
    final userInfo = await SharedPrefsUtils.getUserInfo();
    await emailService.readAllEmail(int.parse(userInfo!['username']));
    //邮件数清零
    Provider.of<NotificationProvider>(
      context,
      listen: false,
    ).setnotificationcount(0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //点击邮件
      onTap: () {
        _playAnimation();
        _readsomeEmail();
      },
      //点击邮件动画
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.12),
                spreadRadius: 1,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getTypeColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getTypeIcon(),
                            color: _getTypeColor(),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontFamily: 'PingFangSC-Regular',
                                          color: Colors.black87,
                                          height: 1.3,
                                        ),
                                        children: [
                                          TextSpan(
                                            text:
                                                widget
                                                            .email['oldArticleContent']
                                                            .length >
                                                        16
                                                    ? '${widget.email['oldArticleContent'].substring(0, 16)}...'
                                                    : widget
                                                        .email['oldArticleContent'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          TextSpan(
                                            text: _getTypeText(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (!widget.email['isRead'])
                                    Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.redAccent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.email['uptonow'],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // 个人信息卡片
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: _getTypeColor().withOpacity(0.03),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: _getTypeColor().withOpacity(0.1),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Transform.translate(
                                          offset: const Offset(
                                            -5,
                                            -15,
                                          ), // 向上移动 4 像素
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: _getTypeColor()
                                                    .withOpacity(0.2),
                                                width: 2,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: _getTypeColor()
                                                      .withOpacity(0.1),
                                                  blurRadius: 8,
                                                  spreadRadius: 1,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),

                                            child: CircleAvatar(
                                              radius: 18,
                                              backgroundImage: NetworkImage(
                                                widget.email['senderUserPic'],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  widget
                                                      .email['senderNickName'],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  '@${widget.email['senderId']}',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            // BIO
                                            if (widget.email['senderBio'] !=
                                                    null &&
                                                widget
                                                    .email['senderBio']
                                                    .isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 8,
                                                ),
                                                child: Text(
                                                  widget.email['senderBio'],
                                                  style: TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 13,
                                                    height: 1.4,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    if (widget.email['senderJob'] != null ||
                                        widget.email['senderLocate'] != null ||
                                        widget.email['senderJoinDate'] != null)
                                      Container(
                                        width: double.infinity,
                                        constraints: BoxConstraints(
                                          maxWidth:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.65,
                                        ),
                                        child: Wrap(
                                          spacing: 8,
                                          runSpacing: 4,
                                          children: [
                                            if (widget.email['senderJob'] !=
                                                null)
                                              _buildInfoChip(
                                                Icons.work_outline_rounded,
                                                widget.email['senderJob'],
                                              ),
                                            if (widget.email['senderLocate'] !=
                                                null)
                                              _buildInfoChip(
                                                Icons.location_on_outlined,
                                                widget.email['senderLocate'],
                                              ),
                                            if (widget
                                                    .email['senderJoinDate'] !=
                                                null)
                                              _buildInfoChip(
                                                Icons.calendar_today_outlined,
                                                widget.email['senderJoinDate'],
                                              ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (widget.email['type'] == 'comment' ||
                        widget.email['type'] == 'reArticle')
                      Container(
                        margin: const EdgeInsets.only(top: 12, left: 44),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getTypeColor().withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getTypeColor().withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          widget.email['newArticleContent'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                            height: 1.4,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      constraints: BoxConstraints(maxWidth: 120),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.black87),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
