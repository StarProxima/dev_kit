import 'package:app_update/app_update.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/parser_test_helpers.dart';

void main() {
  group('UpdateAppStatusConfigParser', () {
    const parser = UpdateAppSettingsConfigParser();

    test('Базовый кейс', () {
      const yamlStr = '''
        app_status: outdated
        custom_params:
          custom_field: 42
      ''';
      final map = parseYamlToMap(yamlStr);
      final result = parser.parse(map, isDebug: true);
      expect(result, isA<UpdateAppSettingsConfig>());
      expect(result?.appStatus?.name, 'outdated');
      expect(result?.customParams, containsPair('custom_field', 42));
    });

    test('Ошибка при неверном типе', () {
      expect(
        () => parser.parse(123, isDebug: true),
        throwsA(isA<ParseConfigException>()),
      );
      expect(
        () => parser.parse([], isDebug: true),
        throwsA(isA<ParseConfigException>()),
      );
    });

    test('null возвращает null', () {
      expect(parser.parse(null, isDebug: true), isNull);
    });
  });
}
