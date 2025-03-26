import 'package:flutter/material.dart';
import '../models/like_notification.dart';

class LikeNotificationCard extends StatelessWidget {
  final LikeNotification notification;
  final VoidCallback? onTap;

  const LikeNotificationCard({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 帖子信息
            Text(
              notification.postTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              notification.postPreview,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // 用户信息行
            Row(
              children: [
                // 头像
                CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage(notification.user.avatar),
                ),
                const SizedBox(width: 12),

                // 用户基本信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.user.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${notification.user.occupation} · ${notification.user.location}",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                // 点赞时间
                Text(
                  _formatTime(notification.likedAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return "${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }
}
