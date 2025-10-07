import 'dart:io';

import 'package:app_update/app_update.dart';
import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/parser_test_helpers.dart';

void main() {
  group('UpdateConfigParser (интеграционный)', () {
    const parser = UpdateConfigParser();

    test('Парсинг большого конфига из api_v3.yaml', () async {
      final yamlStr =
          await File('test/parser/helpers/api_v3.yaml').readAsString();

      final map = parseYamlToMap(yamlStr);
      final result = parser.parse(map, isDebug: true);
      expect(result, isA<UpdateConfig>());

      // Проверка content_rules
      expect(
        result?.contentRules?.any((r) => r.data.title == 'Обновите приложение'),
        isTrue,
      );
      // Проверка settings_rules
      expect(
        result?.settingsRules?.any((r) => r.data.shouldShow == false),
        isTrue,
      );
      // Проверка sources
      expect(
        result?.sources?.any((s) => s.sourceName.name == 'appstore'),
        isTrue,
      );
      expect(
        result?.sources?.any((s) =>
            s.platforms?.any((p) => p.platformName.name == 'macos') ?? false),
        isTrue,
      );
      // Проверка releases
      expect(
        result?.releases.any((r) => r.version.toString() == '0.3.7'),
        isTrue,
      );
      expect(
        result?.releases.any((r) =>
            r.contentRules?.any((cr) => cr.data.releaseNotes != null) ?? false),
        isTrue,
      );
      expect(
        result?.releases.any((r) =>
            r.customParams?.containsKey('is_super_ultra_mega_release') ??
            false),
        isTrue,
      );
      // Проверка вложенных источников и платформ
      final githubSource = result?.sources
          ?.firstWhereOrNull((s) => s.sourceName.name == 'github');
      expect(githubSource?.platforms, isNotNull);
      expect(
        githubSource?.platforms?.any((p) => p.platformName.name == 'android'),
        isTrue,
      );
      // Проверка вложенного release в source
      final releaseWithNested = result?.releases
          .firstWhereOrNull((r) => r.version.toString() == '0.0.3+80');
      final googlePlaySource = releaseWithNested?.sources
          ?.firstWhereOrNull((s) => s.sourceName.name == 'googleplay');
      expect(googlePlaySource?.releaseOverride, isNotNull);
      // Проверка кастомных полей
      final megaRelease = result?.releases.firstWhereOrNull(
        (r) => r.customParams?['is_super_ultra_mega_release'] == true,
      );
      expect(megaRelease?.customParams?['is_super_ultra_mega_release'], isTrue);
      // Проверка appStatusRules
      expect(result?.appSettingsRules, isNotNull);
      expect(result?.appSettingsRules, isNotEmpty);
    });

    test('Ошибка при некорректном yaml', () {
      const yamlStr = '''
        releases: null
      ''';
      final map = parseYamlToMap(yamlStr);
      expect(
        () => parser.parse(map, isDebug: true),
        throwsA(isA<ParseConfigException>()),
      );
    });
  });
}
