import 'package:app_update/app_update.dart';
import 'package:flutter/foundation.dart';

import '../data/config_loader.dart';
import 'update_config_type.dart';

/// Состояние sandbox приложения
class SandboxState {
  const SandboxState({
    required this.locale,
    required this.configType,
    required this.mockAppVersion,
    required this.autoShowDialog,
    required this.controller,
    this.lastResult,
    this.isLoading = false,
  });

  final UpdateLocale locale;
  final UpdateConfigType configType;
  final String mockAppVersion;
  final bool autoShowDialog;
  final UpdateController controller;
  final UpdateResult? lastResult;
  final bool isLoading;

  SandboxState copyWith({
    UpdateLocale? locale,
    UpdateConfigType? configType,
    String? mockAppVersion,
    bool? autoShowDialog,
    UpdateController? controller,
    UpdateResult? lastResult,
    bool? isLoading,
  }) {
    return SandboxState(
      locale: locale ?? this.locale,
      configType: configType ?? this.configType,
      mockAppVersion: mockAppVersion ?? this.mockAppVersion,
      autoShowDialog: autoShowDialog ?? this.autoShowDialog,
      controller: controller ?? this.controller,
      lastResult: lastResult ?? this.lastResult,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Notifier для управления состоянием sandbox
class SandboxStateNotifier extends ValueNotifier<SandboxState> {
  SandboxStateNotifier()
      : _configLoader = const ConfigLoader(),
        super(
          SandboxState(
            locale: UpdateLocale.en,
            configType: UpdateConfigType.optional,
            mockAppVersion: '1.0.0',
            autoShowDialog: true,
            controller: _createController(
              UpdateConfigType.optional,
              const ConfigLoader(),
            ),
          ),
        ) {
    // Асинхронная инициализация в constructor body
    _initController();
  }

  final ConfigLoader _configLoader;

  /// Инициализирует контроллер асинхронно
  Future<void> _initController() async {
    await value.controller.init();
  }

  /// Создает контроллер с указанным конфигом
  static UpdateController _createController(
    UpdateConfigType configType,
    ConfigLoader configLoader,
  ) {
    return UpdateController(
      fetchers: [configLoader.createFetcher(configType)],
    );
  }

  /// Изменяет локаль
  void changeLocale(UpdateLocale locale) {
    value = value.copyWith(locale: locale);
  }

  /// Изменяет тип конфига (пересоздает контроллер)
  Future<void> changeConfigType(UpdateConfigType configType) async {
    // Dispose старого контроллера
    await value.controller.dispose();

    // Создаем новый контроллер
    final newController = _createController(configType, _configLoader);
    await newController.init();

    value = value.copyWith(
      configType: configType,
      controller: newController,
      lastResult: null, // Сбрасываем результат
    );
  }

  /// Изменяет версию приложения
  void changeMockAppVersion(String version) {
    value = value.copyWith(mockAppVersion: version);
  }

  /// Переключает автопоказ диалога
  void toggleAutoShowDialog() {
    value = value.copyWith(autoShowDialog: !value.autoShowDialog);
  }

  /// Проверяет обновления
  Future<void> checkForUpdates() async {
    value = value.copyWith(isLoading: true);

    try {
      await value.controller.fetch(
        UpdateSearchConfig(locale: value.locale),
      );

      final result = value.controller.findUpdate(
        UpdateSearchConfig(locale: value.locale),
      );

      value = value.copyWith(
        lastResult: result,
        isLoading: false,
      );
    } catch (e) {
      value = value.copyWith(isLoading: false);
      rethrow;
    }
  }

  /// Загружает тестовый сценарий
  Future<UpdateResult?> loadScenario(String configFileName) async {
    value = value.copyWith(isLoading: true);

    try {
      final testController = UpdateController(
        fetchers: [
          UpdateConfigFetcher.customRaw(
            () => _configLoader.loadConfigFromAssets(configFileName),
          ),
        ],
      );

      await testController.init();
      await testController.fetch(
        UpdateSearchConfig(locale: value.locale),
      );

      final result = testController.findUpdate(
        UpdateSearchConfig(locale: value.locale),
      );

      value = value.copyWith(
        lastResult: result,
        isLoading: false,
      );

      // Контроллер останется для показа диалога, cleanup снаружи
      return result;
    } catch (e) {
      value = value.copyWith(isLoading: false);
      rethrow;
    }
  }

  @override
  void dispose() {
    // Не await потому что dispose должен быть синхронным
    value.controller.dispose();
    super.dispose();
  }
}
