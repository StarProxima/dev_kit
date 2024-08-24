import 'package:app_logger/src/app_logger_helper.dart';
import 'package:flutter/material.dart';

Future<void> showInfoDialog({
  required BuildContext context,
  Widget? title,
  Widget? content,
}) =>
    showDialog(
      context: context,
      builder: (context) => Theme(
        data: AppLoggerHelper.instance.theme,
        child: AlertDialog(
          title: title,
          content: content,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CLOSE'),
            ),
          ],
        ),
      ),
    );
