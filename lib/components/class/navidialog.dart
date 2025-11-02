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
    this.agreeColor = const Color(0xFF6201E7),
    this.disagreeColor = const Color(0xFF5D5D5D),
    required this.onAgreePressed,
    required this.onDisagreePressed,
    this.widthFactor = 0.75,
    this.height = 400,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: Colors.white,
      elevation: 0,
      child: Container(
        width: MediaQuery.of(context).size.width * widthFactor,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                constraints: BoxConstraints(
                  maxHeight: height,
                ),
                child: SingleChildScrollView(
                  child: Text(
                    content,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onDisagreePressed,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: Text(
                    disagreeText,
                    style: TextStyle(
                      color: disagreeColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: onAgreePressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: agreeColor,
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
                  child: Text(
                    agreeText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
