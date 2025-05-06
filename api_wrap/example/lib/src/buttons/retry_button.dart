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
  RetryStats? retryStats;

  int get attempt => retryStats?.attempt ?? 0;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Text('Attemt: ${retryStats?.attempt ?? 0}'),
        AppButton(
          onTap: () async {
            await apiWrapper.apiWrap(
              () {
                return Future.delayed(
                  const Duration(milliseconds: 1000),
                  () => attempt < 5 ? throw Exception('Retry Error') : 'Success response after $attempt attempts',
                );
              },
              retry: Retry(
                maxAttempts: 6,
                onAttempt: (stats) {
                  if (mounted) setState(() => retryStats = stats);
                },
                onFailAttempt: (e, s, stats) {
                  final error = apiWrapper.wrapError(e, s);

                  toastification.show(
                    type: ToastificationType.error,
                    title: Row(
                      children: [
                        const Text('Failed attempt, retry after '),
                        TimeText(stats.delayBeforeNextAttempt),
                      ],
                    ),
                    description: Text(error.toString()),
                    autoCloseDuration: stats.delayBeforeNextAttempt,
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
