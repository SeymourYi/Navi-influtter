class PostArticle {
  final String avatar;
  final String username;
  final String content;
  final String categoryId;
  final String createUserId;
  final String createUserName;
  final String location;
  final String occupation;
  final DateTime joinDate;
  final String bio;
  const PostArticle({
    required this.avatar,
    required this.username,
    required this.location,
    required this.content,
    required this.categoryId,
    required this.createUserId,
    required this.createUserName,
    required this.occupation,
    required this.joinDate,
    required this.bio,
  });
}
