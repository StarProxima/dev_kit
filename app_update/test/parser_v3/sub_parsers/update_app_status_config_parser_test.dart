import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';
import 'package:app_update/src/parser/common.dart';
import 'package:app_update/src/parser/sub_parsers/update_app_status_config_parser.dart';
import 'package:app_update/src/shared/models/update_app_status/update_app_status_config.dart';

void main() {
  group('UpdateAppStatusConfigParser', () {
    const parser = UpdateAppStatusConfigParser();

    test('Базовый кейс', () {
      const yamlStr = '''
        app_status: outdated
        custom_field: 42
      ''';
      final map = Map<String, dynamic>.from(loadYaml(yamlStr));
      final result = parser.parse(map);
      expect(result, isA<UpdateAppStatusConfig>());
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
