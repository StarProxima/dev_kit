import 'package:handler/handler.dart';
import 'package:example/src/handler.dart';
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
            await handler.handle(
              () => Future.delayed(
                const Duration(milliseconds: 1000),
                () => 'Debounce Response',
              ),
              rateLimiter: Debounce(
                duration: const Duration(seconds: 2),
                tickInterval: const Duration(milliseconds: 5),
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
