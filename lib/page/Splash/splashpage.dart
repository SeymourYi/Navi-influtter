import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final int x; // 接收外部传入的x值
  final Widget aScreen; // 界面A
  final Widget bScreen; // 界面B
  final Widget cScreen; // 界面C
  const SplashScreen({
    Key? key,
    required this.x,
    required this.aScreen,
    required this.bScreen,
    required this.cScreen,
  }) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAndNavigate();
  }

  @override
  void didUpdateWidget(SplashScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当widget.x发生变化时重新检查跳转
    if (oldWidget.x != widget.x) {
      _checkAndNavigate();
    }
  }

  void _checkAndNavigate() {
    // 仅当x不为0时才执行跳转
    if (widget.x == 0) {
      return; // 正在加载中，不跳转
    }

    Future.delayed(Duration(milliseconds: 100), () {
      if (!mounted) return;

      if (widget.x == 1) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => widget.aScreen),
        );
      } else if (widget.x == 2) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => widget.bScreen),
        );
      } else if (widget.x == 3) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => widget.cScreen),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(), // 加载指示器
            SizedBox(height: 20),
            Text('加载中...', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
