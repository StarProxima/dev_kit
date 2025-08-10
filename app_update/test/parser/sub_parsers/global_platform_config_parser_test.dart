import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';
import 'package:app_update/src/parser/common.dart';
import 'package:app_update/src/parser/sub_parsers/global_platform_config_parser.dart';
import 'package:app_update/src/shared/models/global_platform/global_platform_config.dart';

void main() {
  group('GlobalPlatformConfigParser', () {
    const parser = GlobalPlatformConfigParser();

    test('Короткий синтаксис', () {
      const yamlStr = '''android''';
      final result = parser.parse(loadYaml(yamlStr));
      expect(result, isA<GlobalPlatformConfig>());
      expect(result?.platformName.name, 'android');
      expect(result?.contentRules, isNull);
      expect(result?.settingsRules, isNull);
      expect(result?.appSettingsRules, isNull);
      expect(result?.customData, isNull);
    });

    test('Полный набор полей (rules)', () {
      const yamlStr = '''
        name: ios
        content:
          title: Title
        settings:
          should_show: true
        app_settings:
          app_status: active
        custom_field: 42
      ''';
      final map = Map<String, dynamic>.from(loadYaml(yamlStr));
      final result = parser.parse(map);
      expect(result, isA<GlobalPlatformConfig>());
      expect(result?.platformName.name, 'ios');
      expect(result?.contentRules, isNotNull);
      expect(result?.settingsRules, isNotNull);
      expect(result?.appSettingsRules, isNotNull);
      expect(result?.customData, containsPair('custom_field', 42));
    });

    test('Ошибка при неверном типе', () {
      expect(() => parser.parse(123), throwsA(isA<UpdateConfigException>()));
      expect(() => parser.parse([]), throwsA(isA<UpdateConfigException>()));
    });

    test('null возвращает null', () {
      expect(parser.parse(null), isNull);
    });
  });
}
