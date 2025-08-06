// ignore_for_file: avoid-long-functions

import 'package:app_update/src/parser/update_config_exception.dart';
import 'package:app_update/src/parser/update_config_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UpdateSettingsParser', () {
    const updateSettingsParser = UpdateSettingsParser();
    const isDebug = true;

    test('parses valid update settings data correctly', () {
      final value = {
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
}
