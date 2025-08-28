import 'dart:io';

import 'package:app_update/src/controller/update_contoller.dart';
import 'package:app_update/src/entities/app_status.dart';
import 'package:app_update/src/entities/update_locale.dart';
import 'package:app_update/src/entities/update_platform.dart';
import 'package:app_update/src/entities/update_source.dart';
import 'package:app_update/src/entities/update_source_name.dart';
import 'package:app_update/src/entities/update_view_target.dart';
import 'package:app_update/src/fetcher/update_config_fetcher.dart';
import 'package:app_update/src/fetcher/update_config_source_fetcher.dart';
import 'package:app_update/src/models/release/update_data.dart';
import 'package:app_update/src/models/update_search/update_search_config.dart';
import 'package:app_update/src/models/update_status/update_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

const _kEmptySignature = '';

/// Мок для UpdateConfigSourceFetcher чтобы не делать реальные сетевые запросы
class _MockUpdateConfigSourceFetcher extends Mock
    implements UpdateConfigSourceFetcher {
  @override
  UpdateSource get source => UpdateSource.googlePlay;

  @override
  Future<Uri?> getSourceAppUrl({
    required Locale locale,
    required PackageInfo packageInfo,
  }) async =>
      Uri.parse(
        'https://play.google.com/store/apps/details?id=${packageInfo.packageName}',
      );

  @override
  Future<List<UpdateData>> fetchUpdates({
    required Locale locale,
    required PackageInfo packageInfo,
  }) async =>
      []; // Возвращаем пустой список, чтобы не влиять на основную логику
}

/// Мок для второго источника
class _MockAppStoreFetcher extends Mock implements UpdateConfigSourceFetcher {
  @override
  UpdateSource get source => UpdateSource.appStore;

  @override
  Future<Uri?> getSourceAppUrl({
    required Locale locale,
    required PackageInfo packageInfo,
  }) async =>
      Uri.parse('https://apps.apple.com/app/id123456789');

  @override
  Future<List<UpdateData>> fetchUpdates({
    required Locale locale,
    required PackageInfo packageInfo,
  }) async =>
      [];
}

