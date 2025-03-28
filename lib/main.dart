import 'package:flutter/material.dart';
import 'package:flutterlearn2/page/Home/home.dart';
import 'package:flutterlearn2/page/login/login.dart';
import 'package:flutterlearn2/utils/mydio.dart';

void main(List<String> args) {
  HttpClient.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Navi",
      home: LoginPage(),
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 255, 255, 255),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(backgroundColor: Colors.white),
      ),
    );
  }
}
