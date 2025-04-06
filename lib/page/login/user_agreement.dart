import 'package:flutter/material.dart';

class UserAgreementPage extends StatelessWidget {
  const UserAgreementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121214),
      appBar: AppBar(
        title: const Text('隐私政策'),
        backgroundColor: Color(0xFF121214),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '隐私政策',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Color(0xFF1A1A1C),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Color(0xFF6F6BCC).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '更新日期：2024/12/6',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                  Text(
                    '生效日期：2024/12/6',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            sectionTitle('导言'),
            SizedBox(height: 10),
            sectionContent(
              'Navi 是一款由 商丘千寻微梦信息科技有限公司 （以下简称"我们"）提供的产品。 您在使用我们的服务时，我们可能会收集和使用您的相关信息。我们希望通过本《隐私政策》向您说明，在使用我们的服务时，我们如何收集、使用、储存和分享这些信息，以及我们为您提供的访问、更新、控制和保护这些信息的方式。 本《隐私政策》与您所使用的 Navi 服务息息相关，希望您仔细阅读，在需要时，按照本《隐私政策》的指引，作出您认为适当的选择。本《隐私政策》中涉及的相关技术词汇，我们尽量以简明扼要的表述，并提供进一步说明的链接，以便您的理解。',
            ),
            SizedBox(height: 10),
            sectionContent('您使用或继续使用我们的服务，即意味着同意我们按照本《隐私政策》收集、使用、储存和分享您的相关信息。'),
            SizedBox(height: 10),
            sectionContent('如对本《隐私政策》或相关事宜有任何问题，请通过 19137056165 与我们联系。'),
            SizedBox(height: 20),
            sectionTitle('1. 我们收集的信息'),
            SizedBox(height: 10),
            sectionContent(
              '我们或我们的第三方合作伙伴提供服务时，可能会收集、储存和使用下列与您有关的信息。如果您不提供相关信息，可能无法注册成为我们的用户或无法享受我们提供的某些服务，或者无法达到相关服务拟达到的效果。',
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF1A1A1C),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[800]!, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '手机号',
                    style: TextStyle(
                      color: Color(0xFF6F6BCC),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '您在注册账户时，向我们提供个人手机号，我们通过发送短信的方式验证。手机号用于绑定您的账号,用于日后的登录，以及密码找回等',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '职业，位置，加入时间',
                    style: TextStyle(
                      color: Color(0xFF6F6BCC),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '进入Navi后你可以自定义编辑职业，位置， 不要求真实性，此为个人自愿填写。用于在个人信息等界面的展示。加入时间为账号注册的时间，也是用于在个人信息等界面的展示。',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            sectionTitle('2. 信息的存储'),
            SizedBox(height: 10),
            subSectionTitle('2.1 信息存储的方式和期限'),
            SizedBox(height: 5),
            sectionContent('我们会通过安全的方式存储您的信息，包括本地存储（例如利用APP进行数据缓存）、数据库和服务器日志。'),
            SizedBox(height: 5),
            sectionContent('一般情况下，我们只会在为实现服务目的所必需的时间内或法律法规规定的条件下存储您的个人信息。'),
            SizedBox(height: 10),
            subSectionTitle('2.2 信息存储的地域'),
            SizedBox(height: 5),
            sectionContent('我们会按照法律法规规定，将境内收集的用户个人信息存储于中国境内。'),
            SizedBox(height: 5),
            sectionContent(
              '目前我们不会跨境传输或存储您的个人信息。将来如需跨境传输或存储的，我们会向您告知信息出境的目的、接收方、安全保证措施和安全风险，并征得您的同意。',
            ),
            SizedBox(height: 10),
            subSectionTitle('2.3 产品或服务停止运营时的通知'),
            SizedBox(height: 5),
            sectionContent(
              '当我们的产品或服务发生停止运营的情况时，我们将以推送通知、公告等形式通知您，并在合理期限内删除您的个人信息或进行匿名化处理，法律法规另有规定的除外。',
            ),
            SizedBox(height: 20),
            sectionTitle('3. 信息安全'),
            SizedBox(height: 10),
            sectionContent(
              '我们使用各种安全技术和程序，以防信息的丢失、不当使用、未经授权阅览或披露。例如，在某些服务中，我们将利用加密技术（例如SSL）来保护您提供的个人信息。但请您理解，由于技术的限制以及可能存在的各种恶意手段，在互联网行业，即便竭尽所能加强安全措施，也不可能始终保证信息百分之百的安全。',
            ),
            SizedBox(height: 20),
            sectionTitle('4. 第三方隐私SDK说明'),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF1A1A1C),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[800]!, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '4.1 腾讯云短信SDK',
                    style: TextStyle(
                      color: Color(0xFF6F6BCC),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '使用目的：短信登录验证。通过手机号，发送短信验证码，进行注册或登录验证。',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '腾讯云短信SDK官网链接/隐私政策：https://cloud.tencent.com/document/sdk',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '4.2 极光推送SDK',
                    style: TextStyle(
                      color: Color(0xFF6F6BCC),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '使用目的：消息推送服务，用于向您的设备推送通知和消息。',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '极光推送SDK官网链接/隐私政策：https://www.jiguang.cn/license/privacy',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // 封装的小部件：章节标题
  Widget sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF6F6BCC),
      ),
    );
  }

  // 封装的小部件：子章节标题
  Widget subSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  // 封装的小部件：章节内容
  Widget sectionContent(String content) {
    return Text(
      content,
      style: TextStyle(fontSize: 14, color: Colors.white, height: 1.5),
    );
  }
}
