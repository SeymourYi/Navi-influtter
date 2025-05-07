import 'package:flutter/material.dart';

class PrivacyPolicyDialog extends StatelessWidget {
  final String title;
  final String content;
  final String agreeText;
  final String disagreeText;
  final Color agreeColor;
  final Color disagreeColor;
  final VoidCallback onAgreePressed;
  final VoidCallback onDisagreePressed;
  final double widthFactor;
  final double height;

  const PrivacyPolicyDialog({
    Key? key,
    required this.title,
    required this.content,
    this.agreeText = '同意',
    this.disagreeText = '不同意',
    this.agreeColor = const Color(0xFF4170CD),
    this.disagreeColor = const Color(0xFF5D5D5D),
    required this.onAgreePressed,
    required this.onDisagreePressed,
    this.widthFactor = 0.75,
    this.height = 400,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      insetPadding: EdgeInsets.symmetric(horizontal: 50),
      backgroundColor: Colors.white,
      elevation: 0,
      child: Container(
        width: MediaQuery.of(context).size.width * widthFactor,
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
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
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    height: height,
                    child: SingleChildScrollView(
                      child: Text(
                        content,
                        style: const TextStyle(
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
                    onPressed: onDisagreePressed,
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      disagreeText,
                      style: TextStyle(
                        color: disagreeColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                  TextButton(
                    onPressed: onAgreePressed,
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      agreeText,
                      style: TextStyle(
                        color: agreeColor,
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
  }
}
