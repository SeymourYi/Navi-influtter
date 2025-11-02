import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import '../../api/smsSender.dart';
import '../../api/smsloginAPI.dart';
import '../Home/home.dart';
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

  // 生成随机6位数字验证码
  String _generateRandomCode() {
    final random = Random();
    String code = '';
    for (int i = 0; i < 6; i++) {
      code += random.nextInt(10).toString();
    }
    return code;
  }

  // 发送验证码
  Future<void> _sendSmsCode() async {
    // 验证手机号格式
    if (_phoneController.text.isEmpty || _phoneController.text.length != 11) {
      _showErrorDialog('请输入正确的手机号码');
      return;
    }

    setState(() {
      _isSendingSms = true;
      _generatedCode = _generateRandomCode(); // 生成新的验证码
    });

    try {
      final smsSenderService = SmsSenderService();
      final response = await smsSenderService.smsSender(
        _phoneController.text,
        _generatedCode, // 使用随机生成的验证码
      );

      if (response['code'] == 0) {
        // 开始倒计时
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

  // 开始倒计时
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

  // 短信登录
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 验证短信验证码
    if (_smsCodeController.text.isEmpty) {
      _showErrorDialog('请输入验证码');
      return;
    }

    // 验证验证码是否正确
    if (_smsCodeController.text != _generatedCode) {
      _showErrorDialog('验证码错误，请重新输入');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 调用短信登录API
      final smsLoginService = SmsLoginService();
      final phoneNumber = _phoneController.text;

      print('准备登录，手机号: $phoneNumber'); // 调试日志

      final response = await smsLoginService.smsLogin(phoneNumber);

      print('登录响应: $response'); // 调试日志

      if (response['code'] == 0 && response['data'] != null) {
        // 保存token
        final token = response['data'].toString();
        print('保存token: $token'); // 调试日志
        await SharedPrefsUtils.saveToken(token);

        // 重新初始化 HttpClient 以使用新token
        await HttpClient.init();

        // 获取用户信息
        final userService = UserService();
        final userInfoResponse = await userService.getUserinfo();

        print('用户信息响应: $userInfoResponse'); // 调试日志

        if (userInfoResponse['code'] == 0 && userInfoResponse['data'] != null) {
          // 保存用户信息
          await SharedPrefsUtils.saveUserInfo(userInfoResponse['data']);

          // 设置登录状态
          await SharedPrefsUtils.setBool('is_logged_in', true);

          if (!mounted) return;

          // 显示成功提示
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('登录成功'),
              duration: Duration(seconds: 1),
            ),
          );

          // 导航到主页
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

  // 显示错误对话框
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
      appBar: AppBar(title: Text('短信验证码登录'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FlutterLogo(size: 80),
              const SizedBox(height: 40),

              // 手机号输入
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: '手机号',
                  prefixIcon: Icon(Icons.phone_android),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入手机号';
                  }
                  if (value.length != 11) {
                    return '请输入11位手机号';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // 验证码输入
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _smsCodeController,
                      decoration: InputDecoration(
                        labelText: '验证码',
                        prefixIcon: Icon(Icons.verified_user),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入验证码';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 120,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _countDown < 60 && _countDown > 0
                                ? Colors.grey
                                : const Color.fromARGB(255, 126, 121, 211),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed:
                          (_countDown < 60 && _countDown > 0) || _isSendingSms
                              ? null
                              : _sendSmsCode,
                      child:
                          _isSendingSms
                              ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.0,
                                ),
                              )
                              : Text(
                                _countDown < 60 ? '${_countDown}秒' : '获取验证码',
                                style: TextStyle(fontSize: 14),
                              ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 登录按钮
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

              // 返回账号密码登录
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('返回账号密码登录'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
