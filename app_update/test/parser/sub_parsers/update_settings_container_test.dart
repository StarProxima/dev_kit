// ignore_for_file: prefer-correct-test-file-name, avoid-long-functions, prefer-moving-to-variable, prefer-test-matchers, avoid-similar-names, no-equal-arguments

import 'dart:ui';

import 'package:app_update/src/parser/models/update_config_exception.dart';
import 'package:app_update/src/parser/update_config_parser.dart';
import 'package:app_update/src/shared/app_version_status.dart';
import 'package:app_update/src/shared/text_translations.dart';
import 'package:app_update/src/shared/update_alert_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UpdateSettingsContainerParser', () {
    const containerParser = UpdateSettingsContainerParser();
    const isDebug = true;

    const base = 'base';
    final unsupported = VersionStatus.unsupported.name;
    final deprecated = VersionStatus.deprecated.name;
    final updatable = VersionStatus.updatable.name;
    final dialog = UpdateAlertType.dialog.name;
    final card = UpdateAlertType.card.name;

    test('parses single base settings', () {
      final value = {
        'title': 'title',
        'description': 'description',
        'can_skip_release': true,
      };

      final result = containerParser.parse(value, isDebug: isDebug);
      expect(
        result?.getByRaw(type: base, status: base)?.canSkipRelease,
        isTrue,
      );
    });
    test('parses nested settings with bases', () {
      final value1 = {
        'can_skip_release': true,
      };

      final value2 = {
        base: {
          'can_skip_release': true,
        },
      };

      final value21 = {
        base: {
          'can_skip_release': true,
        },
        deprecated: {
          'can_skip_release': false,
        },
      };

      final value22 = {
        base: {
          'can_skip_release': true,
        },
        dialog: {
          'can_skip_release': false,
        },
      };

      final value3 = {
        base: {
          base: {
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
        result1?.getByRaw(type: base, status: base)?.canSkipRelease,
        isTrue,
      );

      expect(
        result2?.getByRaw(type: base, status: base)?.canSkipRelease,
        isTrue,
      );

      expect(
        result21?.getByRaw(type: base, status: deprecated)?.canSkipRelease,
        isFalse,
      );

      expect(
        result22?.getByRaw(type: dialog, status: base)?.canSkipRelease,
        isFalse,
      );

      expect(
        result3?.getByRaw(type: base, status: base)?.canSkipRelease,
        isTrue,
      );
    });

    // test('returns null when value is not Map and not in debug mode', () {
    //   const value = 'invalid_data';
    //   final result = containerParser.parse(value, isDebug: false);
    //   expect(result, isNull);
    // });

    test('parses settings with nested type and status-based fields', () {
      final value = {
        dialog: {
          base: {
            'title': 'title',
            'description': 'description',
            'can_skip_release': true,
          },
          unsupported: {
            'title': 'title',
            'description': 'description',
            'can_skip_release': true,
          },
          updatable: {
            'title': 'title',
            'description': 'description',
            'can_skip_release': true,
          },
        },
      };

      final result = containerParser.parse(value, isDebug: isDebug);
      expect(
        result?.getByRaw(type: dialog, status: base)?.canSkipRelease,
        isTrue,
      );
      expect(
        result?.getByRaw(type: dialog, status: unsupported)?.canSkipRelease,
        isTrue,
      );
      expect(
        result?.getByRaw(type: dialog, status: updatable)?.canSkipRelease,
        isTrue,
      );
    });

    test(
      'parses settings with multiple statuses',
      () {
        final value = {
          base: {
            'title': 'title',
            'description': 'description',
            'can_skip_release': true,
          },
          unsupported: {
            'title': 'title',
            'can_skip_release': false,
          },
          updatable: {
            'title': 'updatable title',
            'can_skip_release': false,
          },
        };

        final result = containerParser.parse(value, isDebug: isDebug);
        expect(
          result?.getByRaw(type: base, status: base)?.canSkipRelease,
          isTrue,
        );
        expect(
          result?.getByRaw(type: base, status: unsupported)?.canSkipRelease,
          isFalse,
        );
        expect(
          result?.getByRaw(type: base, status: updatable)?.canSkipRelease,
          isFalse,
        );
        expect(
          result?.getByRaw(type: base, status: updatable)?.translations?.title?.byLocale(kAppUpdateDefaultLocale),
          'updatable title',
        );
      },
    );

    test('parses settings with various types and statuses', () {
      final value = {
        base: {
          'can_skip_release': true,
        },
        dialog: {
          unsupported: {
            'title': 'title',
            'description': 'description',
            'can_skip_release': true,
          },
          updatable: {
            'title': 'title',
            'description': 'description',
            'can_skip_release': true,
          },
        },
        card: {
          'title': 'title',
          'description': 'description',
          'can_skip_release': true,
        },
      };

      final result = containerParser.parse(value, isDebug: isDebug);
      expect(
        result?.getByRaw(type: base, status: base)?.canSkipRelease,
        isTrue,
      );
      expect(
        result?.getByRaw(type: dialog, status: unsupported)?.canSkipRelease,
        isTrue,
      );
      expect(
        result?.getByRaw(type: dialog, status: updatable)?.canSkipRelease,
        isTrue,
      );
      expect(
        result?.getByRaw(type: card, status: base)?.canSkipRelease,
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
      final value = {
        dialog: {
          unsupported: {
            'title': 'title',
            'description': 'description',
          },
        },
        card: {
          'description': 'only description',
          'can_skip_release': false,
        },
      };

      final result = containerParser.parse(value, isDebug: isDebug);

      expect(
        result?.getByRaw(type: dialog, status: unsupported)?.translations?.title?.byLocale(const Locale('en')),
        'title',
      );
      expect(
        result?.getByRaw(type: card, status: base)?.canSkipRelease,
        isFalse,
      );
      expect(
        result?.getByRaw(type: card, status: base)?.translations?.description?.byLocale(const Locale('en')),
        'only description',
      );
    });
  });
}
