import 'package:flutter/material.dart';
import '../models/like_notification.dart';

class UserProfileDialog extends StatelessWidget {
  final UserInfo user;
  final VoidCallback onFollow;

  const UserProfileDialog({
    super.key,
    required this.user,
    required this.onFollow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 拖拽指示器
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 用户头像和基本信息
          Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage(user.avatar),
              ),
              const SizedBox(height: 16),
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                user.occupation,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                user.location,
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 详细信息
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileItem("加入时间", _formatDate(user.joinDate)),
                const SizedBox(height: 12),
                _buildProfileItem("个人简介", user.bio),
              ],
            ),
          ),

          const Spacer(),

          // 操作按钮
          ElevatedButton(
            onPressed: onFollow,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("关注"),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(content, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}年${date.month}月${date.day}日";
  }
}
