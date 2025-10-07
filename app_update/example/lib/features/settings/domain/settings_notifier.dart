import 'package:app_update/app_update.dart';
import 'package:flutter/foundation.dart';

import '../../shared/domain/app_state.dart';
import '../../shared/domain/update_config_type.dart';

/// Временное состояние настроек (для редактирования)
class SettingsState {
  const SettingsState({
    required this.locale,
    required this.configType,
    required this.mockVersion,
    required this.autoShowDialog,
  });

  final UpdateLocale locale;
  final UpdateConfigType configType;
  final String mockVersion;
  final bool autoShowDialog;

  SettingsState copyWith({
    UpdateLocale? locale,
    UpdateConfigType? configType,
    String? mockVersion,
    bool? autoShowDialog,
  }) {
    return SettingsState(
      locale: locale ?? this.locale,
      configType: configType ?? this.configType,
      mockVersion: mockVersion ?? this.mockVersion,
      autoShowDialog: autoShowDialog ?? this.autoShowDialog,
    );
  }
}

/// Notifier для управления настройками (временное состояние)
class SettingsNotifier extends ValueNotifier<SettingsState> {
  SettingsNotifier()
      : super(
          SettingsState(
            locale: AppState.instance.notifier.value.locale,
            configType: AppState.instance.notifier.value.configType,
            mockVersion: AppState.instance.notifier.value.mockAppVersion,
            autoShowDialog: AppState.instance.notifier.value.autoShowDialog,
          ),
        );

  void changeLocale(UpdateLocale locale) {
    value = value.copyWith(locale: locale);
  }

  void changeConfigType(UpdateConfigType configType) {
    value = value.copyWith(configType: configType);
  }

  void changeMockVersion(String version) {
    value = value.copyWith(mockVersion: version);
  }

  void toggleAutoShowDialog() {
    value = value.copyWith(autoShowDialog: !value.autoShowDialog);
  }

  /// Сохраняет изменения в глобальное состояние
  Future<void> saveSettings() async {
    final sandboxNotifier = AppState.instance.notifier;
    final currentConfig = sandboxNotifier.value.configType;
    final newConfig = value.configType;

    // Если конфиг изменился - пересоздаем контроллер
    if (currentConfig != newConfig) {
      await sandboxNotifier.changeConfigType(newConfig);
    }

    // Применяем остальные настройки
    sandboxNotifier
      ..changeLocale(value.locale)
      ..changeMockAppVersion(value.mockVersion);

    if (sandboxNotifier.value.autoShowDialog != value.autoShowDialog) {
      sandboxNotifier.toggleAutoShowDialog();
    }
  }
}
