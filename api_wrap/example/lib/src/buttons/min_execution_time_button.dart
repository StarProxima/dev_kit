import 'package:handler/handler.dart';
import 'package:example/src/handler.dart';
import 'package:example/src/app_button.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class MinExecutionTimeButton extends StatefulWidget {
  const MinExecutionTimeButton({super.key});

  @override
  State<MinExecutionTimeButton> createState() => _MinExecutionTimeButtonState();
}

class _MinExecutionTimeButtonState extends State<MinExecutionTimeButton> {
  int _actualTime = 0;
  int _perceivedTime = 0;

  void _resetTimers() {
    setState(() {
      _actualTime = 0;
      _perceivedTime = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          'Actual execution time: $_actualTime ms\n'
          'Perceived execution time: $_perceivedTime ms',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: AppButton(
                isSmall: true,
                text: 'Without min time',
                onTap: () async {
                  _resetTimers();

                  final stopwatch = Stopwatch()..start();

                  await handler.handle<String, String>(
                    () async {
                      // Быстрый запрос, который занимает всего 50 мс
                      await Future.delayed(const Duration(milliseconds: 50));
                      return 'Fast Response';
                    },
                    onSuccess: (res) {
                      final elapsed = stopwatch.elapsedMilliseconds;
                      setState(() => _actualTime = elapsed);
                      _perceivedTime = elapsed;

                      toastification.show(
                        type: ToastificationType.success,
                        autoCloseDuration: const Duration(seconds: 2),
                        title: Text(res),
                        description:
                            const Text('Completed without min execution time'),
                      );
                      return res;
                    },
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppButton(
                isSmall: true,
                text: 'With min time (800ms)',
                onTap: () async {
                  _resetTimers();

                  final stopwatch = Stopwatch()..start();

                  await handler.handle<String, String>(
                    () async {
                      // Тот же быстрый запрос, который занимает всего 50 мс
                      await Future.delayed(const Duration(milliseconds: 50));
                      setState(
                          () => _actualTime = stopwatch.elapsedMilliseconds);
                      return 'Fast Response';
                    },
                    // Устанавливаем минимальное время выполнения 800 мс
                    minExecutionTime: const Duration(milliseconds: 800),
                    onSuccess: (res) {
                      setState(
                          () => _perceivedTime = stopwatch.elapsedMilliseconds);

                      toastification.show(
                        type: ToastificationType.success,
                        autoCloseDuration: const Duration(seconds: 2),
                        title: Text(res),
                        description:
                            const Text('Completed with min execution time'),
                      );
                      return res;
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
