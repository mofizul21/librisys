import 'package:flutter/material.dart';

enum SnackBarType { success, warning, error }

void showCustomSnackBar(
  BuildContext context,
  SnackBarType type,
  String message,
) {
  Color backgroundColor;
  switch (type) {
    case SnackBarType.success:
      backgroundColor = const Color(0xFF4CAF50);
      break;
    case SnackBarType.warning:
      backgroundColor = const Color(0xFF997F31);
      break;
    case SnackBarType.error:
      backgroundColor = const Color(0xFFF44336);
      break;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
