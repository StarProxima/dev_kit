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

/// Mock для source fetcher чтобы не делать сетевые запросы
class MockUpdateConfigSourceFetcher extends Mock
    implements UpdateConfigSourceFetcher {
  @override
  UpdateSource get source => UpdateSource.googlePlay;

  @override
  Future<Uri?> getSourceAppUrl({
    required Locale locale,
    required PackageInfo packageInfo,
  }) async =>
      Uri.parse(
          'https://play.google.com/store/apps/details?id=${packageInfo.packageName}');

  @override
  Future<List<UpdateData>> fetchUpdates({
    required Locale locale,
    required PackageInfo packageInfo,
  }) async =>
      [];
}

void main() {
  group('UpdateController E2E Comprehensive Tests', () {
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      registerFallbackValue(const Locale('en'));
      registerFallbackValue(
        PackageInfo(
          appName: 'TestApp',
          packageName: 'com.example.app',
          version: '1.0.0',
          buildNumber: '1',
        ),
      );
    });

    group('Базовая функциональность с простым конфигом', () {
      test('должен найти простое обновление', () async {
        // Arrange
        const yamlConfig = '''
sources:
  - name: googlePlay
    url: https://play.google.com/store/apps/details?id={appPackageName}
    platforms: [android]

content:
  - data:
      title: "Update Available"
      description: "Version {updateVersion} is now available"
      update_url: "https://example.com/update"
      release_notes_title: "What's new?"
      skip_button: "Skip"
      postpone_button: "Later"
      update_button: "Update"

settings:
  - data:
      should_show: true

releases:
  - version: "2.0.0"
    date: "2024-01-01T10:00:00"
    sources: [googlePlay]
''';

        PackageInfo.setMockInitialValues(
          appName: 'TestApp',
          packageName: 'com.example.app',
          version: '1.5.0',
          buildNumber: '15',
          buildSignature: '',
        );

        final configFile = await _createTempConfig(yamlConfig);
        final controller = UpdateController(
          fetchers: [
            UpdateConfigFetcher.byFile(configFile),
            MockUpdateConfigSourceFetcher(),
          ],
        );

        await controller.init();
        await controller.fetch(const UpdateSearchConfig());

        // Act
        final result = controller.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: const [UpdateSource.googlePlay],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
            currentDate: DateTime.parse('2024-01-15T10:00:00'),
          ),
        );

        // Assert
        expect(result.updateStatus.type, UpdateStatusType.found);
        expect(result.update, isNotNull);
        expect(result.update!.version, Version.parse('2.0.0'));
        expect(result.update!.content.title, 'Update Available');
        expect(result.update!.content.description, contains('2.0.0'));
        expect(result.update!.settings.shouldShow, isTrue);

        // Cleanup
        await configFile.delete();
      });

      test('не должен найти обновление для актуальной версии', () async {
        // Arrange
        const yamlConfig = '''
sources:
  - name: googlePlay
    platforms: [android]

releases:
  - version: "2.0.0"
    date: "2024-01-01T10:00:00"
    sources: [googlePlay]
''';

        PackageInfo.setMockInitialValues(
          appName: 'TestApp',
          packageName: 'com.example.app',
          version: '2.0.0', // Та же версия что и релиз
          buildNumber: '20',
          buildSignature: '',
        );

        final configFile = await _createTempConfig(yamlConfig);
        final controller = UpdateController(
          fetchers: [UpdateConfigFetcher.byFile(configFile)],
        );

        await controller.init();
        await controller.fetch(const UpdateSearchConfig());

        // Act
        final result = controller.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: const [UpdateSource.googlePlay],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
            currentDate: DateTime.parse('2024-01-15T10:00:00'),
          ),
        );

        // Assert
        expect(result.updateStatus.type, UpdateStatusType.notFound);
        expect(result.update, isNull);

        // Cleanup
        await configFile.delete();
      });
    });

    group('Многоязычность и локализация', () {
      test('должен правильно применять локализацию', () async {
        // Arrange
        const yamlConfig = '''
sources:
  - name: googlePlay
    platforms: [android]
  - name: appStore
    platforms: [ios]

content:
  # Базовый контент на английском
  - data:
      title: "Update Available"
      description: "Version {updateVersion} is available"
      update_url: "https://example.com/update"
      release_notes_title: "What's new?"
      update_button: "Update"
      skip_button: "Skip"
      postpone_button: "Later"
      
  # Русская локализация
  - locale_is: ru
    data:
      title: "Доступно обновление"
      description: "Доступна версия {updateVersion}"
      update_button: "Обновить"
      skip_button: "Пропустить"
      
  # Специфичная локализация для iOS
  - locale_is: ru
    platform_is: ios
    data:
      title: "Обновление для iOS"
      description: "Версия {updateVersion} доступна в App Store"

settings:
  - data:
      should_show: true

releases:
  - version: "2.1.0"
    date: "2024-01-01T10:00:00"
    sources: [googlePlay, appStore]
''';

        PackageInfo.setMockInitialValues(
          appName: 'TestApp',
          packageName: 'com.example.app',
          version: '2.0.0',
          buildNumber: '20',
          buildSignature: '',
        );

        final configFile = await _createTempConfig(yamlConfig);
        final controller = UpdateController(
          fetchers: [UpdateConfigFetcher.byFile(configFile)],
        );

        await controller.init();
        await controller.fetch(const UpdateSearchConfig());

        // Act - Русская локализация Android
        final androidRuResult = controller.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: const [UpdateSource.googlePlay],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.ru,
            currentDate: DateTime.parse('2024-01-15T10:00:00'),
          ),
        );

        // Act - Русская локализация iOS
        final iosRuResult = controller.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.ios,
            sources: const [UpdateSource.appStore],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.ru,
            currentDate: DateTime.parse('2024-01-15T10:00:00'),
          ),
        );

        // Act - Английская локализация
        final enResult = controller.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: const [UpdateSource.googlePlay],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
            currentDate: DateTime.parse('2024-01-15T10:00:00'),
          ),
        );

        // Assert - Русский Android
        expect(androidRuResult.update!.content.title, 'Доступно обновление');
        expect(androidRuResult.update!.content.description,
            contains('Доступна версия 2.1.0'));
        expect(androidRuResult.update!.content.updateButton, 'Обновить');

        // Assert - Русский iOS (более специфичное правило)
        expect(iosRuResult.update!.content.title, 'Обновление для iOS');
        expect(iosRuResult.update!.content.description, contains('App Store'));

        // Assert - Английский
        expect(enResult.update!.content.title, 'Update Available');
        expect(enResult.update!.content.updateButton, 'Update');

        // Cleanup
        await configFile.delete();
      });

      test('должен использовать fallback локализацию', () async {
        // Arrange
        const yamlConfig = '''
sources:
  - name: googlePlay
    platforms: [android]

content:
  - data:
      title: "Default Title"
      description: "Default description"
      update_url: "https://example.com/update"
      release_notes_title: "What's new?"
      skip_button: "Skip"
      postpone_button: "Later"
      update_button: "Update"
      
  - locale_is: en
    data:
      title: "English Title"

releases:
  - version: "2.0.0"
    date: "2024-01-01T10:00:00"
    sources: [googlePlay]
''';

        PackageInfo.setMockInitialValues(
          appName: 'TestApp',
          packageName: 'com.example.app',
          version: '1.0.0',
          buildNumber: '10',
          buildSignature: '',
        );

        final configFile = await _createTempConfig(yamlConfig);
        final controller = UpdateController(
          fetchers: [UpdateConfigFetcher.byFile(configFile)],
        );

        await controller.init();
        await controller.fetch(const UpdateSearchConfig());

        // Act - Несуществующая локаль должна использовать fallback
        final result = controller.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: const [UpdateSource.googlePlay],
            displayTarget: UpdateViewTarget.dialog,
            locale: const UpdateLocale(
                Locale('fr', 'FR')), // Французская локаль отсутствует
            currentDate: DateTime.parse('2024-01-15T10:00:00'),
          ),
        );

        // Assert - Должен использовать базовое правило
        expect(result.update!.content.title, 'Default Title');

        // Cleanup
        await configFile.delete();
      });
    });

    group('App Status Rules и жизненный цикл версий', () {
      test('должен правильно определять статусы версий с временными правилами',
          () async {
        // Arrange
        const yamlConfig = r'''
sources:
  - name: googlePlay
    platforms: [android]

content:
  - app_status_is: active
    data:
      title: "Optional Update"
      
  - app_status_is: outdated
    data:
      title: "Recommended Update"
      
  - app_status_is: unsupported
    data:
      title: "Critical Update Required"

settings:
  - app_status_is: active
    data:
      should_show: true
      can_skip: true
      can_postpone: true
      
  - app_status_is: outdated
    data:
      should_show: true
      can_skip: true
      can_postpone: true
      
  - app_status_is: unsupported
    data:
      should_show: true
      can_skip: false
      can_postpone: false

app_settings:
  # По умолчанию все активные
  - app_version_is: any
    data:
      app_status: active
      
  # Версии старше 2 дней становятся outdated
  - app_version_is: any
    date: $localReleaseDate
    delay_hours: 48
    data:
      app_status: outdated
      
  # Версии старше 30 дней становятся unsupported
  - app_version_is: any
    date: $localReleaseDate
    delay_hours: 720  # 30 дней
    data:
      app_status: unsupported

releases:
  - version: "2.0.0"
    date: "2024-01-01T10:00:00"
    sources: [googlePlay]
''';

        final configFile = await _createTempConfig(yamlConfig);
        final controller = UpdateController(
          fetchers: [UpdateConfigFetcher.byFile(configFile)],
        );

        await controller.init();
        await controller.fetch(const UpdateSearchConfig());

        // Act - Свежая версия (active)
        PackageInfo.setMockInitialValues(
          appName: 'TestApp',
          packageName: 'com.example.app',
          version: '1.9.0',
          buildNumber: '19',
          buildSignature: '',
        );

        final activeResult = controller.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: const [UpdateSource.googlePlay],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
            currentDate: DateTime.parse('2024-01-15T10:00:00'),
            localReleaseDate:
                DateTime.parse('2024-01-14T10:00:00'), // 1 день назад
          ),
        );

        // Act - Устаревшая версия (outdated)
        final outdatedResult = controller.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: const [UpdateSource.googlePlay],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
            currentDate: DateTime.parse('2024-01-15T10:00:00'),
            localReleaseDate:
                DateTime.parse('2024-01-10T10:00:00'), // 5 дней назад
          ),
        );

        // Act - Неподдерживаемая версия (unsupported)
        final unsupportedResult = controller.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: const [UpdateSource.googlePlay],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
            currentDate: DateTime.parse('2024-01-15T10:00:00'),
            localReleaseDate:
                DateTime.parse('2023-12-01T10:00:00'), // 45 дней назад
          ),
        );

        // Assert - Active
        expect(activeResult.update!.content.title, 'Optional Update');
        expect(activeResult.update!.settings.canSkip, isTrue);
        expect(activeResult.update!.settings.canPostpone, isTrue);

        // Assert - Outdated
        expect(outdatedResult.update!.content.title, 'Recommended Update');
        expect(outdatedResult.update!.settings.canSkip, isTrue);
        expect(outdatedResult.update!.settings.canPostpone, isTrue);

        // Assert - Unsupported
        expect(unsupportedResult.update!.content.title,
            'Critical Update Required');
        expect(unsupportedResult.update!.settings.canSkip, isFalse);
        expect(unsupportedResult.update!.settings.canPostpone, isFalse);

        // Cleanup
        await configFile.delete();
      });

      test('должен применять app status по версионным ограничениям', () async {
        // Arrange
        const yamlConfig = '''
sources:
  - name: googlePlay
    platforms: [android]

content:
  - app_status_is: active
    data:
      title: "Current Version"
      description: "Current version"
      update_url: "https://example.com/update"
      release_notes_title: "What's new?"
      skip_button: "Skip"
      postpone_button: "Later"
      update_button: "Update"
      
  - app_status_is: deprecated
    data:
      title: "Please Update Soon"
      description: "Please update soon"
      update_url: "https://example.com/update"
      release_notes_title: "What's new?"
      skip_button: "Skip"
      postpone_button: "Later"
      update_button: "Update"
      
  - app_status_is: unsupported
    data:
      title: "Update Required"
      description: "Update required"
      update_url: "https://example.com/update"
      release_notes_title: "What's new?"
      skip_button: "Skip"
      postpone_button: "Later"
      update_button: "Update"

settings:
  - data:
      should_show: true

app_settings:
  # По умолчанию active
  - app_version_is: any
    data:
      app_status: active
      
  # Версии 1.x deprecated
  - app_version_is: ">=1.0.0 <2.0.0"
    data:
      app_status: deprecated
      
  # Версии ниже 1.0 unsupported
  - app_version_is: "<1.0.0"
    data:
      app_status: unsupported

releases:
  - version: "3.0.0"
    date: "2024-01-01T10:00:00"
    sources: [googlePlay]
''';

        final configFile = await _createTempConfig(yamlConfig);

        // Act & Assert - Версия 2.5.0 (active)
        PackageInfo.setMockInitialValues(
          appName: 'TestApp',
          packageName: 'com.example.app',
          version: '2.5.0',
          buildNumber: '25',
          buildSignature: '',
        );

        final activeController = UpdateController(
          fetchers: [UpdateConfigFetcher.byFile(configFile)],
        );
        await activeController.init();
        await activeController.fetch(const UpdateSearchConfig());

        final activeResult = activeController.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: const [UpdateSource.googlePlay],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
            currentDate: DateTime.parse('2024-01-15T10:00:00'),
          ),
        );

        expect(activeResult.update!.content.title, 'Current Version');

        // Act & Assert - Версия 1.5.0 (deprecated)
        PackageInfo.setMockInitialValues(
          appName: 'TestApp',
          packageName: 'com.example.app',
          version: '1.5.0',
          buildNumber: '15',
          buildSignature: '',
        );

        final deprecatedController = UpdateController(
          fetchers: [UpdateConfigFetcher.byFile(configFile)],
        );
        await deprecatedController.init();
        await deprecatedController.fetch(const UpdateSearchConfig());

        final deprecatedResult = deprecatedController.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: const [UpdateSource.googlePlay],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
            currentDate: DateTime.parse('2024-01-15T10:00:00'),
          ),
        );

        expect(deprecatedResult.update!.content.title, 'Please Update Soon');

        // Act & Assert - Версия 0.9.0 (unsupported)
        PackageInfo.setMockInitialValues(
          appName: 'TestApp',
          packageName: 'com.example.app',
          version: '0.9.0',
          buildNumber: '9',
          buildSignature: '',
        );

        final unsupportedController = UpdateController(
          fetchers: [UpdateConfigFetcher.byFile(configFile)],
        );
        await unsupportedController.init();
        await unsupportedController.fetch(const UpdateSearchConfig());

        final unsupportedResult = unsupportedController.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: const [UpdateSource.googlePlay],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
            currentDate: DateTime.parse('2024-01-15T10:00:00'),
          ),
        );

        expect(unsupportedResult.update!.content.title, 'Update Required');

        // Cleanup
        await configFile.delete();
      });
    });

    group('Временные правила: segmentation, rollout, delay', () {
      test('должен правильно обрабатывать segmentation для beta релизов',
          () async {
        // Arrange
        const yamlConfig = '''
sources:
  - name: googlePlay
    platforms: [android]

content:
  - data:
      title: "Regular Update"
      
  - platform_is: android
    data:
      title: "Beta Update"
      is_beta: true

app_settings:
  # Базовое правило - все активные
  - app_version_is: any
    data:
      app_status: active
      
  # Beta релиз только для 30% пользователей
  - app_version_is: ">=2.1.0-beta"
    segmentation_percent: 30
    data:
      app_status: active
      is_beta_available: true

releases:
  - version: "2.0.0"
    date: "2024-01-01T10:00:00"
    sources: [googlePlay]
    
  - version: "2.1.0-beta.1"
    date: "2024-01-10T10:00:00"
    sources: [googlePlay]
''';

        PackageInfo.setMockInitialValues(
          appName: 'TestApp',
          packageName: 'com.example.app',
          version: '1.9.0',
          buildNumber: '19',
          buildSignature: '',
        );

        final configFile = await _createTempConfig(yamlConfig);
        final controller = UpdateController(
          fetchers: [UpdateConfigFetcher.byFile(configFile)],
        );

        await controller.init();
        await controller.fetch(const UpdateSearchConfig());

        // Act - Пользователь в beta сегменте (20% < 30%)
        final betaUserResult = controller.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: const [UpdateSource.googlePlay],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
            currentDate: DateTime.parse('2024-01-15T10:00:00'),
            segmentationPointer: 0.2, // 20%
          ),
        );

        // Act - Пользователь вне beta сегмента (40% > 30%)
        final regularUserResult = controller.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: const [UpdateSource.googlePlay],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
            currentDate: DateTime.parse('2024-01-15T10:00:00'),
            segmentationPointer: 0.4, // 40%
          ),
        );

        // Assert - Beta пользователь должен получить beta версию
        expect(betaUserResult.update!.version.toString(), contains('beta'));
        expect(
            betaUserResult
                .update!.appSettings.customParams?['is_beta_available'],
            isTrue);

        // Assert - Обычный пользователь должен получить стабильную версию
        expect(regularUserResult.update!.version, Version.parse('2.0.0'));
        expect(
            regularUserResult
                .update!.appSettings.customParams?['is_beta_available'],
            isNull);

        // Cleanup
        await configFile.delete();
      });

      test('должен применять rollout правила с временными ограничениями',
          () async {
        // Arrange
        const yamlConfig = '''
sources:
  - name: googlePlay
    platforms: [android]

app_settings:
  # Базовое правило
  - app_version_is: any
    data:
      app_status: active
      
  # Поэтапный rollout для критических версий
  - app_version_is: ">=2.0.0"
    date: "2024-01-01T10:00:00"
    delay_hours: 24      # Задержка 24 часа
    rollout_hours: 72    # Раскатка на 3 дня
    segmentation_percent: 50  # Только 50% пользователей
    data:
      app_status: outdated

releases:
  - version: "2.0.0"
    date: "2024-01-01T10:00:00"
    sources: [googlePlay]
''';

        PackageInfo.setMockInitialValues(
          appName: 'TestApp',
          packageName: 'com.example.app',
          version: '1.8.0',
          buildNumber: '18',
          buildSignature: '',
        );

        final configFile = await _createTempConfig(yamlConfig);
        final controller = UpdateController(
          fetchers: [UpdateConfigFetcher.byFile(configFile)],
        );

        await controller.init();
        await controller.fetch(const UpdateSearchConfig());

        // Act - До начала rollout (до delay)
        final beforeDelayResult = controller.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: const [UpdateSource.googlePlay],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
            currentDate:
                DateTime.parse('2024-01-01T20:00:00'), // 10 часов после релиза
            segmentationPointer: 0.3,
            rolloutPointer: 0.3,
          ),
        );

        // Act - В середине rollout (после delay)
        final duringRolloutResult = controller.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: const [UpdateSource.googlePlay],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
            currentDate:
                DateTime.parse('2024-01-02T20:00:00'), // 34 часа после релиза
            segmentationPointer: 0.3, // В сегменте
            rolloutPointer: 0.3, // В rollout
          ),
        );

        // Act - После rollout
        final afterRolloutResult = controller.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: const [UpdateSource.googlePlay],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
            currentDate:
                DateTime.parse('2024-01-05T10:00:00'), // 4 дня после релиза
            segmentationPointer: 0.3,
            rolloutPointer: 0.8, // Вне rollout группы
          ),
        );

        // Assert - До delay правило не должно применяться
        expect(
            beforeDelayResult.update!.appSettings.appStatus, AppStatus.active);

        // Assert - В rollout правило применяется для подходящих пользователей
        expect(duringRolloutResult.update!.appSettings.appStatus,
            AppStatus.outdated);

        // Assert - После rollout правило применяется ко всем
        expect(afterRolloutResult.update!.appSettings.appStatus,
            AppStatus.outdated);

        // Cleanup
        await configFile.delete();
      });
    });

    group('Комплексные сценарии с множественными источниками', () {
      test('должен правильно выбирать между источниками по приоритету',
          () async {
        // Arrange
        const yamlConfig = '''
sources:
  - name: googlePlay
    url: https://play.google.com/store/apps/details?id={appPackageName}
    platforms: [android]
    
  - name: appStore
    url: https://apps.apple.com/app/id123456789
    platforms: [ios, macos]
    
  - name: ruStore
    url: https://apps.rustore.ru/app/{appPackageName}
    platforms: [android]
    content:
      - locale_is: ru
        data:
          store_name: "RuStore"
          special_offer: "Без комиссий!"
          
  - name: fdroid
    url: https://f-droid.org/packages/{appPackageName}
    platforms: [android]

content:
  - data:
      title: "Update from {sourceName}"
      description: "Version {updateVersion} via {sourceName}"

releases:
  # Один релиз доступен во всех источниках
  - version: "2.0.0"
    date: "2024-01-01T10:00:00"
    sources: [googlePlay, ruStore, fdroid]
    
  # Эксклюзивный релиз только в Google Play (например, с Google Services)
  - version: "2.1.0"
    date: "2024-01-10T10:00:00"
    sources: [googlePlay]
    content:
      - data:
          release_notes: "Exclusive Google Play features"
          
  # iOS релиз
  - version: "2.0.5"
    date: "2024-01-05T10:00:00"
    sources: [appStore]
''';

        PackageInfo.setMockInitialValues(
          appName: 'TestApp',
          packageName: 'com.example.app',
          version: '1.9.0',
          buildNumber: '19',
          buildSignature: '',
        );

        final configFile = await _createTempConfig(yamlConfig);
        final controller = UpdateController(
          fetchers: [UpdateConfigFetcher.byFile(configFile)],
        );

        await controller.init();
        await controller.fetch(const UpdateSearchConfig());

        // Act - Множественные источники Android (должен выбрать первый по приоритету)
        final multipleSourcesResult = controller.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: const [
              UpdateSource.googlePlay,
              UpdateSource.ruStore,
              UpdateSource.custom(UpdateSourceName.custom('fdroid')),
            ],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
            currentDate: DateTime.parse('2024-01-15T10:00:00'),
          ),
        );

        // Act - Только Google Play (должен найти эксклюзивную версию)
        final googlePlayOnlyResult = controller.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: const [UpdateSource.googlePlay],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
            currentDate: DateTime.parse('2024-01-15T10:00:00'),
          ),
        );

        // Act - Только RuStore
        final ruStoreOnlyResult = controller.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: const [UpdateSource.ruStore],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.ru,
            currentDate: DateTime.parse('2024-01-15T10:00:00'),
          ),
        );

        // Act - iOS App Store
        final iosResult = controller.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.ios,
            sources: const [UpdateSource.appStore],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
            currentDate: DateTime.parse('2024-01-15T10:00:00'),
          ),
        );

        // Assert - Должен выбрать самую новую доступную версию из первого источника
        expect(multipleSourcesResult.update!.version, Version.parse('2.1.0'));
        expect(multipleSourcesResult.update!.sourceName,
            UpdateSourceName.googlePlay);

        // Assert - Google Play эксклюзив
        expect(googlePlayOnlyResult.update!.version, Version.parse('2.1.0'));
        expect(googlePlayOnlyResult.update!.rawContent.releaseNotes,
            contains('Exclusive'));

        // Assert - RuStore с кастомным контентом
        expect(ruStoreOnlyResult.update!.version, Version.parse('2.0.0'));
        expect(ruStoreOnlyResult.update!.sourceName, UpdateSourceName.ruStore);
        expect(ruStoreOnlyResult.update!.content.customParams?['store_name'],
            'RuStore');

        // Assert - iOS версия
        expect(iosResult.update!.version, Version.parse('2.0.5'));
        expect(iosResult.update!.platform, UpdatePlatform.ios);

        // Cleanup
        await configFile.delete();
      });

      test('должен корректно обрабатывать platform-specific переопределения',
          () async {
        // Arrange
        const yamlConfig = '''
sources:
  - name: universal
    platforms: [android, ios, windows, macos, linux]

content:
  # Базовый контент
  - data:
      title: "Universal Update"
      description: "Works on all platforms"
      
  # Специфично для мобильных
  - platform_is: [android, ios]
    data:
      title: "Mobile Update"
      mobile_specific: true
      
  # Специфично для desktop
  - platform_is: [windows, macos, linux]
    data:
      title: "Desktop Update"
      desktop_features: true

settings:
  # Базовые настройки
  - data:
      should_show: true
      can_skip: true
      
  # На мобильных нельзя откладывать
  - platform_is: [android, ios]
    data:
      can_postpone: false
      
  # На desktop можно все
  - platform_is: [windows, macos, linux]
    data:
      can_postpone: true
      postpone_hours: 24

releases:
  - version: "3.0.0"
    date: "2024-01-01T10:00:00"
    sources: [universal]
    
    # Platform-specific overrides в релизе
    content:
      - platform_is: android
        data:
          android_feature: "Google Play Integration"
          
      - platform_is: ios
        data:
          ios_feature: "App Store Integration"
          
      - platform_is: windows
        data:
          windows_feature: "Windows Store Integration"
''';

        PackageInfo.setMockInitialValues(
          appName: 'TestApp',
          packageName: 'com.example.app',
          version: '2.5.0',
          buildNumber: '25',
          buildSignature: '',
        );

        final configFile = await _createTempConfig(yamlConfig);
        final controller = UpdateController(
          fetchers: [UpdateConfigFetcher.byFile(configFile)],
        );

        await controller.init();
        await controller.fetch(const UpdateSearchConfig());

        // Act - Android
        final androidResult = controller.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: const [
              UpdateSource.custom(UpdateSourceName.custom('universal')),
            ],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
            currentDate: DateTime.parse('2024-01-15T10:00:00'),
          ),
        );

        // Act - iOS
        final iosResult = controller.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.ios,
            sources: const [
              UpdateSource.custom(UpdateSourceName.custom('universal')),
            ],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
            currentDate: DateTime.parse('2024-01-15T10:00:00'),
          ),
        );

        // Act - Windows
        final windowsResult = controller.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.windows,
            sources: const [
              UpdateSource.custom(UpdateSourceName.custom('universal')),
            ],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
            currentDate: DateTime.parse('2024-01-15T10:00:00'),
          ),
        );

        // Assert - Android (мобильные правила + android-специфичный контент)
        expect(androidResult.update!.content.title, 'Mobile Update');
        expect(androidResult.update!.content.customParams?['mobile_specific'],
            isTrue);
        expect(androidResult.update!.content.customParams?['android_feature'],
            'Google Play Integration');
        expect(androidResult.update!.settings.canPostpone, isFalse);

        // Assert - iOS (мобильные правила + ios-специфичный контент)
        expect(iosResult.update!.content.title, 'Mobile Update');
        expect(
            iosResult.update!.content.customParams?['mobile_specific'], isTrue);
        expect(iosResult.update!.content.customParams?['ios_feature'],
            'App Store Integration');
        expect(iosResult.update!.settings.canPostpone, isFalse);

        // Assert - Windows (desktop правила + windows-специфичный контент)
        expect(windowsResult.update!.content.title, 'Desktop Update');
        expect(windowsResult.update!.content.customParams?['desktop_features'],
            isTrue);
        expect(windowsResult.update!.content.customParams?['windows_feature'],
            'Windows Store Integration');
        expect(windowsResult.update!.settings.canPostpone, isTrue);

        // Cleanup
        await configFile.delete();
      });
    });

    group('Интерполяция переменных и кастомные данные', () {
      test('должен интерполировать все доступные переменные', () async {
        // Arrange
        const yamlConfig = '''
sources:
  - name: testStore
    url: https://store.example.com/{appPackageName}
    platforms: [android]

content:
  - data:
      title: "Update {appName} from {localVersion} to {updateVersion}"
      description: |
        Hello {appName} user!
        Current version: {localVersion} (build {buildNumber})
        New version: {updateVersion}
        Package: {appPackageName}
        Platform: {platform}
        Source: {sourceName}
        Date: {currentDate}
      update_url: "https://store.example.com/{appPackageName}/download/{updateVersion}"

custom_data:
  app_category: "productivity"
  target_audience: "developers"
  feature_flags:
    - "new_ui"
    - "dark_mode"
    - "analytics"

releases:
  - version: "2.3.0"
    date: "2024-01-01T10:00:00"
    sources: [testStore]
    content:
      - data:
          release_notes: |
            What's new in {updateVersion}:
            - Improved performance for {appName}
            - New features for {platform}
        custom_data:
          changelog: |
            What's new in {updateVersion}:
            - Improved performance for {appName}
            - New features for {platform}
          custom_field: "Value for {appPackageName}"
    custom_data:
      release_type: "major"
      requires_restart: true
''';

        PackageInfo.setMockInitialValues(
          appName: 'AwesomeApp',
          packageName: 'com.example.awesomeapp',
          version: '2.1.5',
          buildNumber: '125',
          buildSignature: '',
        );

        final configFile = await _createTempConfig(yamlConfig);
        final controller = UpdateController(
          fetchers: [UpdateConfigFetcher.byFile(configFile)],
        );

        await controller.init();
        await controller.fetch(const UpdateSearchConfig());

        // Act
        final result = controller.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: const [
              UpdateSource.custom(UpdateSourceName.custom('testStore')),
            ],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
            currentDate: DateTime.parse('2024-01-15T14:30:00'),
          ),
        );

        // Assert - Интерполяция в основном контенте
        expect(result.update!.content.title,
            'Update AwesomeApp from 2.1.5+125 to 2.3.0');
        expect(result.update!.content.description,
            contains('Hello AwesomeApp user!'));
        expect(result.update!.content.description,
            contains('Current version: 2.1.5+125'));
        expect(
            result.update!.content.description, contains('New version: 2.3.0'));
        expect(result.update!.content.description,
            contains('Package: com.example.awesomeapp'));
        expect(
            result.update!.content.description, contains('Platform: android'));
        expect(
            result.update!.content.description, contains('Source: testStore'));

        // Assert - Интерполяция URL
        expect(result.update!.content.updateUrl,
            'https://store.example.com/com.example.awesomeapp/download/2.3.0');

        // Assert - Интерполяция в release контенте
        expect(result.update!.content.releaseNotes,
            contains("What's new in 2.3.0:"));
        expect(result.update!.content.releaseNotes,
            contains('Improved performance for AwesomeApp'));
        expect(result.update!.content.releaseNotes,
            contains('New features for android'));
        expect(result.update!.content.customParams?['changelog'],
            contains("What's new in 2.3.0:"));
        expect(result.update!.content.customParams?['custom_field'],
            'Value for com.example.awesomeapp');

        // Assert - Кастомные данные
        expect(
            result.searchData!.customParams?['app_category'], 'productivity');
        expect(result.searchData!.customParams?['feature_flags'],
            contains('new_ui'));
        expect(result.update!.customParams?['release_type'], 'major');
        expect(result.update!.customParams?['requires_restart'], isTrue);

        // Cleanup
        await configFile.delete();
      });

      test('должен правильно мерджить кастомные данные из разных источников',
          () async {
        // Arrange
        const yamlConfig = '''
sources:
  - name: mainStore
    platforms: [android]

# Глобальные кастомные данные
custom_data:
  environment: "production"
  analytics_enabled: true
  theme: "light"

content:
  - data:
      title: "Update Available"
      
  # Правило с кастомными данными  
  - platform_is: android
    custom_data:
      android_specific: true
      theme: "dark"  # Переопределяет глобальное
    data:
      android_features: "enabled"

releases:
  - version: "2.0.0"
    date: "2024-01-01T10:00:00"
    sources: [mainStore]
    custom_data:
      release_channel: "stable"
      analytics_enabled: false  # Переопределяет глобальное
      beta_features: false
    
    content:
      - platform_is: android
        custom_data:
          performance_mode: "optimized"
        data:
          android_optimization: "enabled"
''';

        PackageInfo.setMockInitialValues(
          appName: 'TestApp',
          packageName: 'com.example.app',
          version: '1.5.0',
          buildNumber: '15',
          buildSignature: '',
        );

        final configFile = await _createTempConfig(yamlConfig);
        final controller = UpdateController(
          fetchers: [UpdateConfigFetcher.byFile(configFile)],
        );

        await controller.init();
        await controller.fetch(const UpdateSearchConfig());

        // Act
        final result = controller.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: const [
              UpdateSource.custom(UpdateSourceName.custom('mainStore')),
            ],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
            currentDate: DateTime.parse('2024-01-15T10:00:00'),
          ),
        );

        // Assert - Проверяем merged кастомные данные в searchData
        final searchcustomParams = result.searchData!.customParams!;
        expect(
            searchcustomParams['environment'], 'production'); // Из глобальных
        expect(searchcustomParams['analytics_enabled'],
            isFalse); // Переопределено в release
        expect(searchcustomParams['theme'],
            'dark'); // Переопределено в content правиле
        expect(searchcustomParams['android_specific'],
            isTrue); // Из content правила
        expect(searchcustomParams['release_channel'], 'stable'); // Из release
        expect(searchcustomParams['performance_mode'],
            'optimized'); // Из release content

        // Assert - Кастомные данные в update
        final updatecustomParams = result.update!.customParams!;
        expect(updatecustomParams['release_channel'], 'stable');
        expect(updatecustomParams['beta_features'], isFalse);

        // Cleanup
        await configFile.delete();
      });
    });

    group('Edge Cases и обработка ошибок', () {
      test('должен корректно обрабатывать пустой конфиг', () async {
        // Arrange
        const yamlConfig = '''
# Минимальный конфиг без релизов
sources: []
content: []
settings: []
app_settings: []
releases: []
''';

        PackageInfo.setMockInitialValues(
          appName: 'TestApp',
          packageName: 'com.example.app',
          version: '1.0.0',
          buildNumber: '10',
          buildSignature: '',
        );

        final configFile = await _createTempConfig(yamlConfig);
        final controller = UpdateController(
          fetchers: [UpdateConfigFetcher.byFile(configFile)],
        );

        await controller.init();
        await controller.fetch(const UpdateSearchConfig());

        // Act
        final result = controller.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: const [UpdateSource.googlePlay],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
            currentDate: DateTime.parse('2024-01-15T10:00:00'),
          ),
        );

        // Assert
        expect(result.updateStatus.type, UpdateStatusType.notFound);
        expect(result.update, isNull);

        // Cleanup
        await configFile.delete();
      });

      test('должен обрабатывать будущие релизы', () async {
        // Arrange
        const yamlConfig = '''
sources:
  - name: testStore
    platforms: [android]

releases:
  - version: "2.0.0"
    date: "2024-12-31T23:59:59"  # Будущий релиз
    sources: [testStore]
    
  - version: "1.5.0"
    date: "2024-01-01T10:00:00"  # Прошлый релиз
    sources: [testStore]
''';

        PackageInfo.setMockInitialValues(
          appName: 'TestApp',
          packageName: 'com.example.app',
          version: '1.0.0',
          buildNumber: '10',
          buildSignature: '',
        );

        final configFile = await _createTempConfig(yamlConfig);
        final controller = UpdateController(
          fetchers: [UpdateConfigFetcher.byFile(configFile)],
        );

        await controller.init();
        await controller.fetch(const UpdateSearchConfig());

        // Act
        final result = controller.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: const [
              UpdateSource.custom(UpdateSourceName.custom('testStore')),
            ],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
            currentDate:
                DateTime.parse('2024-01-15T10:00:00'), // До будущего релиза
          ),
        );

        // Assert - Должен найти только доступный релиз 1.5.0, не будущий 2.0.0
        expect(result.update!.version, Version.parse('1.5.0'));

        // Cleanup
        await configFile.delete();
      });

      test('должен правильно обрабатывать несовместимые платформы и источники',
          () async {
        // Arrange
        const yamlConfig = '''
sources:
  - name: iosOnlyStore
    platforms: [ios]
    
  - name: androidOnlyStore  
    platforms: [android]

releases:
  - version: "2.0.0"
    date: "2024-01-01T10:00:00"
    sources: [iosOnlyStore]
    
  - version: "1.9.0"
    date: "2024-01-01T10:00:00"
    sources: [androidOnlyStore]
''';

        PackageInfo.setMockInitialValues(
          appName: 'TestApp',
          packageName: 'com.example.app',
          version: '1.0.0',
          buildNumber: '10',
          buildSignature: '',
        );

        final configFile = await _createTempConfig(yamlConfig);
        final controller = UpdateController(
          fetchers: [UpdateConfigFetcher.byFile(configFile)],
        );

        await controller.init();
        await controller.fetch(const UpdateSearchConfig());

        // Act - Android платформа с iOS источником
        final incompatibleResult = controller.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: const [
              UpdateSource.custom(UpdateSourceName.custom('iosOnlyStore')),
            ],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
            currentDate: DateTime.parse('2024-01-15T10:00:00'),
          ),
        );

        // Act - Android платформа с совместимым источником
        final compatibleResult = controller.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: const [
              UpdateSource.custom(UpdateSourceName.custom('androidOnlyStore')),
            ],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
            currentDate: DateTime.parse('2024-01-15T10:00:00'),
          ),
        );

        // Assert
        expect(incompatibleResult.updateStatus.type, UpdateStatusType.notFound);
        expect(compatibleResult.updateStatus.type, UpdateStatusType.found);
        expect(compatibleResult.update!.version, Version.parse('1.9.0'));

        // Cleanup
        await configFile.delete();
      });

      test('должен обрабатывать инициализацию контроллера', () async {
        // Arrange
        const yamlConfig = '''
sources:
  - name: testStore
    platforms: [android]

releases:
  - version: "2.0.0"
    date: "2024-01-01T10:00:00"
    sources: [testStore]
''';

        PackageInfo.setMockInitialValues(
          appName: 'TestApp',
          packageName: 'com.example.app',
          version: '1.0.0',
          buildNumber: '10',
          buildSignature: '',
        );

        final configFile = await _createTempConfig(yamlConfig);
        final controller = UpdateController(
          fetchers: [UpdateConfigFetcher.byFile(configFile)],
        );

        // Act & Assert - Попытка использования до инициализации
        expect(
          () => controller.findUpdate(
            const UpdateSearchConfig(
              platform: UpdatePlatform.android,
              sources: [
                UpdateSource.custom(UpdateSourceName.custom('testStore')),
              ],
              displayTarget: UpdateViewTarget.dialog,
              locale: UpdateLocale.en,
            ),
          ),
          throwsA(isA<Exception>()),
        );

        // Act - Правильная инициализация
        await controller.init();
        await controller.fetch(const UpdateSearchConfig());

        final result = controller.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: const [
              UpdateSource.custom(UpdateSourceName.custom('testStore')),
            ],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
            currentDate: DateTime.parse('2024-01-15T10:00:00'),
          ),
        );

        // Assert
        expect(result.updateStatus.type, UpdateStatusType.found);
        expect(result.update!.version, Version.parse('2.0.0'));

        // Cleanup
        await configFile.delete();
      });
    });

    group('Display Target специфичные правила', () {
      test('должен применять разные правила для разных display targets',
          () async {
        // Arrange
        const yamlConfig = '''
sources:
  - name: testStore
    platforms: [android]

content:
  # Базовое правило
  - data:
      title: "Default Update"
      
  # Специфично для карточек
  - view_target_is: card
    data:
      title: "Card Update"
      show_icon: true
      
  # Специфично для диалогов
  - view_target_is: dialog
    data:
      title: "Dialog Update"  
      show_details: true
      
  # Специфично для полноэкранного режима
  - view_target_is: screen
    data:
      title: "Critical Update Required"
      full_screen_mode: true

settings:
  # Базовые настройки
  - data:
      should_show: true
      can_skip: true
      can_postpone: true
      
  # Для карточек - можно пропустить  
  - view_target_is: card
    data:
      can_skip: true
      can_postpone: true
      
  # Для диалогов - ограниченные возможности
  - view_target_is: dialog  
    data:
      can_skip: true
      can_postpone: false
      
  # Для полного экрана - никаких действий
  - view_target_is: screen
    data:
      can_skip: false
      can_postpone: false

releases:
  - version: "2.0.0"
    date: "2024-01-01T10:00:00"
    sources: [testStore]
''';

        PackageInfo.setMockInitialValues(
          appName: 'TestApp',
          packageName: 'com.example.app',
          version: '1.0.0',
          buildNumber: '10',
          buildSignature: '',
        );

        final configFile = await _createTempConfig(yamlConfig);
        final controller = UpdateController(
          fetchers: [UpdateConfigFetcher.byFile(configFile)],
        );

        await controller.init();
        await controller.fetch(const UpdateSearchConfig());

        // Act - Card target
        final cardResult = controller.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: const [
              UpdateSource.custom(UpdateSourceName.custom('testStore')),
            ],
            displayTarget: UpdateViewTarget.card,
            locale: UpdateLocale.en,
            currentDate: DateTime.parse('2024-01-15T10:00:00'),
          ),
        );

        // Act - Dialog target
        final dialogResult = controller.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: const [
              UpdateSource.custom(UpdateSourceName.custom('testStore')),
            ],
            displayTarget: UpdateViewTarget.dialog,
            locale: UpdateLocale.en,
            currentDate: DateTime.parse('2024-01-15T10:00:00'),
          ),
        );

        // Act - Screen target
        final screenResult = controller.findUpdate(
          UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: const [
              UpdateSource.custom(UpdateSourceName.custom('testStore')),
            ],
            displayTarget: UpdateViewTarget.screen,
            locale: UpdateLocale.en,
            currentDate: DateTime.parse('2024-01-15T10:00:00'),
          ),
        );

        // Assert - Card
        expect(cardResult.update!.content.title, 'Card Update');
        expect(cardResult.update!.content.customParams?['show_icon'], isTrue);
        expect(cardResult.update!.settings.canSkip, isTrue);
        expect(cardResult.update!.settings.canPostpone, isTrue);

        // Assert - Dialog
        expect(dialogResult.update!.content.title, 'Dialog Update');
        expect(
            dialogResult.update!.content.customParams?['show_details'], isTrue);
        expect(dialogResult.update!.settings.canSkip, isTrue);
        expect(dialogResult.update!.settings.canPostpone, isFalse);

        // Assert - Screen
        expect(screenResult.update!.content.title, 'Critical Update Required');
        expect(screenResult.update!.content.customParams?['full_screen_mode'],
            isTrue);
        expect(screenResult.update!.settings.canSkip, isFalse);
        expect(screenResult.update!.settings.canPostpone, isFalse);

        // Cleanup
        await configFile.delete();
      });
    });
  });
}

/// Создает временный файл с YAML конфигом
Future<File> _createTempConfig(String yamlContent) async {
  final tempDir = Directory.systemTemp;
  final tempFile = File(
      '${tempDir.path}/test_config_${DateTime.now().millisecondsSinceEpoch}.yaml');
  await tempFile.writeAsString(yamlContent);
  return tempFile;
}

/// Генерирует базовые content данные для избежания ошибок "required field"
String _getBaseContentData() => '''
      title: "Update Available"
      description: "Update available"
      update_url: "https://example.com/update"
      release_notes_title: "What's new?"
      skip_button: "Skip"
      postpone_button: "Later"  
      update_button: "Update"''';

/// Генерирует базовые settings данные
String _getBaseSettingsData() => '''
      should_show: true
      can_skip: true
      can_postpone: true''';
