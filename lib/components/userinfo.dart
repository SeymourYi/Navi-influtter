import 'package:flutter/material.dart';

class Userinfo extends StatefulWidget {
  const Userinfo({super.key});

  @override
  State<Userinfo> createState() => _UserinfoState();
}

class _UserinfoState extends State<Userinfo> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.blue),
      child: Padding(
        padding: EdgeInsets.only(top: 4, right: 12),
        child: Text(
          "我是主界面",
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
