// ignore_for_file: avoid-long-functions
import 'package:app_update/src/parser/update_config_exception.dart';
import 'package:app_update/src/parser/update_config_parser.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';

void main() {
  group('ReleaseParser', () {
    const parser = ReleaseParser();
    const isDebug = true;
    const isOverride = false;

    test('parses release with version, date, and sources in local timezone', () {
      final value = {
        'version': '0.3.7',
        'date': '2024-08-24 15:35:00',
        'settings': {
          'release_notes': 'Big update!',
          'can_skip_release': true,
          'reminder_period_hours': 48,
          'release_delay_hours': 48,
        },
        'sources': [],
      };

      final result = parser.parse(value, isDebug: isDebug, isOverride: isOverride);

      expect(result?.version, Version.parse('0.3.7'));
      expect(result?.date, DateTime(2024, 8, 24, 15, 35));
      expect(result?.settings, isNotNull);
      expect(result?.sources, isEmpty);
    });

    test('parses release with date in UTC format', () {
      final value = {
        'version': '1.0.0',
        'date': '2024-08-24T15:35:00Z',
        'sources': [],
      };

      final result = parser.parse(value, isDebug: isDebug, isOverride: isOverride);

      expect(result?.version, Version.parse('1.0.0'));
      expect(result?.date?.isUtc, true);
      expect(result?.date, DateTime.utc(2024, 8, 24, 15, 35));
      expect(result?.sources, isEmpty);
    });

    test('parses release with version and sources in semantic format with build metadata', () {
      final value = {
        'version': '0.3.8+10-beta',
        'settings': {
          'release_notes': 'Minor Improvements',
        },
        'sources': [
          {'name': 'googlePlay'},
          {'name': 'appStore'},
        ],
      };

      final result = parser.parse(value, isDebug: isDebug, isOverride: isOverride);

      expect(result?.version, Version.parse('0.3.8+10-beta'));
      expect(result?.settings, isNotNull);
      expect(result?.sources?.length, 2);
    });

    test('parses release with version, date, custom settings, and sources', () {
      final value = {
        'version': '0.2.4',
        'date': '2014-10-17 23:00:00',
        'settings': {
          'title': 'Title',
          'description': 'Description',
          'release_notes': 'Note',
          'can_skip_release': true,
        },
        'sources': [
          {'name': 'googlePlay', 'url': 'https://play.google.com'},
        ],
      };

      final result = parser.parse(value, isDebug: isDebug, isOverride: isOverride);

      expect(result?.version, Version.parse('0.2.4'));
      expect(result?.date, DateTime(2014, 10, 17, 23));
      expect(result?.settings, isNotNull);
      expect(result?.sources?.firstOrNull?.name, 'googlePlay');
    });

    test('throws exception if version is missing and isOverride is false', () {
      final value = {
        'date': '2024-08-24 15:35:00',
        'sources': [],
      };

      expect(
        () => parser.parse(value, isDebug: isDebug, isOverride: isOverride),
        throwsA(isA<UpdateConfigException>()),
      );
    });

    test('parses release without version if isOverride is true', () {
      final value = {
        'date': '2024-08-24 15:35:00',
        'sources': [],
      };

      final result = parser.parse(value, isDebug: isDebug, isOverride: true);

      expect(result?.version, isNull);
      expect(result?.date?.isUtc, false);
      expect(result?.date, DateTime(2024, 8, 24, 15, 35));
      expect(result?.sources, isEmpty);
    });

    test('throws exception if date is invalid', () {
      final value = {
        'version': '0.3.7',
        'date': 'invalid-date-format',
        'sources': [],
      };

      expect(
        () => parser.parse(value, isDebug: isDebug, isOverride: isOverride),
        throwsA(isA<UpdateConfigException>()),
      );
    });

    test('parses release with custom metadata fields', () {
      final value = {
        'version': '0.3.7',
        'date': '2024-08-24 15:35:00',
        'is_super_ultra_mega_release': true,
        'sources': [],
      };

      final result = parser.parse(value, isDebug: isDebug, isOverride: isOverride);

      expect(result?.version, Version.parse('0.3.7'));
      expect(result?.customData?['is_super_ultra_mega_release'], isTrue);
      expect(result?.sources, isEmpty);
    });

    test('parses release with timezone offset in date', () {
      final value = {
        'version': '1.2.0',
        'date': '2024-08-24T15:35:00+02:00',
        'sources': [],
      };

      final result = parser.parse(value, isDebug: isDebug, isOverride: isOverride);

      expect(result?.version, Version.parse('1.2.0'));
      expect(result?.date?.isUtc, true);
      expect(result?.date, DateTime.utc(2024, 8, 24, 13, 35));
      expect(result?.sources, isEmpty);
    });

    test('throws exception if sources is missing', () {
      final value = {
        'version': '0.3.7',
        'date': '2024-08-24 15:35:00',
      };

      expect(
        () => parser.parse(value, isDebug: isDebug, isOverride: isOverride),
        throwsA(isA<UpdateConfigException>()),
      );
    });

    test('parses release with multiple sources', () {
      final value = {
        'version': '0.3.7',
        'date': '2024-08-24 15:35:00',
        'sources': [
          'googlePlay',
          {'name': 'appStore', 'url': 'https://apple.com/app-store'},
        ],
      };

      final result = parser.parse(value, isDebug: isDebug, isOverride: isOverride);

      expect(result?.sources?.length, 2);
      expect(result?.sources?.firstOrNull?.name, 'googlePlay');
      expect(result?.sources?.elementAtOrNull(1)?.name, 'appStore');
    });
  });
}
