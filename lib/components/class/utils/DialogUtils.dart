import 'package:flutter/material.dart';
import '../navidialog.dart';

class DialogUtils {
  static void showPrivacyDialog({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onAgree,
    VoidCallback? onDisagree,
    String agreeText = '同意',
    String disagreeText = '不同意',
    double widthFactor = 0.75,
    double height = 400,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => PrivacyPolicyDialog(
            title: title,
            content: content,
            agreeText: agreeText,
            disagreeText: disagreeText,
            onAgreePressed: onAgree,
            onDisagreePressed: onDisagree ?? () => Navigator.of(context).pop(),
            widthFactor: widthFactor,
            height: height,
          ),
    );
  }
}
