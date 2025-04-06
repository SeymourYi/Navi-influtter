import 'package:flutter/material.dart';

class CommentWidget extends StatelessWidget {
  final List<dynamic> comments;

  const CommentWidget({Key? key, required this.comments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        return _buildCommentItem(comment);
      },
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
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
                      children: [
                        Text(
                          comment['nickname'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          comment['uptonowTime'],
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Comment Text
                    Text(
                      comment['content'],
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    // Action Buttons
                    // _buildActionButtons(comment),
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
}
