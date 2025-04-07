import 'package:Navi/api/emailAPI.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChineseSocialMediaPage extends StatefulWidget {
  const ChineseSocialMediaPage({Key? key}) : super(key: key);

  @override
  State<ChineseSocialMediaPage> createState() => _ChineseSocialMediaPageState();
}

class _ChineseSocialMediaPageState extends State<ChineseSocialMediaPage> {
  EmailService service = EmailService();
  List<dynamic> emailList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getEmailList();
  }

  Future<void> getEmailList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username') ?? '';
    try {
      var response = await service.getEmailList(int.parse(username));
      if (response['code'] == 0) {
        setState(() {
          emailList = response['data'] ?? [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching email list: $e');
    }
  }

  String _formatDate(String? dateTime) {
    if (dateTime == null) return '未知日期';
    try {
      DateTime dt = DateTime.parse(dateTime);
      return '${dt.month}月${dt.day}日';
    } catch (e) {
      return dateTime;
    }
  }

  String _getMessageType(String? type) {
    switch (type) {
      case 'reArticle':
        return '转发';
      case 'comment':
        return '评论';
      default:
        return '消息';
    }
  }

  IconData _getMessageIcon(String? type) {
    switch (type) {
      case 'reArticle':
        return Icons.repeat;
      case 'comment':
        return Icons.comment;
      default:
        return Icons.notifications;
    }
  }

  Color _getMessageColor(String? type) {
    switch (type) {
      case 'reArticle':
        return Colors.green;
      case 'comment':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("消息"),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.email))],
        centerTitle: true,
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : emailList.isEmpty
              ? Center(child: Text('暂无消息'))
              : Column(
                children: [
                  Expanded(
                    child: ListView(
                      children:
                          emailList.map((email) {
                            return _buildMessageItem(
                              day: _formatDate(email['createTime']),
                              icon: _getMessageIcon(email['type']),
                              iconColor: _getMessageColor(email['type']),
                              message: _getMessageType(email['type']),
                              description: email['uptonow'] ?? '刚刚',
                              username: email['senderNickName'] ?? '未知用户',
                              userTag:
                                  '@${email['senderUserName'] ?? 'unknown'}',
                              userContent: email['newArticleContent'] ?? '无内容',
                              location: email['senderLocate'] ?? '未知地点',
                              tag: email['senderJob'] ?? '未知职业',
                              date: email['senderJoinDate'] ?? '未知加入日期',
                              bottomText:
                                  email['type'] == 'comment'
                                      ? '原文: ${email['oldArticleContent'] ?? '无内容'}'
                                      : null,
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildMessageItem({
    required String day,
    required IconData icon,
    required Color iconColor,
    required String message,
    required String description,
    required String username,
    required String userTag,
    required String userContent,
    required String location,
    required String tag,
    required String date,
    String? bottomText,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(day, style: TextStyle(color: Colors.grey, fontSize: 14)),
              Spacer(),
              Icon(Icons.mail_outline, color: Colors.grey),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: iconColor),
                  SizedBox(width: 4),
                  Text(message, style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(color: Colors.grey, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Row(
                        children: [
                          Text(
                            username,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 4),
                          Text(
                            userTag,
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                      subtitle: Text(userContent),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            location,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          SizedBox(width: 16),
                          Icon(Icons.label, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            tag,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          SizedBox(width: 16),
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 4),
                          Text(
                            date,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (bottomText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(bottomText, style: TextStyle(fontSize: 14)),
                ),
            ],
          ),
        ),
        Divider(height: 1),
      ],
    );
  }
}
