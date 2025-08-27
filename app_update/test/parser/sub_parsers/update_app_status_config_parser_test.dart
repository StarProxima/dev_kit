import 'package:app_update/app_update.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

void main() {
  group('UpdateAppStatusConfigParser', () {
    const parser = UpdateAppSettingsConfigParser();

    test('Базовый кейс', () {
      const yamlStr = '''
        app_status: outdated
        custom_field: 42
      ''';
      final map = Map<String, dynamic>.from(loadYaml(yamlStr));
      final result = parser.parse(map);
      expect(result, isA<UpdateAppSettingsConfig>());
      expect(result?.appStatus?.name, 'outdated');
      expect(result?.customData, containsPair('custom_field', 42));
    });

    test('Ошибка при неверном типе', () {
      expect(() => parser.parse(123), throwsA(isA<ParseConfigException>()));
      expect(() => parser.parse([]), throwsA(isA<ParseConfigException>()));
    });

    test('null возвращает null', () {
      expect(parser.parse(null), isNull);
    });
  });
}
