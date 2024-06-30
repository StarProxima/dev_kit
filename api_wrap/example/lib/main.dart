import 'package:example/src/buttons/debounce_button.dart';
import 'package:example/src/buttons/error_button.dart';
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
        title: 'ApiWrap Demo',
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
      const SuccessButton(),
      const ErrorButton(),
      const DebounceButton(),
      const ThrottleButton(),
      const RetryButton(),
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('ApiWrap Example'),
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
                final gap = MediaQuery.sizeOf(context).height / 2;

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: gap),
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
