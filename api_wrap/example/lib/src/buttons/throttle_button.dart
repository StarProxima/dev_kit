import 'package:api_wrap/api_wrap.dart';
import 'package:example/src/api_wrapper.dart';
import 'package:example/src/app_button.dart';
import 'package:example/src/buttons/time_text.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ThrottleButton extends StatefulWidget {
  const ThrottleButton({super.key});

  @override
  State<ThrottleButton> createState() => _ThrottleButtonState();
}

class _ThrottleButtonState extends State<ThrottleButton> {
  Duration duration = Duration.zero;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TimeText(duration),
        AppButton(
          isDisabled: duration > Duration.zero,
          onTap: () {
            return apiWrapper.apiWrap(
              () => Future.delayed(
                const Duration(milliseconds: 1000),
                () => 'Throttle Response',
              ),
              rateLimiter: Throttle(
                duration: const Duration(seconds: 4),
                cooldownTickInterval: const Duration(milliseconds: 5),
                onCooldownTick: (time) =>
                    setState(() => duration = time.remainingTime),
              ),
              onSuccess: (res) {
                toastification.show(
                  type: ToastificationType.success,
                  autoCloseDuration: const Duration(seconds: 2),
                  title: Text(res),
                );
              },
            );
          },
          text: 'Throttle function',
        ),
      ],
    );
  }
}
