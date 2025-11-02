import 'package:flutter/material.dart';
import 'package:Navi/api/userAPI.dart';
import 'package:Navi/api/smsSender.dart';
import 'package:Navi/Store/storeutils.dart';

/// 修改密码页面
/// 参考 capacitor 项目的 changePassword.vue 实现
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final UserService _userService = UserService();
  final SmsSenderService _smsSenderService = SmsSenderService();
  final _formKey = GlobalKey<FormState>();

  // 修改方式：'password' 密码验证，'sms' 短信验证码
  String _changeMethod = 'password';

  // 表单数据
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _verificationCodeController = TextEditingController();

  // 状态管理
  bool _isChanging = false;
  String? _error;
  bool _isSuccess = false;

  // 短信验证码相关
  bool _isSendingCode = false;
  int _countdown = 0;
  String _generatedCode = '';
  bool _isCodeSent = false;

  String? _username;
  String? _phoneNumber;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    // 添加监听器以实时更新按钮状态
    _currentPasswordController.addListener(_updateFormState);
    _newPasswordController.addListener(_updateFormState);
    _confirmPasswordController.addListener(_updateFormState);
    _phoneNumberController.addListener(_updateFormState);
    _verificationCodeController.addListener(_updateFormState);
  }

  void _updateFormState() {
    setState(() {
      // 触发UI更新以反映表单验证状态
    });
  }

  @override
  void dispose() {
    _currentPasswordController.removeListener(_updateFormState);
    _newPasswordController.removeListener(_updateFormState);
    _confirmPasswordController.removeListener(_updateFormState);
    _phoneNumberController.removeListener(_updateFormState);
    _verificationCodeController.removeListener(_updateFormState);
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _phoneNumberController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    try {
      final userInfo = await SharedPrefsUtils.getUserInfo();
      if (userInfo != null) {
        setState(() {
          _username = userInfo['username'];
          _phoneNumber = userInfo['phoneNumber'];
          if (_phoneNumber != null) {
            _phoneNumberController.text = _phoneNumber!;
          }
        });
      }
    } catch (e) {
      print('加载用户信息失败: $e');
    }
  }

  // 发送验证码
  Future<void> _sendVerificationCode() async {
    if (_phoneNumberController.text.trim().isEmpty) {
      setState(() {
        _error = '请输入手机号';
      });
      return;
    }

    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(_phoneNumberController.text.trim())) {
      setState(() {
        _error = '请输入正确的手机号';
      });
      return;
    }

    setState(() {
      _isSendingCode = true;
      _error = null;
    });

    try {
      // 生成4位随机验证码
      _generatedCode = (1000 + (9999 - 1000) * (DateTime.now().millisecondsSinceEpoch % 10000) / 10000).toString().split('.')[0].padLeft(4, '0');
      _generatedCode = _generatedCode.substring(0, 4);
      print('生成的验证码: $_generatedCode');

      // 调用发送验证码的API
      var res = await _smsSenderService.smsSender(
        _phoneNumberController.text.trim(),
        _generatedCode,
      );

      if (res != null && res['code'] == 0) {
        setState(() {
          _isSendingCode = false;
          _isCodeSent = true;
          _countdown = 60;
        });

        // 开始倒计时
        _startCountdown();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('验证码已发送')),
        );
      } else {
        setState(() {
          _isSendingCode = false;
          _error = res?['msg'] ?? '发送失败，请稍后重试';
        });
      }
    } catch (e) {
      setState(() {
        _isSendingCode = false;
        _error = '网络错误，请检查网络连接后重试';
      });
      print('发送验证码失败: $e');
    }
  }

  // 开始倒计时
  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _countdown--;
        });
        return _countdown > 0;
      }
      return false;
    });
  }

  // 验证密码格式（只允许纯中文诗句）
  bool _isPureChinese(String text) {
    return RegExp(r'^[\u4e00-\u9fa5]+$').hasMatch(text);
  }

  // 表单验证
  bool get _isFormValid {
    if (_changeMethod == 'password') {
      final currentPassword = _currentPasswordController.text.trim();
      final newPassword = _newPasswordController.text.trim();
      final confirmPassword = _confirmPasswordController.text.trim();
      
      // 检查所有字段是否填写
      if (currentPassword.isEmpty || 
          newPassword.isEmpty || 
          confirmPassword.isEmpty) {
        return false;
      }
      
      // 检查新密码和确认密码是否一致
      if (newPassword != confirmPassword) {
        return false;
      }
      
      // 检查新密码和当前密码是否不同
      if (newPassword == currentPassword) {
        return false;
      }
      
      // 检查新密码是否为纯中文
      if (!_isPureChinese(newPassword)) {
        return false;
      }
      
      return true;
    } else {
      return _phoneNumberController.text.trim().isNotEmpty &&
          _verificationCodeController.text.trim().isNotEmpty &&
          _newPasswordController.text.trim().isNotEmpty &&
          _confirmPasswordController.text.trim().isNotEmpty &&
          _newPasswordController.text == _confirmPasswordController.text &&
          _isPureChinese(_newPasswordController.text) &&
          _verificationCodeController.text == _generatedCode;
    }
  }

  // 修改密码
  Future<void> _changePassword() async {
    if (!_isFormValid) {
      setState(() {
        _error = '请填写完整信息';
      });
      return;
    }

    if (_username == null) {
      setState(() {
        _error = '用户信息异常，请重新登录';
      });
      return;
    }

    setState(() {
      _isChanging = true;
      _error = null;
    });

    try {
      Map<String, dynamic>? res;

      if (_changeMethod == 'password') {
        // 密码验证方式
        res = await _userService.changePassword(
          username: _username!,
          oldPassword: _currentPasswordController.text.trim(),
          newPassword: _newPasswordController.text.trim(),
        );
      } else {
        // 短信验证码方式
        res = await _userService.changePassword(
          username: _username!,
          oldPassword: '', // 短信验证码方式不需要旧密码
          newPassword: _newPasswordController.text.trim(),
          phoneNumber: _phoneNumberController.text.trim(),
        );
      }

      if (res != null && res['code'] == 0) {
        setState(() {
          _isChanging = false;
          _isSuccess = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('密码修改成功！')),
        );

        // 2秒后返回
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      } else {
        setState(() {
          _isChanging = false;
          _error = res?['msg'] ?? '修改失败，请稍后重试';
        });
      }
    } catch (e) {
      setState(() {
        _isChanging = false;
        _error = '网络错误，请检查网络连接后重试';
      });
      print('修改密码失败: $e');
    }
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
          '修改密码',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 修改方式选择
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: Text('密码验证'),
                      selected: _changeMethod == 'password',
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _changeMethod = 'password';
                            _error = null;
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: Text('短信验证'),
                      selected: _changeMethod == 'sms',
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _changeMethod = 'sms';
                            _error = null;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),

              // 密码验证方式表单
              if (_changeMethod == 'password') ...[
                TextFormField(
                  controller: _currentPasswordController,
                  decoration: InputDecoration(
                    labelText: '当前密码',
                    border: OutlineInputBorder(),
                    helperText: '请输入您当前的密码',
                  ),
                  obscureText: false,
                  onChanged: (_) => setState(() {}),
                ),
                SizedBox(height: 16),
              ],

              // 短信验证码方式表单
              if (_changeMethod == 'sms') ...[
                TextFormField(
                  controller: _phoneNumberController,
                  decoration: InputDecoration(
                    labelText: '手机号',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  enabled: _phoneNumber == null, // 如果已有手机号则禁用
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _verificationCodeController,
                        decoration: InputDecoration(
                          labelText: '验证码',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: (_isSendingCode || _countdown > 0) ? null : _sendVerificationCode,
                      child: Text(_countdown > 0 ? '$_countdown秒' : '发送验证码'),
                    ),
                  ],
                ),
                SizedBox(height: 16),
              ],

              // 新密码
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: '新密码',
                  border: OutlineInputBorder(),
                  helperText: _newPasswordController.text.isNotEmpty && 
                              !_isPureChinese(_newPasswordController.text)
                          ? '密码只能包含中文字符'
                          : '请输入中文诗句作为密码',
                  helperMaxLines: 2,
                ),
                obscureText: false,
                onChanged: (value) {
                  setState(() {});
                  if (!_isPureChinese(value) && value.isNotEmpty) {
                    // 可以在这里添加实时验证提示
                  }
                },
              ),

              SizedBox(height: 16),

              // 确认新密码
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: '确认新密码',
                  border: OutlineInputBorder(),
                  helperText: _newPasswordController.text.isNotEmpty && 
                              _confirmPasswordController.text.isNotEmpty &&
                              _newPasswordController.text != _confirmPasswordController.text
                          ? '两次输入的密码不一致'
                          : null,
                  helperMaxLines: 2,
                ),
                obscureText: false,
                onChanged: (_) => setState(() {}),
              ),

              SizedBox(height: 24),

              // 验证状态提示
              if (_changeMethod == 'password' && 
                  _currentPasswordController.text.isNotEmpty &&
                  _newPasswordController.text.isNotEmpty &&
                  _confirmPasswordController.text.isNotEmpty &&
                  !_isFormValid) ...[
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange[700], size: 18),
                          SizedBox(width: 8),
                          Text(
                            '请检查以下条件：',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[800],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      if (!_isPureChinese(_newPasswordController.text))
                        Text('• 新密码必须为纯中文', style: TextStyle(color: Colors.orange[800])),
                      if (_newPasswordController.text != _confirmPasswordController.text)
                        Text('• 新密码和确认密码必须一致', style: TextStyle(color: Colors.orange[800])),
                      if (_newPasswordController.text == _currentPasswordController.text && 
                          _newPasswordController.text.isNotEmpty)
                        Text('• 新密码必须与当前密码不同', style: TextStyle(color: Colors.orange[800])),
                    ],
                  ),
                ),
                SizedBox(height: 16),
              ],

              // 示例提示
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '示例：',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('春风又绿江南岸明月何时照我还'),
                    SizedBox(height: 4),
                    Text('山重水复疑无路柳暗花明又一村'),
                    SizedBox(height: 4),
                    Text('落红不是无情物化作春泥更护花'),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // 提交按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isChanging || !_isFormValid) ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_isChanging || !_isFormValid) 
                        ? Colors.grey[300] 
                        : Color(0xFF7461CA),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isChanging
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          '修改密码',
                          style: TextStyle(
                            color: (_isChanging || !_isFormValid) 
                                ? Colors.grey[600] 
                                : Colors.white,
                          ),
                        ),
                ),
              ),

              // 调试信息（开发时可以显示，帮助排查问题）
              if (false) ...[
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('调试信息:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('当前密码: ${_currentPasswordController.text.trim().isNotEmpty}'),
                      Text('新密码: ${_newPasswordController.text.trim().isNotEmpty}'),
                      Text('确认密码: ${_confirmPasswordController.text.trim().isNotEmpty}'),
                      Text('密码匹配: ${_newPasswordController.text == _confirmPasswordController.text}'),
                      Text('密码不同: ${_newPasswordController.text != _currentPasswordController.text}'),
                      Text('纯中文: ${_isPureChinese(_newPasswordController.text)}'),
                      Text('表单有效: $_isFormValid'),
                    ],
                  ),
                ),
              ],

              // 错误提示
              if (_error != null) ...[
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.red[600]),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(color: Colors.red[800]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // 成功提示
              if (_isSuccess) ...[
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[600]),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '密码修改成功！',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '您的密码已更新',
                              style: TextStyle(color: Colors.green[700]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

