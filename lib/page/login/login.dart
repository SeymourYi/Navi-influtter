import 'package:Navi/api/smsloginAPI.dart';
import 'package:Navi/components/class/utils/DialogUtils.dart';
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
import 'package:jverify/jverify.dart';
import 'package:lottie/lottie.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
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
  final SmsLoginService smsLoginService = SmsLoginService();
  bool _isLoading = false;
  bool _agreementAccepted = false;
  bool _obscurePassword = true;
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
    // 设置默认的手机号和密码
    // _emailController.text = '19137056165';
    _emailController.text = '';
    // _passwordController.text = '多少楼台烟雨中';
    _passwordController.text = '';
    _checkAgreementStatus();
  }

  void _notifyNativePushInitialization() {
    if (kIsWeb || !Platform.isAndroid) {
      return;
    }

    const MethodChannel channel = MethodChannel('com.Navi/push_notification');
    channel.invokeMethod('initializePushIfNeeded').catchError((error) {
      debugPrint('触发原生推送初始化失败: $error');
    });
  }

  void _myjver() {
    Jverify jverify = Jverify();
    jverify.setup(
      appKey: "8b8a7faafb8dbceffabf0bdb",
      channel: "devloper-default",
    );
    jverify.setDebugMode(true);

    jverify.checkVerifyEnable().then((map) {
      bool result = map["result"];
      if (result) {
        print("当前网络环境支持认证");

        jverify.getToken().then((map) {
          int code = map["code"];
          String token = map["content"] ?? "";
          String operator = map["operator"] ?? "";

          print("获取token结果: code=$code, operator=$operator");

          if (code == 2000) {
            print("成功获取token: $token");

            JVUIConfig uiConfig = JVUIConfig();
            uiConfig.navColor = Color(0xFF6F6BCC).value;
            uiConfig.navText = "一键登录";
            uiConfig.navTextColor = Colors.white.value;

            uiConfig.logoWidth = 80;
            uiConfig.logoHeight = 80;
            uiConfig.logoOffsetY = 10;
            uiConfig.logoHidden = false;

            uiConfig.numberColor = Colors.black.value;
            uiConfig.numberSize = 18;

            uiConfig.logBtnText = "本机号码一键登录";
            uiConfig.logBtnTextColor = Colors.white.value;
            uiConfig.logBtnTextSize = 16;

            uiConfig.privacyState = true;
            uiConfig.privacyCheckboxSize = 20;

            uiConfig.privacyText = ["登录即同意", "《隐私政策》", "和", "《用户协议》"];
            uiConfig.privacyTextSize = 13;
            uiConfig.clauseColor = Color(0xFF6F6BCC).value;

            uiConfig.clauseName = "隐私政策";
            uiConfig.clauseUrl = "https://privacy.policy.url";

            uiConfig.clauseNameTwo = "用户协议";
            uiConfig.clauseUrlTwo = "https://user.agreement.url";

            jverify.addLoginAuthCallBackListener((event) {
              print(
                "登录回调: code=${event.code}, message=${event.message}, operator=${event.operator}",
              );

              if (event.code == 6000) {
                print("一键登录成功: ${event.message}");
                final loginToken = event.message.toString();
                void _loginWithJverifyToken() async {
                  try {
                    final loginService = LoginService();
                    final response = await loginService.verifyJVerifyToken(
                      loginToken,
                    );
                    print(response);
                    if (response['code'] == 8000) {
                      print(response['phone']);
                      var number = await loginService.decryptToken(
                        response['phone'],
                      );

                      var smslogin = await smsLoginService.smsLogin(
                        number['data'],
                      );
                      print(smslogin);
                      final Token = smslogin['data'].toString();

                      await SharedPrefsUtils.saveToken(Token);

                      await HttpClient.init();

                      final userService = UserService();
                      final userInfoResponse = await userService.getUserinfo();

                      if (userInfoResponse['code'] == 0 &&
                          userInfoResponse['data'] != null) {
                        await SharedPrefsUtils.saveUserInfo(
                          userInfoResponse['data'],
                        );

                        await SharedPrefsUtils.setBool('is_logged_in', true);

                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('登录成功'),
                            duration: Duration(seconds: 1),
                          ),
                        );

                        if (mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyHome(),
                            ),
                          );
                        }
                      } else {
                        throw Exception(userInfoResponse['msg'] ?? '获取用户信息失败');
                      }
                    } else {
                      throw Exception(response['msg'] ?? '极光认证失败');
                    }
                  } catch (e) {
                    print('极光一键登录错误: $e');
                    await SharedPrefsUtils.clearToken();
                    if (mounted) {
                      _showErrorDialog(
                        e.toString().contains('Exception:')
                            ? e.toString().split('Exception: ')[1]
                            : '网络错误，请检查网络连接',
                      );
                    }
                  }
                }

                _loginWithJverifyToken();
                jverify.dismissLoginAuthView();
              } else {
                print("一键登录失败: ${event.message}");
                if (mounted) {}
              }
            });

            jverify.setCustomAuthorizationView(true, uiConfig);
            jverify.loginAuthSyncApi(autoDismiss: true);
          } else {
            print("获取token失败: ${map["content"]}");
            if (mounted) {
              _showErrorDialog("无法获取手机号，请手动输入");
            }
          }
        });
      } else {
        print("当前网络环境不支持认证");
        if (mounted) {
          _showErrorDialog("当前网络环境不支持一键获取手机号，请手动输入");
        }
      }
    });
  }

  Future<void> _checkAgreementStatus() async {
    final consentGranted = await SharedPrefsUtils.hasPrivacyConsent();
    if (!mounted) {
      return;
    }

    if (consentGranted) {
      setState(() {
        _agreementAccepted = true;
      });
      _notifyNativePushInitialization();
    } else {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _showAgreementDialog();
        }
      });
    }
  }

  void _showAgreementDialog() {
    DialogUtils.showPrivacyDialog(
      context: context,
      title: '请阅读下方隐私政策',
      content:
          '隐私政策\n\n更新日期: 2024/12/6\n生效日期: 2024/12/6\n\n导言\n\nNavi 是一款由 商丘千寻微梦信息科技有限公司 （以下简称 "我们"）提供的产品。 您在使用我们的服务时，我们可能会收集和使用您的相关信息。我们希望通过本《隐私政策》向您说明，在使用我们的服务时，我们如何收集、使用、储存和分享这些信息，以及我们为您提供的访问、更新、控制和保护这些信息的方式。\n\n本《隐私政策》与您所使用的 Navi 服务息息相关，希望您仔细阅读，在需要时，按照本《隐私政策》的指引，作出您认为适当的选择。本《隐私政策》中涉及的相关技术词汇，我们尽量以简明扼要的表述，并提供进一步说明的链接，以便您的理解。\n\n您使用或继续使用我们的服务，即意味着同意我们按照本《隐私政策》收集、使用、储存和分享您的相关信息。\n\n如对本《隐私政策》或相关事宜有任何问题，请通过 19137056165 与我们联系。\n\n我们收集的信息\n我们或我们的第三方合作伙伴提供服务时，可能会收集、储存和使用下列与您有关的信息。如果您不提供相关信息，可能无法注册成为我们的用户或无法享受我们提供的某些服务，或者无法达到相关服务拟达到的效果。\n\n手机号 您在注册账户时，向我们提供个人手机号，我们通过发送短信的方式验证。手机号用于绑定您的账号，用于日后的登录，以及密码找回等\n\n职业，位置，加入时间 进入 Navi 后你可以自定义编辑职业，位置， 不要求真实性，此为个人自愿填写。用于在个人信息等界面的展示。加入时间为账号注册的时间，也是用于在个人信息等界面的展示。\n\n设备标识符 为了提供消息推送服务，我们可能会通过第三方SDK收集您的设备标识符信息，包括但不限于：\n- OAID（开放匿名设备标识符）：用于在Android设备上识别设备，用于消息推送服务的设备识别和消息精准送达。\n- AndroidID：用于在Android设备上识别设备，用于消息推送服务的设备识别和消息精准送达。\n上述设备标识符仅用于提供消息推送服务，不会用于其他目的。\n\n信息的存储\n2.1 信息存储的方式和期限\n我们会通过安全的方式存储您的信息，包括本地存储（例如利用 APP 进行数据缓存）、数据库和服务器日志。\n一般情况下，我们只会在为实现服务目的所必需的时间内或法律法规规定的条件下存储您的个人信息。\n\n2.2 信息存储的地域\n我们会按照法律法规规定，将境内收集的用户个人信息存储于中国境内。\n目前我们不会跨境传输或存储您的个人信息。将来如需跨境传输或存储的，我们会向您告知信息出境的目的、接收方、安全保证措施和安全风险，并征得您的同意。\n\n2.3 产品或服务停止运营时的通知\n当我们的产品或服务发生停止运营的情况时，我们将以推送通知、公告等形式通知您，并在合理期限内删除您的个人信息或进行匿名化处理，法律法规另有规定的除外。\n\n信息安全\n我们使用各种安全技术和程序，以防信息的丢失、不当使用、未经授权阅览或披露。例如，在某些服务中，我们将利用加密技术（例如 SSL）来保护您提供的个人信息。但请您理解，由于技术的限制以及可能存在的各种恶意手段，在互联网行业，即便竭尽所能加强安全措施，也不可能始终保证信息百分之百的安全。\n\n第三方隐私 SDK 说明\n4.1 腾讯云短信 SDK\n使用目的：短信登录验证。通过手机号，发送短信验证码，进行注册或登录验证。\n腾讯云短信 SDK 官网链接 / 隐私政策：https://cloud.tencent.com/document/sdk\n\n4.2 极光推送 SDK\n使用目的：消息推送服务，用于向您的设备推送通知和消息。\n收集的个人信息类型：\n- OAID（开放匿名设备标识符）：用于在Android设备上识别设备，实现消息推送服务的设备识别和消息精准送达。\n- AndroidID：用于在Android设备上识别设备，实现消息推送服务的设备识别和消息精准送达。\n上述信息仅用于提供消息推送服务，不会用于其他目的。\n极光推送 SDK 官网链接 / 隐私政策：https://www.jiguang.cn/license/privacy',
      onAgree: () {
        setState(() {
          _agreementAccepted = true;
        });
        SharedPrefsUtils.setPrivacyConsent(true);
        _notifyNativePushInitialization();
        Navigator.of(context).pop();
      },
      onDisagree: () {
        SharedPrefsUtils.setPrivacyConsent(false);
        Navigator.of(context).pop();
      },
    );
  }

  Future<void> _login() async {
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
      final loginService = LoginService();
      final response = await loginService.Login(
        _emailController.text,
        _passwordController.text,
      );

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
              Icon(Icons.error_outline, color: Colors.red[600], size: 24),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '登录失败',
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                elevation: 0,
              ),
              child: const Text(
                '确定',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),

                  // Logo
                  Center(
                    child: Container(
                      height: 60,
                      width: 60,
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
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 48),

                  // 标题
                  Text(
                    "欢迎回来",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "登录以继续使用",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),

                  SizedBox(height: 40),

                  // 手机号输入框
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(color: Colors.black87, fontSize: 16),
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
                        borderSide: BorderSide(
                          color: Color(0xFF6F6BCC),
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),

                  SizedBox(height: 24),

                  // 密码输入框
                  TextField(
                    controller: _passwordController,
                    keyboardType: TextInputType.text,
                    style: TextStyle(color: Colors.black87, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: "密码（仅限中文）",
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
                        borderSide: BorderSide(
                          color: Color(0xFF6F6BCC),
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                    ),
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

                  SizedBox(height: 24),

                  // 短信验证码登录链接
                  Center(
                    child: TextButton(
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
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Text("短信验证码登录 →", style: TextStyle(fontSize: 15)),
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
                          "新用户",
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

                  // 注册按钮
                  Container(
                    width: double.infinity,
                    height: 50,
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
                        foregroundColor: Colors.black87,
                        side: BorderSide(color: Colors.grey[400]!, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        "创建账号",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 32),

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
                        foregroundColor: Colors.grey[500],
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Text("《隐私政策》", style: TextStyle(fontSize: 12)),
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
