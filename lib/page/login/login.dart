import 'package:Navi/page/Home/home.dart';
import 'package:Navi/page/login/smslogin.dart';
import 'package:Navi/page/login/smsregister.dart';
import 'package:flutter/material.dart';
import 'package:Navi/page/Home/home.dart';
import 'package:Navi/page/login/smsregister.dart';
import 'package:Navi/page/login/smslogin.dart';
import 'package:Navi/page/login/user_agreement.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:giffy_dialog/giffy_dialog.dart' hide LinearGradient;
import 'package:lottie/lottie.dart';
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
    // bool hasAccepted =
    //     await SharedPrefsUtils.getBool('agreement_accepted') ?? false;

    // if (!hasAccepted && mounted) {
    if (mounted) {
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
        return Dialog(
          //宽度设置
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3), // 更小的圆角
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: 50), // 修改水平内边距，使对话框更窄
          backgroundColor: Colors.white,
          elevation: 0,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.75, // 设置为屏幕宽度的75%
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  '请阅读下方隐私政策',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF5D5D5D),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F2), // 浅灰色背景
                    borderRadius: BorderRadius.circular(4), // 更小的圆角
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        height: 400, // 设置一个固定高度以实现滚动
                        child: SingleChildScrollView(
                          child: Text(
                            '隐私政策\n\n更新日期: 2024/12/6\n生效日期: 2024/12/6\n\n导言\n\nNavi 是一款由 商丘千寻微梦信息科技有限公司 （以下简称 "我们"）提供的产品。 您在使用我们的服务时，我们可能会收集和使用您的相关信息。我们希望通过本《隐私政策》向您说明，在使用我们的服务时，我们如何收集、使用、储存和分享这些信息，以及我们为您提供的访问、更新、控制和保护这些信息的方式。\n\n本《隐私政策》与您所使用的 Navi 服务息息相关，希望您仔细阅读，在需要时，按照本《隐私政策》的指引，作出您认为适当的选择。本《隐私政策》中涉及的相关技术词汇，我们尽量以简明扼要的表述，并提供进一步说明的链接，以便您的理解。\n\n您使用或继续使用我们的服务，即意味着同意我们按照本《隐私政策》收集、使用、储存和分享您的相关信息。\n\n如对本《隐私政策》或相关事宜有任何问题，请通过 19137056165 与我们联系。\n\n我们收集的信息\n我们或我们的第三方合作伙伴提供服务时，可能会收集、储存和使用下列与您有关的信息。如果您不提供相关信息，可能无法注册成为我们的用户或无法享受我们提供的某些服务，或者无法达到相关服务拟达到的效果。\n\n手机号 您在注册账户时，向我们提供个人手机号，我们通过发送短信的方式验证。手机号用于绑定您的账号，用于日后的登录，以及密码找回等\n\n职业，位置，加入时间 进入 Navi 后你可以自定义编辑职业，位置， 不要求真实性，此为个人自愿填写。用于在个人信息等界面的展示。加入时间为账号注册的时间，也是用于在个人信息等界面的展示。\n\n信息的存储\n2.1 信息存储的方式和期限\n我们会通过安全的方式存储您的信息，包括本地存储（例如利用 APP 进行数据缓存）、数据库和服务器日志。\n一般情况下，我们只会在为实现服务目的所必需的时间内或法律法规规定的条件下存储您的个人信息。\n\n2.2 信息存储的地域\n我们会按照法律法规规定，将境内收集的用户个人信息存储于中国境内。\n目前我们不会跨境传输或存储您的个人信息。将来如需跨境传输或存储的，我们会向您告知信息出境的目的、接收方、安全保证措施和安全风险，并征得您的同意。\n\n2.3 产品或服务停止运营时的通知\n当我们的产品或服务发生停止运营的情况时，我们将以推送通知、公告等形式通知您，并在合理期限内删除您的个人信息或进行匿名化处理，法律法规另有规定的除外。\n\n信息安全\n我们使用各种安全技术和程序，以防信息的丢失、不当使用、未经授权阅览或披露。例如，在某些服务中，我们将利用加密技术（例如 SSL）来保护您提供的个人信息。但请您理解，由于技术的限制以及可能存在的各种恶意手段，在互联网行业，即便竭尽所能加强安全措施，也不可能始终保证信息百分之百的安全。\n\n第三方隐私 SDK 说明\n4.1 腾讯云短信 SDK\n使用目的：短信登录验证。通过手机号，发送短信验证码，进行注册或登录验证。\n腾讯云短信 SDK 官网链接 / 隐私政策：https://cloud.tencent.com/document/sdk\n\n4.2 极光推送 SDK\n使用目的：消息推送服务，用于向您的设备推送通知和消息。\n极光推送 SDK 官网链接 / 隐私政策：https://www.jiguang.cn/license/privacy',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF5D5D5D),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          '不同意',
                          style: TextStyle(
                            color: Color(0xFF5D5D5D),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const SizedBox(width: 30),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _agreementAccepted = true;
                          });
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          '同意',
                          style: TextStyle(
                            color: Color(0xFF4170CD),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 报纸风格的条目
  Widget _buildNewspaperItem({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'serif',
          ),
        ),
        SizedBox(height: 5.h),
        // 内容
        Text(
          content,
          style: TextStyle(fontSize: 12.sp, height: 1.5, fontFamily: 'serif'),
          textAlign: TextAlign.justify,
        ),
      ],
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

      if (response['code'] == 0 && response['data'] != null) {
        // 2. 保存token
        final token = response['data'].toString();
        await SharedPrefsUtils.saveToken(token);

        // 3. 重新初始化 HttpClient 以使用新token
        await HttpClient.init();

        // 4. 获取用户信息
        final userService = UserService();
        final userInfoResponse = await userService.getUserinfo();

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 60),

                  // 自定义Logo
                  Center(
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF6F6BCC), Color(0xFF5254e5)],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "N",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 40),

                  // 标题
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "欢迎回到 ",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                          ),
                        ),
                        TextSpan(
                          text: "Navi",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6F6BCC),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    "登录以继续",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),

                  SizedBox(height: 40),

                  // 手机号输入框
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                    ),
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(color: Colors.black87, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: "手机号",
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.phone_android,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // 密码输入框
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: false,
                      keyboardType: TextInputType.text,
                      style: TextStyle(color: Colors.black87, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: "密码",
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 40),

                  // 登录按钮
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6F6BCC),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          _isLoading
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
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // 忘记密码/短信登录
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          // 忘记密码功能
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          minimumSize: Size.zero,
                          padding: EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 5,
                          ),
                        ),
                        child: Text("忘记密码?"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SmsLoginPage(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Color(0xFF6F6BCC),
                          minimumSize: Size.zero,
                          padding: EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 5,
                          ),
                        ),
                        child: Text("短信验证码登录 →"),
                      ),
                    ],
                  ),

                  SizedBox(height: 40),

                  // 分隔线
                  Row(
                    children: [
                      Expanded(
                        child: Container(height: 1, color: Colors.grey[300]),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          "新用户",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(height: 1, color: Colors.grey[300]),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // 注册按钮
                  Container(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SmsRegisterPage(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xFF6F6BCC),
                        backgroundColor: Colors.transparent,
                        side: BorderSide(color: Color(0xFF6F6BCC), width: 1),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "创建账号",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 30),

                  // 隐私政策
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserAgreementPage(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                        minimumSize: Size.zero,
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                      ),
                      child: Text("《隐私政策》", style: TextStyle(fontSize: 12)),
                    ),
                  ),

                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
