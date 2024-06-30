import 'package:api_wrap/api_wrap.dart';
import 'package:example/src/api_wrapper.dart';
import 'package:example/src/app_button.dart';
import 'package:example/src/buttons/time_text.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class DebounceButton extends StatefulWidget {
  const DebounceButton({super.key});

  @override
  State<DebounceButton> createState() => _DebounceButtonState();
}

class _DebounceButtonState extends State<DebounceButton> {
  Duration duration = Duration.zero;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TimeText(duration),
        AppButton(
          showLoading: false,
          isLoading: isLoading,
          allowTapDuringLoading: true,
          onTap: () async {
            await apiWrapper.apiWrap(
              () => Future.delayed(
                const Duration(milliseconds: 1000),
                () => 'Debounce Response',
              ),
              rateLimiter: Debounce(
                duration: const Duration(seconds: 2),
                delayTickInterval: const Duration(milliseconds: 5),
                onDelayTick: (time) =>
                    setState(() => duration = time.elapsedTime),
                onDelayEnd: () => setState(() => isLoading = true),
              ),
              onSuccess: (res) {
                toastification.show(
                  type: ToastificationType.success,
                  autoCloseDuration: const Duration(seconds: 2),
                  title: Text(res),
                );
              },
            );
            setState(() => isLoading = false);
          },
          text: 'Debounce function',
        ),
      ],
    );
  }
}
