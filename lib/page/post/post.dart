import 'package:flutter/material.dart';

class Post extends StatefulWidget {
  const Post({super.key});

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.blue),
      child: Padding(
        padding: EdgeInsets.only(top: 4, right: 12),
        child: Text(
          "发表界面",
          style: TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontFamily: "Inter-Regular",
          ),
        ),
      ),
    );
  }
}
