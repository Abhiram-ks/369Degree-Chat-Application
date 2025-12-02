import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';

class CustomCupertinoDialog {
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    Color? color = AppPalette.black,
    required String text,
  }) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => CupertinoAlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  text,
                  style: TextStyle(color: color),
                ),
              ),
            ],
          ),
    );
  }
}