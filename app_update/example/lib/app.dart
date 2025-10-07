import 'package:app_update/app_update.dart';
import 'package:flutter/material.dart';

import 'features/home/presentation/home_screen.dart';
import 'features/shared/domain/app_state.dart';

/// Главное приложение с интеграцией UpdateHandler
class UpdateExampleApp extends StatelessWidget {
  const UpdateExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Update Sandbox',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ValueListenableBuilder(
        valueListenable: AppState.instance.notifier,
        builder: (context, state, child) {
          return UpdateHandler.alert(
            onUpdateResult: (context, controller, result) {
              // Показываем диалог только если включено в настройках
              if (state.autoShowDialog && result.shouldShow) {
                UpdateAlertHandler.materialDialog(context, controller, result);
              }
            },
            searchConfig: UpdateSearchConfig(
              locale: state.locale,
            ),
            controller: state.controller,
            child: const HomeScreen(),
          );
        },
      ),
    );
  }
}
