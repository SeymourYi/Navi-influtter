import 'dart:async';
import 'package:Navi/Store/storeutils.dart';
import 'package:Navi/api/userAPI.dart';
import 'package:flutter/material.dart';

class ChatItem extends StatefulWidget {
  const ChatItem({super.key, required this.chatWithusername});

  final chatWithusername;
  @override
  State<ChatItem> createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatItem> {
  dynamic _selectedCharacter = {};

  dynamic _chatWithCharacter = {};

  UserService server = UserService();

  Future<void> _fetchUserInfo() async {
    final userInfo = await SharedPrefsUtils.getUserInfo();
    var res = await server.getsomeUserinfo(userInfo!["username"]);
    var res2 = await server.getsomeUserinfo(widget.chatWithusername);
    setState(() {
      _selectedCharacter = res["data"];
      _chatWithCharacter = res2["data"];
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('与 ${_chatWithCharacter["nickname"]} 的私聊'),
        centerTitle: true,
      ),

      // body: Container(
      //   child: ListView.builder(
      //     controller: _scrollController,
      //     itemCount: messages.length,
      //     padding: const EdgeInsets.all(8.0),
      //     itemBuilder: (context, index) {
      //       final message = messages[index];
      //       return _buildMessageItem(message);
      //     },
      //   ),
      // ),
      // _buildMessageInput(),
    );
  }
}
