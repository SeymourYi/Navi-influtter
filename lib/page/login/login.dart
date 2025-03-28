import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutterlearn2/page/Home/home.dart';
import '../../api/loginAPI.dart';
import '../../Store/storeutils.dart';
import '../../api/userAPI.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  List<dynamic> articleList = [];
  var token = '';
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _login() async {
    _getToken();
  }

  Future<void> _getToken() async {
    LoginService loginservice = LoginService();
    UserService userService = UserService();
    try {
      var response = await loginservice.Login(
        _emailController.text,
        _passwordController.text,
      );
      if (response['code'] == 0) {
        SharedPrefsUtils.setString(token, response['data']);
        var aaaa = await userService.getUserinfo();
        SharedPrefsUtils.saveUserInfo(aaaa['data']);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MyHome()), // 替换为你的主界面Widget
          (route) => false, // 清除所有之前的路由
        );
      } else {
        print(response['msg']);
      }
    } catch (e) {
      print("e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FlutterLogo(size: 100),
              const SizedBox(height: 40),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: '手机号',
                  prefixIcon: Icon(Icons.phone_android_sharp),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: '密码',
                  prefixIcon: Icon(Icons.text_fields_rounded),
                  border: OutlineInputBorder(),
                ),
                obscureText: false,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('登录', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Add forgot password functionality
                },
                child: const Text('忘记密码?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
