import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_update/app_update.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';
import 'package:app_update/app_update.dart';

void main() {
  group('UpdateSettingsConfigParser', () {
    const parser = UpdateSettingsConfigParser();

    test('Полный набор полей', () {
      const yamlStr = '''
        should_show: true
        can_skip: false
        can_postpone: true
        skip_release_delay_hours: 10
        skip_all_releases_delay_hours: 20
        postpone_release_delay_hours: 30
        postpone_all_releases_delay_hours: 40
        custom_field: 42
      ''';
      final map = Map<String, dynamic>.from(loadYaml(yamlStr));
      final result = parser.parse(map);
      expect(result, isA<UpdateSettingsConfig>());
      expect(result?.shouldShow, true);
      expect(result?.canSkip, false);
      expect(result?.canPostpone, true);
      expect(result?.skipReleaseDelay?.inHours, 10);
      expect(result?.skipAllReleasesDelay?.inHours, 20);
      expect(result?.postponeReleaseDelay?.inHours, 30);
      expect(result?.postponeAllReleasesDelay?.inHours, 40);
      expect(result?.customData, containsPair('custom_field', 42));
    });

    test('Частичный набор полей', () {
      const yamlStr = '''
        should_show: false
      ''';
      final map = Map<String, dynamic>.from(loadYaml(yamlStr));
      final result = parser.parse(map);
      expect(result?.shouldShow, false);
      expect(result?.canSkip, isNull);
      expect(result?.canPostpone, isNull);
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
