import 'package:flutter/material.dart';

class Aboutnavi extends StatefulWidget {
  const Aboutnavi({super.key});

  @override
  State<Aboutnavi> createState() => _AboutnaviState();
}

class _AboutnaviState extends State<Aboutnavi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121214),
      appBar: AppBar(
        title: const Text('关于Navi'),
        backgroundColor: Color(0xFF121214),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Color(0xFF1A1A1C),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Color(0xFF6F6BCC).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.navigation,
                      size: 60,
                      color: Color(0xFF6F6BCC),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Navi',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '版本 1.0.0',
                    style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            sectionTitle('应用介绍'),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF1A1A1C),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Color(0xFF6F6BCC).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: sectionContent(
                'Navi 是一款由商丘千寻微梦信息科技有限公司提供的产品。我们致力于为用户提供便捷、高效的服务体验，帮助用户在日常生活中更好地导航和探索。',
              ),
            ),
            SizedBox(height: 20),
            sectionTitle('开发团队'),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(16),
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
                    '商丘千寻微梦信息科技有限公司',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 16, color: Colors.grey[400]),
                      SizedBox(width: 8),
                      Text(
                        '联系电话: 19137056165',
                        style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                      SizedBox(width: 8),
                      Text(
                        '更新日期: 2024/12/6',
                        style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            sectionTitle('功能特点'),
            SizedBox(height: 10),
            featureItem(Icons.security, '安全可靠', '我们使用各种安全技术和程序，保护您的个人信息安全'),
            SizedBox(height: 10),
            featureItem(Icons.privacy_tip, '隐私保障', '您的个人信息仅在必要情况下收集，并存储在中国境内'),
            SizedBox(height: 10),

            // featureItem(Icons.message, '消息推送', '通过极光推送服务，及时获取重要通知'),
            // SizedBox(height: 20),
            // sectionTitle('使用的技术'),
            // SizedBox(height: 10),
            // Container(
            //   padding: EdgeInsets.all(16),
            //   decoration: BoxDecoration(
            //     color: Color(0xFF1A1A1C),
            //     borderRadius: BorderRadius.circular(8),
            //     border: Border.all(color: Colors.grey[800]!, width: 1),
            //   ),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       techItem('腾讯云短信SDK', '用于短信登录验证'),
            //       SizedBox(height: 10),
            //       techItem('极光推送SDK', '用于消息推送服务'),
            //     ],
            //   ),
            // ),
            SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/privacy_policy');
                },
                child: Text(
                  '查看隐私政策',
                  style: TextStyle(color: Color(0xFF6F6BCC), fontSize: 16),
                ),
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

  // 封装的小部件：章节内容
  Widget sectionContent(String content) {
    return Text(
      content,
      style: TextStyle(fontSize: 14, color: Colors.white, height: 1.5),
    );
  }

  // 封装的小部件：功能特点项
  Widget featureItem(IconData icon, String title, String description) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1C),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Color(0xFF6F6BCC), size: 24),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 封装的小部件：技术项
  Widget techItem(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Color(0xFF6F6BCC),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(fontSize: 14, color: Colors.white, height: 1.5),
        ),
      ],
    );
  }
}
