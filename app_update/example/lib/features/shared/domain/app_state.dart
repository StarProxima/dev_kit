import 'package:app_update/app_update.dart';

import 'sandbox_state_notifier.dart';

/// Глобальный доступ к состоянию sandbox
///
/// Singleton для упрощения доступа из UI
class AppState {
  AppState._();

  static final AppState instance = AppState._();

  /// Notifier состояния sandbox
  final SandboxStateNotifier notifier = SandboxStateNotifier();

  /// Доступные локали для выбора
  static const availableLocales = [
    UpdateLocale.en,
    UpdateLocale.ru,
    UpdateLocale.any,
  ];

  /// Dispose resources
  void dispose() {
    notifier.dispose();
  }
}
