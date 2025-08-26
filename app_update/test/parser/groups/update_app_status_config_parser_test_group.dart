part of '../parser_test.dart';

void runUpdateAppStatusConfigParserTests() {
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
      expect(() => parser.parse(123), throwsA(isA<UpdateConfigException>()));
      expect(() => parser.parse([]), throwsA(isA<UpdateConfigException>()));
    });

    test('null возвращает null', () {
      expect(parser.parse(null), isNull);
    });
  });
}
