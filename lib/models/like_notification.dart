class LikeNotification {
  final String postTitle;
  final String postPreview;
  final UserInfo user;
  final DateTime likedAt;

  const LikeNotification({
    required this.postTitle,
    required this.postPreview,
    required this.user,
    required this.likedAt,
  });
}

class UserInfo {
  final String avatar;
  final String name;
  final String location;
  final String occupation;
  final DateTime joinDate;
  final String bio;

  const UserInfo({
    required this.avatar,
    required this.name,
    required this.location,
    required this.occupation,
    required this.joinDate,
    required this.bio,
  });
}
