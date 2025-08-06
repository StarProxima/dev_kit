import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';
import 'package:app_update/src/parser/sub_parsers/global_platform_config/global_platform_config_parser.dart';
import 'package:app_update/src/parser/sub_parsers/global_platform_config/global_platform_config.dart';
import 'package:app_update/src/parser/update_config_exception.dart';

void main() {
  group('GlobalPlatformConfigParser', () {
    const parser = GlobalPlatformConfigParser();

    test('Короткий синтаксис', () {
      const yamlStr = '''android''';
      final result = parser.parse(loadYaml(yamlStr));
      expect(result, isA<GlobalPlatformConfig>());
      expect(result?.name.name, 'android');
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
      expect(result, isA<GlobalPlatformConfig>());
      expect(result?.name.name, 'ios');
      expect(result?.sourceOverride?.name, 'github');
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
