import 'package:example/src/buttons/cancellation_button.dart';
import 'package:example/src/buttons/debounce_button.dart';
import 'package:example/src/buttons/error_button.dart';
import 'package:example/src/buttons/min_execution_time_button.dart';
import 'package:example/src/buttons/nested_button.dart';
import 'package:example/src/buttons/retry_button.dart';
import 'package:example/src/buttons/success_button.dart';
import 'package:example/src/buttons/throttle_button.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      config: const ToastificationConfig(
        alignment: Alignment.bottomCenter,
        animationDuration: Duration(
          milliseconds: 300,
        ),
      ),
      child: MaterialApp(
        title: 'Handler Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final buttons = [
      // Группа базовых операций
      const _SectionTitle('Basic Operations'),
      const SuccessButton(),
      const ErrorButton(),

      // Группа вложенных запросов
      const _SectionTitle('Nested Requests'),
      const NestedButton(),

      // Группа управления временем
      const _SectionTitle('Timing Control'),
      const MinExecutionTimeButton(),

      // Группа ограничения частоты
      const _SectionTitle('Rate Limiting'),
      const DebounceButton(),
      const ThrottleButton(),

      // Группа отмены операций
      const _SectionTitle('Cancellation Control'),
      const CancellationButton(),

      // Группа автоматических повторных попыток
      const _SectionTitle('Retry Mechanism'),
      const RetryButton(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Handler Example'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListView.builder(
              primary: false,
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: buttons.length,
              itemBuilder: (_, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: buttons[index],
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

/// Виджет для отображения заголовка секции
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
