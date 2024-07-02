import 'package:api_wrap/api_wrap.dart';
import 'package:example/src/api_wrapper.dart';
import 'package:example/src/app_button.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ErrorButton extends StatelessWidget {
  const ErrorButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppButton(
      onTap: () => apiWrapper.apiWrapSingle<String>(
        () => Future.delayed(
          const Duration(milliseconds: 600),
          () => throw Exception('Oh no, error'),
        ),
        onSuccess: (res) {
          toastification.show(
            type: ToastificationType.success,
            autoCloseDuration: const Duration(seconds: 2),
            title: Text(res),
          );
          return null;
        },
      ),
      text: 'Error function',
    );
  }
}
