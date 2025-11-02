import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Navi/page/Home/home.dart';
import 'dart:async';
import 'dart:math';
import '../../api/smsSender.dart';
import '../../api/smsloginAPI.dart';
import '../../Store/storeutils.dart';
import '../../utils/mydio.dart';
import '../../api/userAPI.dart';

class SmsLoginPage extends StatefulWidget {
  const SmsLoginPage({Key? key}) : super(key: key);

  @override
  _SmsLoginPageState createState() => _SmsLoginPageState();
}

class _SmsLoginPageState extends State<SmsLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _smsCodeController = TextEditingController();

  bool _isLoading = false;
  bool _isSendingSms = false;

  int _countDown = 60;
  Timer? _timer;
  String _generatedCode = '';

  @override
  void dispose() {
    _phoneController.dispose();
    _smsCodeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String _generateRandomCode() {
    final random = Random();
    String code = '';
    for (int i = 0; i < 6; i++) {
      code += random.nextInt(10).toString();
    }
    return code;
  }

  Future<void> _sendSmsCode() async {
    if (_phoneController.text.isEmpty || _phoneController.text.length != 11) {
      _showErrorDialog('请输入正确的手机号码');
      return;
    }

    setState(() {
      _isSendingSms = true;
      _generatedCode = _generateRandomCode();
    });

    try {
      final smsSenderService = SmsSenderService();
      final response = await smsSenderService.smsSender(
        _phoneController.text,
        _generatedCode,
      );

      if (response['code'] == 0) {
        _startCountDown();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('验证码已发送！')));
      } else {
        throw Exception(response['msg'] ?? '发送验证码失败');
      }
    } catch (e) {
      _showErrorDialog(
        e.toString().contains('Exception:')
            ? e.toString().split('Exception: ')[1]
            : '网络错误，请检查网络连接',
      );
    } finally {
      setState(() {
        _isSendingSms = false;
      });
    }
  }

  void _startCountDown() {
    setState(() {
      _countDown = 60;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_countDown > 0) {
          _countDown--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_smsCodeController.text.isEmpty) {
      _showErrorDialog('请输入验证码');
      return;
    }

    if (_smsCodeController.text != _generatedCode) {
      _showErrorDialog('验证码错误，请重新输入');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final smsLoginService = SmsLoginService();
      final phoneNumber = _phoneController.text;

      final response = await smsLoginService.smsLogin(phoneNumber);

      if (response['code'] == 0 && response['data'] != null) {
        final token = response['data'].toString();
        await SharedPrefsUtils.saveToken(token);

        await HttpClient.init();

        final userService = UserService();
        final userInfoResponse = await userService.getUserinfo();

        if (userInfoResponse['code'] == 0 && userInfoResponse['data'] != null) {
          await SharedPrefsUtils.saveUserInfo(userInfoResponse['data']);

          await SharedPrefsUtils.setBool('is_logged_in', true);

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('登录成功'),
              duration: Duration(seconds: 1),
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyHome()),
          );
        } else {
          throw Exception(userInfoResponse['msg'] ?? '获取用户信息失败');
        }
      } else {
        throw Exception(response['msg'] ?? '登录失败');
      }
    } catch (e) {
      print('登录错误: $e');
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

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red[600],
                size: 24,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '操作失败',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            errorMessage,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6201E7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                elevation: 0,
              ),
              child: const Text(
                '确定',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.black87, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '短信验证码登录',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),

                  // 标题
                  Text(
                    "验证码登录",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "使用手机验证码快速登录",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),

                  SizedBox(height: 40),

                  // 手机号输入框
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(color: Colors.black87, fontSize: 16),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                    ],
                    decoration: InputDecoration(
                      hintText: "手机号",
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF6F6BCC), width: 2),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),

                  SizedBox(height: 24),

                  // 验证码输入框和获取按钮
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _smsCodeController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: Colors.black87, fontSize: 16),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          decoration: InputDecoration(
                            hintText: "验证码",
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 16,
                            ),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF6F6BCC), width: 2),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      SizedBox(
                        width: 100,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (_countDown < 60 && _countDown > 0)
                                ? Colors.grey[300]
                                : Color(0xFF6201E7),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: (_countDown < 60 && _countDown > 0) ||
                                  _isSendingSms
                              ? null
                              : _sendSmsCode,
                          child: _isSendingSms
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.0,
                                  ),
                                )
                              : Text(
                                  _countDown < 60 ? '$_countDown秒' : '获取验证码',
                                  style: TextStyle(fontSize: 14),
                                ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 48),

                  // 登录按钮
                  Container(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6201E7), // 主题色
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "登录",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: 40),

                  // 分隔线
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[300])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "其他登录方式",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[300])),
                    ],
                  ),

                  SizedBox(height: 24),

                  // 返回密码登录按钮
                  Container(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: BorderSide(color: Colors.grey[400]!, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        "密码登录",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


