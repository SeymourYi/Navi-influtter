import 'package:flutter/material.dart';

class UserAgreementPage extends StatelessWidget {
  const UserAgreementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户协议与隐私政策'),
        backgroundColor: const Color.fromARGB(255, 126, 121, 211),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '用户协议与隐私政策',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              '更新日期：2024年5月1日',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            SizedBox(height: 20),
            Text(
              '欢迎您使用我们的应用！',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '请您在使用我们的产品和服务前，仔细阅读并了解本《用户协议与隐私政策》。',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '1. 收集的信息',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '我们可能收集您的以下信息：\n'
              '• 个人信息：如手机号码、电子邮件地址等\n'
              '• 设备信息：如设备型号、操作系统版本等\n'
              '• 日志信息：如您使用我们服务的详细情况',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '2. 信息的使用',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '我们使用收集的信息是为了：\n'
              '• 提供、维护和改进我们的服务\n'
              '• 开发新的服务功能\n'
              '• 保护用户的账号安全',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '3. 信息的共享',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '除非有下列情况，我们不会与任何第三方分享您的个人信息：\n'
              '• 取得您的明确同意\n'
              '• 为遵守适用的法律法规\n'
              '• 在公司合并、收购等情况下',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '4. 信息安全',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '我们采取各种安全措施保护您的个人信息，防止数据遭到未经授权的访问、披露、使用、修改等情况。',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '5. 您的权利',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '您对个人信息有以下权利：\n'
              '• 访问您的个人信息\n'
              '• 更正不准确的信息\n'
              '• 删除您的信息\n'
              '• 撤回您的同意',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '6. 协议更新',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '我们可能会不时更新本协议。如有重大变更，我们会通过应用内通知或其他方式通知您。',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '7. 联系我们',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '如果您对本协议有任何疑问，请联系我们：support@example.com',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
