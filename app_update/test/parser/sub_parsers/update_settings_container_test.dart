// ignore_for_file: prefer-correct-test-file-name, avoid-long-functions, prefer-moving-to-variable, prefer-test-matchers

import 'dart:ui';

import 'package:app_update/src/parser/models/update_config_exception.dart';
import 'package:app_update/src/parser/update_config_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UpdateSettingsContainerParser', () {
    const containerParser = UpdateSettingsContainerParser();
    const isDebug = true;

    test('parses settings_0 with single base settings', () {
      final value = {
        'title': 'title',
        'description': 'description',
        'can_skip_release': true,
      };

      final result = containerParser.parse(value, isDebug: isDebug);
      expect(
        result?.getByRaw(type: 'base', status: 'base')?.canSkipRelease,
        isTrue,
      );
    });

    test('parses settings_1 with nested dialog and status-based settings', () {
      final value = {
        'dialog': {
          'base': {
            'title': 'title',
            'description': 'description',
            'can_skip_release': true,
          },
          'unsupported': {
            'title': 'title',
            'description': 'description',
            'can_skip_release': true,
          },
          'updatable': {
            'title': 'title',
            'description': 'description',
            'can_skip_release': true,
          },
        },
      };

      final result = containerParser.parse(value, isDebug: isDebug);
      expect(
        result?.getByRaw(type: 'dialog', status: 'base')?.canSkipRelease,
        isTrue,
      );
      expect(
        result?.getByRaw(type: 'dialog', status: 'unsupported')?.canSkipRelease,
        isTrue,
      );
      expect(
        result?.getByRaw(type: 'dialog', status: 'updatable')?.canSkipRelease,
        isTrue,
      );
    });

    test(
      'parses settings_2 with different types (base, unsupported, updatable)',
      () {
        final value = {
          'base': {
            'title': 'title',
            'description': 'description',
            'can_skip_release': true,
          },
          'unsupported': {
            'title': 'title',
            'description': 'description',
            'can_skip_release': true,
          },
          'updatable': {
            'title': 'title',
            'description': 'description',
            'can_skip_release': true,
          },
        };

        final result = containerParser.parse(value, isDebug: isDebug);
        expect(
          result?.getByRaw(type: 'base', status: 'base')?.canSkipRelease,
          isTrue,
        );
        expect(
          result?.getByRaw(type: 'unsupported', status: 'base')?.canSkipRelease,
          isTrue,
        );
        expect(
          result?.getByRaw(type: 'updatable', status: 'base')?.canSkipRelease,
          isTrue,
        );
      },
    );

    test('parses settings_3 with various types and statuses', () {
      final value = {
        'base': {
          'can_skip_release': true,
        },
        'dialog': {
          'unsupported': {
            'title': 'title',
            'description': 'description',
            'can_skip_release': true,
          },
          'updatable': {
            'title': 'title',
            'description': 'description',
            'can_skip_release': true,
          },
        },
        'card': {
          'title': 'title',
          'description': 'description',
          'can_skip_release': true,
        },
      };

      final result = containerParser.parse(value, isDebug: isDebug);
      expect(
        result?.getByRaw(type: 'base', status: 'base')?.canSkipRelease,
        isTrue,
      );
      expect(
        result?.getByRaw(type: 'dialog', status: 'unsupported')?.canSkipRelease,
        isTrue,
      );
      expect(
        result?.getByRaw(type: 'dialog', status: 'updatable')?.canSkipRelease,
        isTrue,
      );
      expect(
        result?.getByRaw(type: 'card', status: 'base')?.canSkipRelease,
        isTrue,
      );
    });

    test(
      'throws UpdateConfigException when value is not Map and in debug mode',
      () {
        const value = 'invalid_data';

        expect(
          () => containerParser.parse(value, isDebug: isDebug),
          throwsA(isA<UpdateConfigException>()),
        );
      },
    );

    // test('returns null when value is not Map and not in debug mode', () {
    //   const value = 'invalid_data';
    //   final result = containerParser.parse(value, isDebug: false);
    //   expect(result, isNull);
    // });

    test('returns null for empty map input', () {
      final result = containerParser.parse(<String, dynamic>{}, isDebug: isDebug);
      expect(result, isNull);
    });

    test('parses complex structure with missing optional fields', () {
      final value = {
        'dialog': {
          'unsupported': {
            'title': 'title',
            'description': 'description',
          },
        },
        'card': {
          'description': 'only description',
          'can_skip_release': false,
        },
      };

      final result = containerParser.parse(value, isDebug: isDebug);

      expect(
        result?.getByRaw(type: 'dialog', status: 'unsupported')?.translations?.title?.byLocale(const Locale('en')),
        'title',
      );
      expect(
        result?.getByRaw(type: 'card', status: 'base')?.canSkipRelease,
        isFalse,
      );
      expect(
        result?.getByRaw(type: 'card', status: 'base')?.translations?.description?.byLocale(const Locale('en')),
        'only description',
      );
    });
  });
}
