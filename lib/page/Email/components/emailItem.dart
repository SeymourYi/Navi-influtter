import 'package:flutter/material.dart';

class Emailitem extends StatefulWidget {
  const Emailitem({super.key, required this.email});
  final dynamic email;

  @override
  State<Emailitem> createState() => _EmailitemState();
}

class _EmailitemState extends State<Emailitem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.favorite, color: Colors.red, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'PingFangSC-Regular',
                            color: Colors.black87,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  widget.email['oldArticleContent'].length > 10
                                      ? '${widget.email['oldArticleContent'].substring(0, 10)}...'
                                      : widget.email['oldArticleContent'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: ' 被喜欢了'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 个人信息卡片
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 头像
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(
                                widget.email['senderUserPic'],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        widget.email['senderNickName'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '@${widget.email['senderId']}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  // BIO
                                  if (widget.email['senderBio'] != null &&
                                      widget.email['senderBio'].isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        widget.email['senderBio'],
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 13,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                  // info
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
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.email['senderJob'] != null)
                  _buildInfoChip(Icons.work_outline, widget.email['senderJob']),
                if (widget.email['senderLocate'] != null)
                  _buildInfoChip(
                    Icons.location_on_outlined,
                    widget.email['senderLocate'],
                  ),
                if (widget.email['senderJoinDate'] != null)
                  _buildInfoChip(
                    Icons.calendar_today_outlined,
                    widget.email['senderJoinDate'],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
        ],
      ),
    );
  }
}
