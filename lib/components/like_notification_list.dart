import 'package:flutter/material.dart';
import '../models/like_notification.dart';
import 'like_notification_card.dart';
import 'user_profile_dialog.dart';

class LikeNotificationList extends StatelessWidget {
  final List<LikeNotification> notifications;
  final Function(UserInfo)? onFollowUser;

  const LikeNotificationList({
    super.key,
    required this.notifications,
    this.onFollowUser,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      separatorBuilder: (context, index) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return LikeNotificationCard(
          notification: notification,
          onTap: () => _showUserProfile(context, notification.user),
        );
      },
    );
  }

  void _showUserProfile(BuildContext context, UserInfo user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => UserProfileDialog(
            user: user,
            onFollow: () {
              Navigator.pop(context);
              onFollowUser?.call(user);
            },
          ),
    );
  }
}