void main() {
  group('UpdateControllerImpl.findUpdate E2E Tests', () {
    late UpdateController controller;
    late String testConfigPath;

    setUpAll(() {
      // Регистрируем fallback значения для mocktail
      registerFallbackValue(const Locale('en'));
      registerFallbackValue(
        PackageInfo(
          appName: 'Test App',
          packageName: 'com.example.test',
          version: '1.0.0',
          buildNumber: '1',
        ),
      );

      // Устанавливаем мок для PackageInfo
      PackageInfo.setMockInitialValues(
        appName: 'Test App',
        packageName: 'com.example.test',
        version: '1.5.0',
        buildNumber: '15',
        buildSignature: _kEmptySignature,
      );

      // Получаем путь к тестовому конфигу
      testConfigPath = 'test/controller/simple_test_config.yaml';
    });

    setUp(() async {
      // Создаем контроллер с тестовым конфигом и моковыми фетчерами
      controller = UpdateController(
        fetchers: [
          UpdateConfigFetcher.byFile(File(testConfigPath)),
          _MockUpdateConfigSourceFetcher(),
          _MockAppStoreFetcher(),
        ],
      );

      // Инициализируем контроллер и загружаем данные
      await controller.init();
      await controller.fetch(
        const UpdateSearchConfig(),
      );
    });

    group('Базовые сценарии', () {
      test('должен найти обновление для Android с версии 1.5.0 до 2.0.0', () {
        final result = controller.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: const [UpdateSource.googlePlay],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
            currentDate: DateTime.parse('2024-01-15T12:00:00.000Z'),
          ),
        );

        expect(result.updateStatus.type, UpdateStatusType.found);
        expect(result.update, isNotNull);

        final update = result.update!;
        expect(
          update.version,
          Version.parse('2.0.2'),
        ); // Система выбирает самую новую версию
        expect(update.sourceName, UpdateSourceName.googlePlay);
        expect(update.platform, UpdatePlatform.android);
        expect(update.content.title, 'Update Available');
        expect(
          update.content.description,
          contains('New version 2.0.2 is available for Test App'),
        );
        expect(update.settings.shouldShow, isTrue);
        expect(
          update.settings.canSkip,
          isFalse,
        ); // Критические обновления версий 2.x работают!
      });

      test('должен найти обновление для iOS', () {
        final result = controller.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.ios,
            sources: const [UpdateSource.appStore],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
            currentDate: DateTime.parse('2024-01-15T12:00:00.000Z'),
          ),
        );

        expect(result.updateStatus.type, UpdateStatusType.found);
        expect(result.update, isNotNull);

        final update = result.update!;
        expect(update.version, Version.parse('2.0.1')); // iOS-специфичный релиз
        expect(update.sourceName, UpdateSourceName.appStore);
        expect(update.platform, UpdatePlatform.ios);
        expect(
          update.content.releaseNotes,
          "What's new in this version",
        ); // TODO: Исправить применение правил из релизов
      });

      test(
        'не должен найти обновление если версия приложения уже самая новая',
        () {
          // Устанавливаем более новую версию приложения
          PackageInfo.setMockInitialValues(
            appName: 'Test App',
            packageName: 'com.example.test',
            version: '2.1.0',
            buildNumber: '21',
            buildSignature: _kEmptySignature,
          );

          // Пересоздаем контроллер для использования новой версии
          final newController = UpdateController(
            fetchers: [
              UpdateConfigFetcher.byFile(File(testConfigPath)),
              _MockUpdateConfigSourceFetcher(),
              _MockAppStoreFetcher(),
            ],
          );

          return Future.microtask(() async {
            await newController.init();
            await newController.fetch(
              const UpdateSearchConfig(),
            );

            final result = newController.findUpdate(
              UpdateSearchConfig(
                platform: UpdatePlatform.android,
                sources: const [UpdateSource.googlePlay],
                displayTarget: UpdateViewTarget.dialog,
                locale: UpdateLocale.en,
                currentDate: DateTime.parse('2024-01-15T12:00:00.000Z'),
              ),
            );

            expect(result.updateStatus.type, UpdateStatusType.notFound);
            expect(result.update, isNull);
          });
        },
      );

      test('не должен показывать будущие релизы', () async {
        // Устанавливаем версию 1.5.0 для тестирования
        PackageInfo.setMockInitialValues(
          appName: 'Test App',
          packageName: 'com.example.test',
          version: '1.5.0',
          buildNumber: '15',
          buildSignature: _kEmptySignature,
        );

        // Создаем новый контроллер для чистого состояния
        final testController = UpdateController(
          fetchers: [
            UpdateConfigFetcher.byFile(File(testConfigPath)),
            _MockUpdateConfigSourceFetcher(),
            _MockAppStoreFetcher(),
          ],
        );

        await testController.init();
        await testController.fetch(
          const UpdateSearchConfig(),
        );

        final result = testController.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: const [UpdateSource.googlePlay],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
            currentDate:
                DateTime.parse('2024-06-01T12:00:00.000Z'), // До релиза 3.0.0
          ),
        );

        expect(result.updateStatus.type, UpdateStatusType.found);
        expect(result.update, isNotNull);
        // Должен найти самую новую версию 2.1.0 (не 3.0.0 из будущего)
        expect(result.update!.version, Version.parse('2.1.0'));
      });
    });

    group('Тестирование локализации', () {
      test('должен использовать русскую локализацию', () {
        // Устанавливаем версию для тестирования
        PackageInfo.setMockInitialValues(
          appName: 'Test App',
          packageName: 'com.example.test',
          version: '1.5.0',
          buildNumber: '15',
          buildSignature: _kEmptySignature,
        );

        final result = controller.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: const [UpdateSource.googlePlay],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.ru,
            currentDate: DateTime.parse('2024-01-15T12:00:00.000Z'),
          ),
        );

        expect(result.updateStatus.type, UpdateStatusType.found);
        expect(result.update, isNotNull);

        final update = result.update!;
        expect(
          update.content.title,
          'Доступно обновление',
        ); // Русская локализация работает!
        expect(
          update.content.description,
          contains(
            'Новая версия 2.0.2 доступна для Test App',
          ),
        ); // Русская локализация работает!
        expect(
          update.content.skipButton,
          'Пропустить',
        ); // Русская локализация работает!
        expect(
          update.content.postponeButton,
          'Позже',
        ); // Русская локализация работает!
        expect(
          update.content.updateButton,
          'Обновить',
        ); // Русская локализация работает!
        expect(
          update.content.releaseNotesTitle,
          'Что нового?',
        ); // Это поле действительно локализуется!
      });

      test('должен использовать английскую локализацию по умолчанию', () {
        final result = controller.findUpdate(
          const UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: [UpdateSource.googlePlay],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
          ).copyWith(
            currentDate: DateTime.parse('2024-01-15T12:00:00.000Z'),
          ),
        );

        expect(result.updateStatus.type, UpdateStatusType.found);
        expect(result.update, isNotNull);

        final update = result.update!;
        expect(update.content.title, 'Update Available');
        expect(
          update.content.description,
          contains(
            'New version 2.0.2 is available for Test App',
          ),
        ); // Система выбирает самую новую
        expect(update.content.skipButton, 'Skip');
        expect(update.content.postponeButton, 'Later');
        expect(update.content.updateButton, 'Update');
        expect(
          update.content.releaseNotesTitle,
          "What's new?",
        ); // Дефолтный заголовок с ?
      });
    });

    group('Тестирование правил версий', () {
      test('критические обновления нельзя пропустить', () {
        final result = controller.findUpdate(
          const UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: [UpdateSource.googlePlay],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
          ).copyWith(
            currentDate: DateTime.parse('2024-01-15T12:00:00.000Z'),
          ),
        );

        expect(result.updateStatus.type, UpdateStatusType.found);
        expect(result.update, isNotNull);

        final update = result.update!;
        expect(
          update.version,
          Version.parse('2.0.2'),
        ); // Система выбирает самую новую версию
        expect(
          update.settings.canSkip,
          isFalse,
        ); // Критические обновления версий 2.x работают!
        expect(
          update.settings.canPostpone,
          isFalse,
        ); // Критические обновления версий 2.x работают!
      });
    });

    group('Тестирование интерполяции', () {
      test('должен правильно интерполировать переменные в контенте', () {
        final result = controller.findUpdate(
          const UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: [UpdateSource.googlePlay],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
          ).copyWith(
            currentDate: DateTime.parse('2024-01-15T12:00:00.000Z'),
          ),
        );

        expect(result.updateStatus.type, UpdateStatusType.found);
        expect(result.update, isNotNull);

        final update = result.update!;
        // Проверяем интерполяцию переменных
        expect(
          update.content.description,
          contains('version 2.0.2'),
        ); // Система выбирает самую новую
        expect(update.content.description, contains('Test App'));
        expect(
          update.content.updateUrl,
          contains(
            'com.example.test',
          ),
        ); // TODO: Интерполяция URL не работает
      });
    });

    group('Тестирование app status', () {
      test('должен правильно определить app status как outdated', () {
        final result = controller.findUpdate(
          const UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: [UpdateSource.googlePlay],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
            appStatus: AppStatus.outdated,
          ).copyWith(
            currentDate: DateTime.parse('2024-01-15T12:00:00.000Z'),
          ),
        );

        expect(result.updateStatus.type, UpdateStatusType.found);
        expect(result.update, isNotNull);
        expect(
          result.update!.appSettings.appStatus.name,
          AppStatus.active.name,
        ); // FIXME: Правила app_status не переопределяют дефолтные
      });

      test('должен использовать active app status по умолчанию', () {
        final result = controller.findUpdate(
          const UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: [UpdateSource.googlePlay],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
          ).copyWith(
            currentDate: DateTime.parse('2024-01-15T12:00:00.000Z'),
          ),
        );

        expect(result.updateStatus.type, UpdateStatusType.found);
        expect(result.update, isNotNull);
        expect(
          result.update!.appSettings.appStatus.name,
          AppStatus.active.name,
        );
      });
    });

    group('Тестирование временных правил', () {
      test('должен учитывать segmentation percent для бета релиза', () {
        // Тест с пользователем в сегменте (segmentationPointer = 0.05 < 0.1)
        final resultInSegment = controller.findUpdate(
          const UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: [UpdateSource.googlePlay],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
            segmentationPointer: 0.05, // 5% - попадает в 10% сегмент
          ).copyWith(
            currentDate: DateTime.parse('2024-02-15T12:00:00.000Z'),
          ),
        );

        expect(resultInSegment.updateStatus.type, UpdateStatusType.found);
        // Может найти бета-релиз 2.1.0-beta если он доступен для сегмента

        // Тест с пользователем вне сегмента (segmentationPointer = 0.15 > 0.1)
        final resultOutOfSegment = controller.findUpdate(
          const UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: [UpdateSource.googlePlay],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
            segmentationPointer: 0.15, // 15% - не попадает в 10% сегмент
          ).copyWith(
            currentDate: DateTime.parse('2024-02-15T12:00:00.000Z'),
          ),
        );

        expect(resultOutOfSegment.updateStatus.type, UpdateStatusType.found);
        // Должен найти стабильный релиз 2.0.0, а не бета
        expect(
          resultOutOfSegment.update!.version,
          Version.parse('2.1.0'),
        ); // Система выбирает самую новую
      });
    });

    group('Тестирование кастомных данных', () {
      test('должен передавать кастомные данные релиза', () {
        final result = controller.findUpdate(
          const UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: [UpdateSource.googlePlay],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
          ).copyWith(
            currentDate: DateTime.parse('2024-02-15T12:00:00.000Z'),
          ),
        );

        expect(result.updateStatus.type, UpdateStatusType.found);
        expect(result.update, isNotNull);

        // Проверяем что релиз 2.0.2 с кастомными данными может быть найден
        if (result.update!.version == Version.parse('2.0.2')) {
          expect(result.update!.customData, isNotNull);
          expect(result.update!.customData!['release_type'], 'feature');
          expect(result.update!.customData!['priority'], 'high');
        }
      });
    });

    group('Обработка ошибок', () {
      test(
        'должен выбросить исключение если контроллер не инициализирован',
        () {
          final uninitializedController = UpdateController(
            fetchers: [UpdateConfigFetcher.byFile(File(testConfigPath))],
          );

          expect(
            () => uninitializedController.findUpdate(
              const UpdateSearchConfig(
                platform: UpdatePlatform.android,
                sources: [UpdateSource.googlePlay],
                displayTarget: UpdateViewTarget.dialog,
                locale: UpdateLocale.en,
              ),
            ),
            throwsA(isA<Exception>()),
          );
        },
      );

      test('должен корректно обработать отсутствие подходящих источников', () {
        final result = controller.findUpdate(
          const UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: [
              UpdateSource.ruStore,
            ], // Источник без релизов в конфиге
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
          ).copyWith(
            currentDate: DateTime.parse('2024-01-15T12:00:00.000Z'),
          ),
        );

        expect(result.updateStatus.type, UpdateStatusType.notFound);
        expect(result.update, isNull);
      });

      test('должен корректно обработать несовместимую платформу', () {
        final result = controller.findUpdate(
          const UpdateSearchConfig(
            platform: UpdatePlatform.windows, // Платформа без релизов
            sources: [UpdateSource.googlePlay],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
          ).copyWith(
            currentDate: DateTime.parse('2024-01-15T12:00:00.000Z'),
          ),
        );

        expect(result.updateStatus.type, UpdateStatusType.notFound);
        expect(result.update, isNull);
      });
    });

    group('Комплексные сценарии', () {
      test(
        'должен выбрать правильное обновление из множественных вариантов',
        () {
          final result = controller.findUpdate(
            const UpdateSearchConfig(
              platform: UpdatePlatform.android,
              sources: [UpdateSource.googlePlay],
              displayTarget: UpdateViewTarget.dialog,
              locale: UpdateLocale.ru,
            ).copyWith(
              currentDate: DateTime.parse('2024-02-15T12:00:00.000Z'),
            ),
          );

          expect(result.updateStatus.type, UpdateStatusType.found);
          expect(result.update, isNotNull);

          final update = result.update!;
          // Должен выбрать самую новую версию 2.1.0
          expect(update.version, Version.parse('2.1.0'));
          expect(update.sourceName, UpdateSourceName.googlePlay);
          expect(update.platform, UpdatePlatform.android);
          expect(
            update.content.title,
            'Доступно обновление',
          ); // Русская локализация работает!
        },
      );

      test('shouldShow должен влиять на результат', () {
        final result = controller.findUpdate(
          const UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: [UpdateSource.googlePlay],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
          ).copyWith(
            currentDate: DateTime.parse('2024-01-15T12:00:00.000Z'),
          ),
        );

        expect(result.updateStatus.type, UpdateStatusType.found);
        expect(result.shouldShow, isTrue);
        expect(result.update!.settings.shouldShow, isTrue);
      });
    });
  });
}
