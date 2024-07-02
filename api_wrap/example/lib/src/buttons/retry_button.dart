import 'package:api_wrap/api_wrap.dart';
import 'package:example/src/api_wrapper.dart';
import 'package:example/src/app_button.dart';
import 'package:example/src/buttons/time_text.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class RetryButton extends StatefulWidget {
  const RetryButton({super.key});

  @override
  State<RetryButton> createState() => _RetryButtonState();
}

class _RetryButtonState extends State<RetryButton> {
  int attemtsCount = 0;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Text('Attemts: $attemtsCount'),
        AppButton(
          onTap: () async {
            setState(() => attemtsCount = 0);
            await apiWrapper.apiWrap(
              () {
                setState(() => attemtsCount++);
                return Future.delayed(
                  const Duration(milliseconds: 1000),
                  () => attemtsCount < 5
                      ? throw Exception('Retry Error')
                      : 'Success response after $attemtsCount attempts',
                );
              },
              retry: Retry(
                maxAttempts: 6,
                retryIf: (_) => true,
                onError: (e, delayBeforeNextAttemt) {
                  toastification.show(
                    type: ToastificationType.error,
                    title: Row(
                      children: [
                        const Text('Failed attempt, retry after '),
                        TimeText(delayBeforeNextAttemt),
                      ],
                    ),
                    description: Text(e.toShortString()),
                    autoCloseDuration: delayBeforeNextAttemt,
                    pauseOnHover: false,
                  );
                },
              ),
              onSuccess: (res) {
                toastification.show(
                  type: ToastificationType.success,
                  autoCloseDuration: const Duration(seconds: 4),
                  title: Text(res),
                );
              },
            );
          },
          text: 'Retry function',
        ),
      ],
    );
  }
}
