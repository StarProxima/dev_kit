import 'dart:async';

import 'package:handler/handler.dart';
import 'package:example/src/handler.dart';
import 'package:example/src/app_button.dart';
import 'package:example/src/buttons/time_text.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class CancellationButton extends StatefulWidget {
  const CancellationButton({super.key});

  @override
  State<CancellationButton> createState() => _CancellationButtonState();
}

class _CancellationButtonState extends State<CancellationButton> {
  Duration remainingTime = Duration.zero;
  int operationCount = 0;
  bool isOperationActive = false;

  // Ключи для идентификации операций
  static const debounceKey = 'debounce-operation';
  static const throttleKey = 'throttle-operation';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Active operation: '),
            TimeText(remainingTime),
          ],
        ),
        Text('Operations completed: $operationCount'),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Кнопка для добавления debounce операции
            AppButton(
              isSmall: true,
              text: 'Add Debounce (2s)',
              onTap: () {
                setState(() => isOperationActive = true);

                handler.handle<int, int>(
                  () {
                    setState(() {
                      operationCount++;
                      isOperationActive = false;
                      remainingTime = Duration.zero;
                    });

                    toastification.show(
                      type: ToastificationType.success,
                      autoCloseDuration: const Duration(seconds: 2),
                      title: const Text('Debounce executed'),
                      description: Text('Operation #$operationCount completed'),
                    );

                    return operationCount;
                  },
                  key: debounceKey,
                  rateLimiter: RateLimiter.debounce(
                    duration: const Duration(seconds: 2),
                    tickInterval: const Duration(milliseconds: 50),
                    onDelayTick: (timings) {
                      setState(() => remainingTime = timings.remainingTime);
                    },
                    onDelayEnd: () {
                      // Не сбрасываем индикатор, так как операция еще выполняется
                    },
                  ),
                );
              },
            ),

            const SizedBox(width: 8),
            // Кнопка для добавления throttle операции
            AppButton(
              isSmall: true,
              text: 'Add Throttle (3s)',
              onTap: () {
                handler.handle<int, int>(
                  () {
                    setState(() => operationCount++);

                    toastification.show(
                      type: ToastificationType.success,
                      autoCloseDuration: const Duration(seconds: 2),
                      title: const Text('Throttle executed'),
                      description: Text('Operation #$operationCount completed'),
                    );

                    setState(() => isOperationActive = true);

                    return operationCount;
                  },
                  key: throttleKey,
                  rateLimiter: RateLimiter.throttle(
                    duration: const Duration(seconds: 3),
                    tickInterval: const Duration(milliseconds: 50),
                    onCooldownTick: (timings) {
                      setState(() => remainingTime = timings.remainingTime);
                    },
                    onCooldownEnd: () {
                      setState(() {
                        isOperationActive = false;
                        remainingTime = Duration.zero;
                      });
                    },
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        AppButton(
          isSmall: true,
          text: 'Cancel Operation',
          onTap: () {
            if (!isOperationActive) {
              toastification.show(
                type: ToastificationType.warning,
                autoCloseDuration: const Duration(seconds: 2),
                title: const Text('No active operation'),
                description: const Text('Nothing to cancel'),
              );
              return;
            }

            // Отменяем обе операции (выполнится только для активной)
            handler.cancel(key: debounceKey);
            handler.cancel(key: throttleKey);

            setState(() {
              isOperationActive = false;
              remainingTime = Duration.zero;
            });

            toastification.show(
              type: ToastificationType.info,
              autoCloseDuration: const Duration(seconds: 2),
              title: const Text('Operation cancelled'),
            );
          },
        ),
        const SizedBox(height: 8),
        AppButton(
          isSmall: true,
          text: 'Execute Now',
          onTap: () async {
            if (!isOperationActive) {
              toastification.show(
                type: ToastificationType.warning,
                autoCloseDuration: const Duration(seconds: 2),
                title: const Text('No active operation'),
                description: const Text('Nothing to execute'),
              );
              return;
            }

            // Пробуем выполнить обе операции (сработает только для активной)
            await handler.fire(key: debounceKey);
            await handler.fire(key: throttleKey);

            toastification.show(
              type: ToastificationType.info,
              autoCloseDuration: const Duration(seconds: 2),
              title: const Text('Operation executed immediately'),
            );
          },
        ),
        const SizedBox(height: 8),
        AppButton(
          isSmall: true,
          text: 'Cancel ALL Operations',
          onTap: () {
            handler.cancelAll();

            setState(() {
              isOperationActive = false;
              remainingTime = Duration.zero;
            });

            toastification.show(
              type: ToastificationType.info,
              autoCloseDuration: const Duration(seconds: 2),
              title: const Text('All operations cancelled'),
            );
          },
        ),
      ],
    );
  }
}
