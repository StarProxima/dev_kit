import 'package:app_update/src/parser/common.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';
import 'package:app_update/src/parser/sub_parsers/release_platrform_config_parser.dart';
import 'package:app_update/src/shared/models/release_platrform/release_platrform_config.dart';

void main() {
  group('ReleasePlatformConfigParser', () {
    const parser = ReleasePlatformConfigParser();

    test('Короткий синтаксис', () {
      const yamlStr = '''android''';
      final result = parser.parse(loadYaml(yamlStr));
      expect(result, isA<ReleasePlatformConfig>());
      expect(result?.platform.name, 'android');
      expect(result?.sourceOverride, isNull);
      expect(result?.customData, isNull);
    });

    test('Полный набор полей', () {
      const yamlStr = '''
        name: ios
        source:
          name: github
        custom_field: 42
      ''';
      final map = Map<String, dynamic>.from(loadYaml(yamlStr));
      final result = parser.parse(map);
      expect(result, isA<ReleasePlatformConfig>());
      expect(result?.platform.name, 'ios');
      expect(result?.sourceOverride?.source?.name, 'github'.toLowerCase());
      expect(result?.customData, containsPair('custom_field', 42));
    });

    test('Ошибка при невалидном имени', () {
      const yamlStr = '''unknown_platform''';
      final result = parser.parse(loadYaml(yamlStr));
      expect(result, isA<ReleasePlatformConfig>());
      expect(result?.platform.name, 'unknown_platform');
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
