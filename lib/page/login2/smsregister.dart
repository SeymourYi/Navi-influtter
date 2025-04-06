import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import '../../api/smsSender.dart';
import '../../api/registerAPI.dart';
import '../Home/home.dart';
import '../../Store/storeutils.dart';
import '../../utils/mydio.dart';
import '../../api/userAPI.dart';
import '../../api/loginAPI.dart';

class SmsRegisterPage extends StatefulWidget {
  const SmsRegisterPage({Key? key}) : super(key: key);

  @override
  _SmsRegisterPageState createState() => _SmsRegisterPageState();
}

class _SmsRegisterPageState extends State<SmsRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _smsCodeController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isSendingSms = false;

  int _countDown = 60;
  Timer? _timer;
  String _generatedCode = ''; // 存储生成的验证码

  // 生成随机6位数字验证码
  String _generateRandomCode() {
    final random = Random();
    String code = '';
    for (int i = 0; i < 6; i++) {
      code += random.nextInt(10).toString();
    }
    return code;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _smsCodeController.dispose();
    _passwordController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // 验证是否全是中文字符
  bool _isChineseOnly(String text) {
    final RegExp chineseRegExp = RegExp(r'^[\u4e00-\u9fa5]+$');
    return chineseRegExp.hasMatch(text);
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
        ).showSnackBar(SnackBar(content: Text('验证码已发送: $_generatedCode')));
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

  // 注册账号
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 验证短信验证码
    if (_smsCodeController.text.isEmpty) {
      _showErrorDialog('请输入验证码');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 验证验证码是否正确
      if (_smsCodeController.text != _generatedCode) {
        throw Exception('验证码错误，请重新输入');
      }

      // 调用注册API
      final registerService = RegisterService();
      final response = await registerService.register(
        _phoneController.text,
        _passwordController.text,
      );

      if (response['code'] == 0) {
        // 注册成功后自动登录
        await _loginAfterRegister();
      } else {
        throw Exception(response['msg'] ?? '注册失败');
      }
    } catch (e) {
      _showErrorDialog(
        e.toString().contains('Exception:')
            ? e.toString().split('Exception: ')[1]
            : '注册失败，请稍后重试',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 注册成功后自动登录
  Future<void> _loginAfterRegister() async {
    try {
      // 1. 登录获取token
      final loginService = LoginService();
      final response = await loginService.Login(
        _phoneController.text,
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
              content: Text('注册并登录成功'),
              duration: Duration(seconds: 1),
            ),
          );

          // 8. 导航到主页
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
              : '注册成功，但自动登录失败，请手动登录',
        );
        // 注册成功但登录失败，返回登录页面
        Navigator.pop(context);
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
            borderRadius: BorderRadius.circular(10),
          ),
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 10),
              Text('操作失败'),
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
      appBar: AppBar(title: Text('手机验证码注册'), centerTitle: true),
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

              const SizedBox(height: 16),

              // 中文密码输入
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: '密码（仅限中文）',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  helperText: '请输入纯中文密码',
                ),
                obscureText: false, // 密码不掩盖
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入密码';
                  }
                  if (!_isChineseOnly(value)) {
                    return '密码只能包含中文字符';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // 注册按钮
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
                  onPressed: _isLoading ? null : _register,
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
                              Text('注册中...', style: TextStyle(fontSize: 16)),
                            ],
                          )
                          : Text('注册', style: TextStyle(fontSize: 16)),
                ),
              ),

              const SizedBox(height: 16),

              // 返回登录
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('已有账号？返回登录'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
