import 'package:flutter/material.dart';
import 'package:Navi/page/Home/home.dart';
import 'package:Navi/page/login/smsregister.dart';
import 'package:Navi/page/login/smslogin.dart';
import 'package:Navi/page/login/user_agreement.dart';
import 'dart:io';
import '../../api/loginAPI.dart';
import '../../Store/storeutils.dart';
import '../../api/userAPI.dart';
import '../../utils/mydio.dart';

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
  bool _agreementAccepted = false;
  List<dynamic> articleList = [];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // 检查是否已经接受过协议
    _checkAgreementStatus();
  }

  // 检查协议状态并显示对话框
  Future<void> _checkAgreementStatus() async {
    // 可以添加本地存储检查逻辑，这里简化为首次进入都显示
    bool hasAccepted =
        await SharedPrefsUtils.getBool('agreement_accepted') ?? false;

    if (!hasAccepted && mounted) {
      // 延迟显示对话框，确保界面已完全加载
      Future.delayed(const Duration(milliseconds: 500), () {
        _showAgreementDialog();
      });
    } else {
      setState(() {
        _agreementAccepted = true;
      });
    }
  }

  // 显示用户协议对话框
  void _showAgreementDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('隐私政策'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('欢迎使用Navi！在使用前，请阅读并同意我们的隐私政策：'),
                  SizedBox(height: 16),
                  Text('1. 我们会收集您的手机号等必要个人信息，用于账号登录和服务提供。'),
                  SizedBox(height: 8),
                  Text('2. 我们使用腾讯云短信SDK进行短信验证，极光推送SDK进行消息推送。'),
                  SizedBox(height: 8),
                  Text('3. 您的个人信息将安全存储在中国境内，不会进行跨境传输。'),
                  SizedBox(height: 8),
                  Text('4. 我们采取多种安全措施保护您的个人信息安全。'),
                  SizedBox(height: 16),
                  Text('请点击"同意"继续使用，或点击"不同意"退出应用。'),
                  SizedBox(height: 8),
                  Text('点击"查看完整政策"可查看详细内容。'),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // 如果用户不同意，退出应用
                exit(0);
              },
              child: const Text('不同意'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserAgreementPage(),
                  ),
                );
              },
              child: const Text('查看完整政策'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 126, 121, 211),
              ),
              onPressed: () async {
                // 保存用户同意状态
                await SharedPrefsUtils.setBool('agreement_accepted', true);
                setState(() {
                  _agreementAccepted = true;
                });
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('同意'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _login() async {
    // 确保用户已同意协议
    if (!_agreementAccepted) {
      _showAgreementDialog();
      return;
    }

    _getToken();
  }

  Future<void> _getToken() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorDialog('请输入手机号和密码');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. 登录获取token
      final loginService = LoginService();
      final response = await loginService.Login(
        _emailController.text,
        _passwordController.text,
      );

      print('登录响应: $response'); // 调试日志

      if (response['code'] == 0 && response['data'] != null) {
        // 2. 保存token
        final token = response['data'].toString();
        print('保存token: $token'); // 调试日志
        await SharedPrefsUtils.saveToken(token);

        // 3. 重新初始化 HttpClient 以使用新token
        await HttpClient.init();

        // 4. 获取用户信息
        final userService = UserService();
        final userInfoResponse = await userService.getUserinfo();

        print('用户信息响应: $userInfoResponse'); // 调试日志

        if (userInfoResponse['code'] == 0 && userInfoResponse['data'] != null) {
          // 5. 保存用户信息
          await SharedPrefsUtils.saveUserInfo(userInfoResponse['data']);

          // 6. 显示成功提示并设置登录状态
          await SharedPrefsUtils.setBool('is_logged_in', true);

          if (!mounted) return;

          // 7. 显示成功提示
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('登录成功'),
              duration: Duration(seconds: 1),
            ),
          );

          // 8. 使用替换路由而不是移除所有路由
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MyHome()),
            );
          }
        } else {
          throw Exception(userInfoResponse['msg'] ?? '获取用户信息失败');
        }
      } else {
        throw Exception(response['msg'] ?? '登录失败');
      }
    } catch (e) {
      print('登录错误: $e'); // 调试日志
      // 清理可能保存的token
      await SharedPrefsUtils.clearToken();
      if (mounted) {
        _showErrorDialog(
          e.toString().contains('Exception:')
              ? e.toString().split('Exception: ')[1]
              : '网络错误，请检查网络连接',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 显示登录成功对话框
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // 1.2秒后自动关闭对话框
        Future.delayed(Duration(milliseconds: 1200), () {
          Navigator.of(context).pop();
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 60),
                SizedBox(height: 15),
                Text(
                  '登录成功',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  '欢迎回来',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 显示错误对话框
  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 10),
              Text('登录失败'),
            ],
          ),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                '确定',
                style: TextStyle(
                  color: const Color.fromARGB(255, 126, 121, 211),
                ),
              ),
            ),
          ],
        );
      },
    );
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 126, 121, 211),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: _isLoading ? null : _login,
                  child:
                      _isLoading
                          ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.0,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('登录中...', style: TextStyle(fontSize: 16)),
                            ],
                          )
                          : Text('登录', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      // 忘记密码功能
                    },
                    child: const Text('忘记密码?'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SmsLoginPage()),
                      );
                    },
                    child: const Text('短信验证码登录'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SmsRegisterPage(),
                        ),
                      );
                    },
                    child: const Text('注册账号'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserAgreementPage(),
                        ),
                      );
                    },
                    child: const Text('隐私政策'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
