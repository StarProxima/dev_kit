// ignore_for_file: avoid-long-functions, prefer-test-matchers

import 'dart:ui';

import 'package:app_update/src/parser/models/update_config_exception.dart';
import 'package:app_update/src/parser/update_config_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UpdateSettingsParser', () {
    const updateSettingsParser = UpdateSettingsParser();
    const isDebug = true;

    test('parses valid update settings data correctly', () {
      final value = {
        'title': {
          'en': r'Version $releaseVersion is available!',
          'es': r'¡Versión $releaseVersion disponible!',
          'ru': r'Доступна версия $releaseVersion!',
        },
        'description': r'A new version of $appName is available!',
        'update_button_text': 'Go to Store',
        'reminder_period_hours': 96,
        'progressive_rollout_hours': 96,
        'release_delay_hours': 20,
        'can_skip_release': true,
        'can_postpone_release': false,
      };

      final result = updateSettingsParser.parse(value, isDebug: isDebug);

      expect(result?.canSkipRelease, isTrue);
      expect(result?.canPostponeRelease, isFalse);
      expect(result?.reminderPeriod, const Duration(hours: 96));
      expect(result?.releaseDelay, const Duration(hours: 20));
      expect(result?.progressiveRolloutDuration, const Duration(hours: 96));
      expect(
        result?.translations?.title?.byLocale(const Locale('en')),
        r'Version $releaseVersion is available!',
      );
    });

    test(
      'throws UpdateConfigException when value is not a Map and in debug mode',
      () {
        const value = 123;
        expect(
          () => updateSettingsParser.parse(value, isDebug: isDebug),
          throwsA(isA<UpdateConfigException>()),
        );
      },
    );

    // test('returns null when value is not a Map and not in debug mode', () {
    //   const value = 123;
    //   final result = updateSettingsParser.parse(value, isDebug: false);
    //   expect(result, isNull);
    // });

    test('returns null when value is null', () {
      final result = updateSettingsParser.parse(null, isDebug: isDebug);
      expect(result, isNull);
    });

    // test('handles empty map correctly by returning null', () {
    //   final value = <String, dynamic>{};
    //   final result = updateSettingsParser.parse(value, isDebug: isDebug);
    //   expect(result, isNull);
    // });
  });

  group('SettingsTranslationsParser', () {
    const translationsParser = SettingsTranslationsParser();
    const isDebug = true;

    test('parses valid translations data correctly', () {
      final value = {
        'title': {
          'en': 'New version available!',
          'es': '¡Nueva versión disponible!',
          'ru': 'Доступна новая версия!',
        },
        'description': 'A new version is available!',
        'update_button_text': 'Update now',
        'skip_button_text': 'Skip',
        'later_button_text': 'Later',
      };

      final result = translationsParser.parse(value, isDebug: isDebug);

      expect(
        result?.title?.byLocale(const Locale('en')),
        'New version available!',
      );
      expect(
        result?.description?.byLocale(const Locale('en')),
        'A new version is available!',
      );
      expect(
        result?.updateButtonText?.byLocale(const Locale('en')),
        'Update now',
      );
      expect(result?.skipButtonText?.byLocale(const Locale('en')), 'Skip');
      expect(result?.laterButtonText?.byLocale(const Locale('en')), 'Later');
    });

    test(
      'throws UpdateConfigException when value is not a Map and in debug mode',
      () {
        const value = 'incorrect_value';
        expect(
          () => translationsParser.parse(value, isDebug: isDebug),
          throwsA(isA<UpdateConfigException>()),
        );
      },
    );

    // test('returns null when value is not a Map and not in debug mode', () {
    //   const value = 'incorrect_value';
    //   final result = translationsParser.parse(value, isDebug: false);
    //   expect(result, isNull);
    // });

    test('returns null when value is null', () {
      final result = translationsParser.parse(null, isDebug: isDebug);
      expect(result, isNull);
    });

    // test('returns null for empty map', () {
    //   final value = <String, dynamic>{};
    //   final result = translationsParser.parse(value, isDebug: isDebug);
    //   expect(result, isNull);
    // });
  });
}
