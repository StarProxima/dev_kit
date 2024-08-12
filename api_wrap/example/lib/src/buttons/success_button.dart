import 'package:api_wrap/api_wrap.dart';
import 'package:example/src/api_wrapper.dart';
import 'package:example/src/app_button.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class SuccessButton extends StatelessWidget {
  const SuccessButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppButton(
      onTap: () => apiWrapper.apiWrap(
        () => Future.delayed(
          const Duration(milliseconds: 300),
          () => 'Success Response',
        ),
        onSuccess: (res) {
          toastification.show(
            type: ToastificationType.success,
            autoCloseDuration: const Duration(seconds: 2),
            title: Text(res),
          );
        },
      ),
      text: 'Success function',
    );
  }
}
