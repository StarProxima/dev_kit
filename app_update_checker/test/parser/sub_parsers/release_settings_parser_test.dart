// ignore_for_file: avoid-long-functions, prefer-test-matchers,  avoid-non-null-assertion

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:update_check/src/parser/models/update_config_exception.dart';
import 'package:update_check/src/parser/update_config_parser.dart';
import 'package:update_check/src/shared/text_translations.dart';

void main() {
  group('ReleaseSettingsParser', () {
    const parser = ReleaseSettingsParser();
    const isDebug = true;

    test('should parse full release settings configuration', () {
      final map = {
        'title': {
          'en': r'Update available for $appName!',
          'es': r'¡Actualización disponible para $appName!',
        },
        'description': r'Version $releaseVersion is available now!',
        'can_ignore_release': true,
        'reminder_period_hours': 48,
        'release_delay_hours': 24,
        'deprecated_before_version': '0.3.7',
        'required_minimum_version': '0.1.0',
        'custom_field': 'custom_value', // Custom data
      };

      final result = parser.parse(map, isDebug: isDebug);

      expect(result.titleTranslations, isNotNull);
      expect(result.titleTranslations!.byLocale(const Locale('en')), r'Update available for $appName!');
      expect(result.titleTranslations!.byLocale(const Locale('es')), r'¡Actualización disponible para $appName!');
      expect(
        result.descriptionTranslations!.byLocale(const Locale('en')),
        r'Version $releaseVersion is available now!',
      );
      expect(result.canSkipRelease, true);
      expect(result.reminderPeriod, const Duration(hours: 48));
      expect(result.releaseDelay, const Duration(hours: 24));
      expect(result.deprecatedBeforeVersion, Version.parse('0.3.7'));
      expect(result.requiredMinimumVersion, Version.parse('0.1.0'));
      expect(result.customData, {'custom_field': 'custom_value'});
    });

    test('should handle missing optional fields', () {
      final map = {
        // Missing some fields
        'title': {
          'en': 'Update available!',
        },
      };

      final result = parser.parse(map, isDebug: isDebug);

      // expect(result, isNotNull);
      expect(result.titleTranslations, isNotNull);
      expect(result.titleTranslations!.byLocale(const Locale('en')), 'Update available!');
      expect(result.descriptionTranslations, isNull);
      expect(result.canSkipRelease, isNull);
      expect(result.reminderPeriod, isNull);
      expect(result.releaseDelay, isNull);
      expect(result.deprecatedBeforeVersion, isNull);
      expect(result.requiredMinimumVersion, isNull);
      expect(result.customData, map..remove('title'));
    });

    test('should handle invalid types for canIgnoreRelease', () {
      final map = {
        'can_ignore_release': 'not_a_bool', // Некорректный тип
      };

      expect(() => parser.parse(map, isDebug: isDebug), throwsA(isA<UpdateConfigException>()));
    });

    test('should handle invalid duration values', () {
      final map = {
        'reminder_period_hours': 'not_a_number', // Некорректный тип
        'release_delay_hours': 'not_a_number', // Некорректный тип
      };

      final result = parser.parse(map, isDebug: false);

      expect(result.reminderPeriod, isNull);
      expect(result.releaseDelay, isNull);
    });

    test('should handle invalid version format', () {
      final map = {
        'deprecated_before_version': 'invalid_version_format',
        'required_minimum_version': 'another_invalid_version_format',
      };

      expect(() => parser.parse(map, isDebug: isDebug), throwsA(isA<UpdateConfigException>()));
    });

    test('should handle missing custom data', () {
      final map = {
        'title': {
          'en': 'Update available!',
        },
        // Custom data is missing
      };

      final result = parser.parse(map, isDebug: isDebug);

      expect(result.customData, isEmpty);
    });
  });
}
