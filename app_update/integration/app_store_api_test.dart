// ignore_for_file: avoid_print

import 'dart:ui';

import 'package:app_update/src/fetcher/data/app_store_api.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils/test_apps.dart';
import 'utils/test_locales.dart';

/// Интеграционные тесты Source Fetchers
/// ⚠️ НЕ запускать в CI/CD - делает реальные HTTP запросы!
void main() {
  group('Source Fetchers Integration Tests', () {
    test('Google Play URL generation', () {
      print('\n📱 Google Play:');
      _testGooglePlay();
    });

    test('RuStore URL generation', () {
      print('\n🏪 RuStore:');
      _testRuStore();
    });

    test('App Store API', () async {
      print('\n🍎 App Store:');
      await _testAppStore();
    });

    test('App Store fallback logic', () async {
      print('\n🔄 Fallback Test:');
      await _testAppStoreFallback();
    });
  });
}

void _testGooglePlay() {
  for (final app in [TestApps.multiStoreApp, TestApps.onlyKoreanApp, TestApps.nonRuApp]) {
    for (final locale in [TestLocales.english, TestLocales.korean]) {
      final parameters = <String, String>{'id': app.getPackageId(TargetPlatform.android)};

      if (locale.countryCode != null) {
        parameters['gl'] = locale.countryCode!;
      }
      if (locale.languageCode.isNotEmpty) {
        parameters['hl'] = locale.languageCode;
      }

      final url = Uri.https('play.google.com', 'store/apps/details', parameters);
      print('  ✅ ${app.name} ${TestLocales.describe(locale)}: URL generated');
      print('    🔗 $url');
    }
  }
}

void _testRuStore() {
  for (final app in [TestApps.multiStoreApp, TestApps.onlyKoreanApp, TestApps.nonRuApp]) {
    final url = Uri.https('apps.rustore.ru', 'app/${app.getPackageId(TargetPlatform.android)}');
    print('  ✅ ${app.name}: URL generated');
    print('    🔗 $url');
  }
}

Future<void> _testAppStore() async {
  const api = AppStoreApi();

  // Мультиплатформенное приложение
  for (final locale in [TestLocales.english, TestLocales.korean, TestLocales.russian]) {
    await _testAppStoreApp(api, TestApps.multiStoreApp, locale);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Корейское приложение
  for (final locale in [TestLocales.korean, TestLocales.english]) {
    await _testAppStoreApp(api, TestApps.onlyKoreanApp, locale);
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  // Приложение не доступное в России
  for (final locale in [TestLocales.english, TestLocales.russian]) {
    await _testAppStoreApp(api, TestApps.nonRuApp, locale);
    await Future.delayed(const Duration(milliseconds: 1000));
  }
}

Future<void> _testAppStoreApp(AppStoreApi api, TestAppData app, Locale locale) async {
  final stopwatch = Stopwatch()..start();

  try {
    final appData = await api.lookupApp(app.getPackageId(TargetPlatform.ios), locale);

    stopwatch.stop();

    if (appData != null) {
      final url = api.buildAppStoreUrl(appData, locale);
      print(
          '  ✅ ${app.name} ${TestLocales.describe(locale)}: App found (${stopwatch.elapsedMilliseconds}ms)');
      if (url != null) {
        print('    🔗 $url');
      }
    } else {
      print(
          '  ❌ ${app.name} ${TestLocales.describe(locale)}: Not found (${stopwatch.elapsedMilliseconds}ms)');
    }
  } catch (e) {
    stopwatch.stop();
    print(
        '  💥 ${app.name} ${TestLocales.describe(locale)}: Error (${stopwatch.elapsedMilliseconds}ms) - $e');
  }
}

Future<void> _testAppStoreFallback() async {
  const api = AppStoreApi();

  // Тест на приложение, которое не доступно в России
  final nonRuAppId = TestApps.nonRuApp.getPackageId(TargetPlatform.ios);

  print('\n  📦 ${TestApps.nonRuApp.name} (не доступно в России):');

  // Тест 1
  await _testFallbackCase(api, nonRuAppId, TestLocales.russian, 'ru-RU (не должен найти)');
  await Future.delayed(const Duration(milliseconds: 1000));

  // Тест 2
  await _testFallbackCase(api, nonRuAppId, TestLocales.russianOnly, 'ru (fallback, должен найти)');
  await Future.delayed(const Duration(milliseconds: 1000));

  // Тест 3
  await _testFallbackCase(api, nonRuAppId, TestLocales.english, 'en-US (должен найти)');
  await Future.delayed(const Duration(milliseconds: 1000));

  // Проверка на корейском приложении
  final onlyKoreanAppId = TestApps.onlyKoreanApp.getPackageId(TargetPlatform.ios);

  print('\n  📦 ${TestApps.onlyKoreanApp.name} (только в Корее):');

  // Тест 4
  await _testFallbackCase(api, onlyKoreanAppId, TestLocales.korean, 'ko-KR (должен найти)');
  await Future.delayed(const Duration(milliseconds: 1000));

  // Тест 5
  await _testFallbackCase(
      api, onlyKoreanAppId, TestLocales.koreanOnly, 'ko (fallback, не должен найти)');
  await Future.delayed(const Duration(milliseconds: 1000));

  // Тест 6
  await _testFallbackCase(api, onlyKoreanAppId, TestLocales.english, 'en-US (не должен найти)');

  // Тест 7
  await _testFallbackCase(
      api, onlyKoreanAppId, TestLocales.englishOnly, 'en (fallback, не должен найти)');
  await Future.delayed(const Duration(milliseconds: 1000));
}

Future<void> _testFallbackCase(
  AppStoreApi api,
  String bundleId,
  Locale locale,
  String description,
) async {
  final stopwatch = Stopwatch()..start();

  try {
    final appData = await api.lookupApp(bundleId, locale, shouldUseFallback: false);

    stopwatch.stop();

    if (appData != null) {
      final url = api.buildAppStoreUrl(appData, locale);
      print('  ✅ $description: App found (${stopwatch.elapsedMilliseconds}ms)');
      if (url != null) {
        print('    🔗 $url');
      }
    } else {
      print('  ❌ $description: Not found (${stopwatch.elapsedMilliseconds}ms)');
    }
  } catch (e) {
    stopwatch.stop();
    print('  💥 $description: Error (${stopwatch.elapsedMilliseconds}ms) - $e');
  }
}
