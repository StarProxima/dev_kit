// ignore_for_file: prefer-correct-test-file-name, avoid-long-functions, prefer-moving-to-variable, no-equal-arguments, avoid-missing-enum-constant-in-map

import 'package:app_update/src/parser/models/update_config_exception.dart';
import 'package:app_update/src/parser/update_config_parser.dart';
import 'package:app_update/src/shared/update_alert_type.dart';
import 'package:app_update/src/shared/version_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UpdateSettingsContainerParser', () {
    const containerParser = UpdateSettingsContainerParser();
    const isDebug = true;

    test('parses single base settings', () {
      final value = {
        'can_skip_release': true,
      };

      final result = containerParser.parse(value, isDebug: isDebug);
      expect(
        result
            ?.getByBase(
              type: UpdateAlertTypeBase.base,
              status: VersionStatusBase.base,
            )
            ?.canSkipRelease,
        isTrue,
      );
    });
    test('parses nested settings with bases', () {
      final value1 = <String, dynamic>{
        'can_skip_release': true,
      };

      final value2 = <String, dynamic>{
        VersionStatusBase.base.key: {
          'can_skip_release': true,
        },
      };

      final value21 = <String, dynamic>{
        VersionStatusBase.base.key: {
          'can_skip_release': true,
        },
        VersionStatusBase.deprecated.key: {
          'can_skip_release': false,
        },
      };

      final value22 = <String, dynamic>{
        UpdateAlertTypeBase.base.key: {
          'can_skip_release': true,
        },
        UpdateAlertTypeBase.dialog.key: {
          'can_skip_release': false,
        },
      };

      final value3 = <String, dynamic>{
        UpdateAlertTypeBase.base.key: {
          VersionStatusBase.base.key: {
            'can_skip_release': true,
          },
        },
      };

      final result1 = containerParser.parse(value1, isDebug: isDebug);
      final result2 = containerParser.parse(value2, isDebug: isDebug);
      final result21 = containerParser.parse(value21, isDebug: isDebug);
      final result22 = containerParser.parse(value22, isDebug: isDebug);
      final result3 = containerParser.parse(value3, isDebug: isDebug);

      expect(
        result1
            ?.getByBase(
              type: UpdateAlertTypeBase.base,
              status: VersionStatusBase.base,
            )
            ?.canSkipRelease,
        isTrue,
      );

      expect(
        result2
            ?.getByBase(
              type: UpdateAlertTypeBase.base,
              status: VersionStatusBase.base,
            )
            ?.canSkipRelease,
        isTrue,
      );

      expect(
        result21
            ?.getByBase(
              type: UpdateAlertTypeBase.base,
              status: VersionStatusBase.deprecated,
            )
            ?.canSkipRelease,
        isFalse,
      );

      expect(
        result22
            ?.getByBase(
              type: UpdateAlertTypeBase.dialog,
              status: VersionStatusBase.base,
            )
            ?.canSkipRelease,
        isFalse,
      );

      expect(
        result3
            ?.getByBase(
              type: UpdateAlertTypeBase.base,
              status: VersionStatusBase.base,
            )
            ?.canSkipRelease,
        isTrue,
      );
    });

    // test('returns null when value is not Map and not in debug mode', () {
    //   const value = 'invalid_data';
    //   final result = containerParser.parse(value, isDebug: false);
    //   expect(result, isNull);
    // });

    test('parses settings with nested type and status-based fields', () {
      final value = <String, dynamic>{
        UpdateAlertTypeBase.dialog.key: {
          VersionStatusBase.base.key: {
            'can_skip_release': true,
          },
          VersionStatusBase.unsupported.key: {
            'can_skip_release': true,
          },
          VersionStatusBase.updatable.key: {
            'can_skip_release': true,
          },
        },
      };

      final result = containerParser.parse(value, isDebug: isDebug);
      expect(
        result?.getByBase(type: UpdateAlertTypeBase.dialog, status: VersionStatusBase.base)?.canSkipRelease,
        isTrue,
      );
      expect(
        result?.getByBase(type: UpdateAlertTypeBase.dialog, status: VersionStatusBase.unsupported)?.canSkipRelease,
        isTrue,
      );
      expect(
        result?.getByBase(type: UpdateAlertTypeBase.dialog, status: VersionStatusBase.updatable)?.canSkipRelease,
        isTrue,
      );
    });

    test(
      'parses settings with multiple statuses',
      () {
        final value = <String, dynamic>{
          VersionStatusBase.base.key: {
            'can_skip_release': true,
          },
          VersionStatusBase.unsupported.key: {
            'can_skip_release': false,
          },
          VersionStatusBase.updatable.key: {
            'can_postpone_release': true,
            'can_skip_release': false,
          },
        };

        final result = containerParser.parse(value, isDebug: isDebug);
        expect(
          result?.getByBase(type: UpdateAlertTypeBase.base, status: VersionStatusBase.base)?.canSkipRelease,
          isTrue,
        );
        expect(
          result?.getByBase(type: UpdateAlertTypeBase.base, status: VersionStatusBase.unsupported)?.canSkipRelease,
          isFalse,
        );
        expect(
          result?.getByBase(type: UpdateAlertTypeBase.base, status: VersionStatusBase.updatable)?.canSkipRelease,
          isFalse,
        );
        expect(
          result?.getByBase(type: UpdateAlertTypeBase.base, status: VersionStatusBase.updatable)?.canPostponeRelease,
          isTrue,
        );
      },
    );

    test('parses settings with various types and statuses', () {
      final value = <String, dynamic>{
        UpdateAlertTypeBase.base.key: {
          'can_skip_release': true,
        },
        UpdateAlertTypeBase.dialog.key: {
          VersionStatusBase.unsupported.key: {
            'can_skip_release': true,
          },
          VersionStatusBase.updatable.key: {
            'can_skip_release': true,
          },
        },
        UpdateAlertTypeBase.card.key: {
          'can_skip_release': true,
        },
      };

      final result = containerParser.parse(value, isDebug: isDebug);
      expect(
        result?.getByBase(type: UpdateAlertTypeBase.base, status: VersionStatusBase.base)?.canSkipRelease,
        isTrue,
      );
      expect(
        result?.getByBase(type: UpdateAlertTypeBase.dialog, status: VersionStatusBase.unsupported)?.canSkipRelease,
        isTrue,
      );
      expect(
        result?.getByBase(type: UpdateAlertTypeBase.dialog, status: VersionStatusBase.updatable)?.canSkipRelease,
        isTrue,
      );
      expect(
        result?.getByBase(type: UpdateAlertTypeBase.card, status: VersionStatusBase.base)?.canSkipRelease,
        isTrue,
      );
    });

    test(
      'throws exception when value is not Map and debug mode is enabled',
      () {
        const value = 'invalid_data';

        expect(
          () => containerParser.parse(value, isDebug: isDebug),
          throwsA(isA<UpdateConfigException>()),
        );
      },
    );

    test('returns null for empty map input', () {
      final result = containerParser.parse(<String, dynamic>{}, isDebug: isDebug);
      expect(result, isNull);
    });

    test('parses structure with missing optional fields correctly', () {
      final value = <String, dynamic>{
        UpdateAlertTypeBase.dialog.key: {
          VersionStatusBase.unsupported.key: {
            'can_postpone_release': true,
          },
        },
        UpdateAlertTypeBase.card.key: {
          'release_delay_hours': 32,
          'can_skip_release': false,
        },
      };

      final result = containerParser.parse(value, isDebug: isDebug);

      expect(
        result?.getByBase(type: UpdateAlertTypeBase.dialog, status: VersionStatusBase.unsupported)?.canPostponeRelease,
        isTrue,
      );
      expect(
        result?.getByBase(type: UpdateAlertTypeBase.card, status: VersionStatusBase.base)?.canSkipRelease,
        isFalse,
      );
      expect(
        result?.getByBase(type: UpdateAlertTypeBase.card, status: VersionStatusBase.base)?.releaseDelay,
        const Duration(hours: 32),
      );
    });
  });
}
