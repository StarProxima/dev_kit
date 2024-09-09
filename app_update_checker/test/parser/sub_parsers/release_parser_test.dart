// ignore_for_file: avoid-long-functions, prefer-test-matchers, avoid-unsafe-collection-methods, map-keys-ordering

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:update_check/src/parser/models/update_config_exception.dart';
import 'package:update_check/src/parser/update_config_parser.dart';
import 'package:update_check/src/shared/release_status.dart';
import 'package:update_check/src/shared/text_translations.dart';

void main() {
  group('ReleaseParser', () {
    const releaseParser = ReleaseParser();
    const isDebug = true;

    test('should parse valid ReleaseConfig', () {
      final value = {
        'version': '0.3.7',
        'ref_version': '0.3.6',
        'build_number': 21,
        'status': 'required',
        'release_note': {
          'en': 'New features and bug fixes',
        },
        'publish_date_utc': '2024-08-24 15:35:00',
        'stores': [
          {
            'name': 'googlePlay',
            'url': 'https://example.com',
          },
          {
            'name': 'appStore',
            'url': 'https://example.com',
          },
        ],
        'customField': 'customValue',
      };

      final result = releaseParser.parse(value, isDebug: isDebug);

      expect(result, isNotNull);
      expect(result?.version.toString(), '0.3.7');
      expect(result?.refVersion?.toString(), '0.3.6');
      expect(result?.buildNumber, 21);
      expect(result?.status, ReleaseStatus.required);
      expect(
        result?.releaseNoteTranslations?.byLocale(Locale('ababa')),
        'New features and bug fixes',
      );
      expect(result?.publishDateUtc?.toString(), '2024-08-24 15:35:00.000');
      expect(result?.stores, hasLength(2));
      // ignore: prefer-first
      expect(result?.stores?[0].name, 'googlePlay');
      expect(result?.stores?[1].name, 'appStore');
      expect(result?.customData?['customField'], 'customValue');
    });

    test('should return null if version is missing', () {
      final value = {
        'ref_version': '0.3.6',
        'build_number': 21,
      };

      final result = releaseParser.parse(value, isDebug: false);
      expect(result, isNull);

      expect(
        () => releaseParser.parse(value, isDebug: isDebug),
        throwsA(isA<UpdateConfigException>()),
      );
    });

    test('should handle invalid date format', () {
      final value = {
        'version': '0.3.7',
        'publish_date_utc': 'invalid-date',
      };

      final release = releaseParser.parse(value, isDebug: false);
      expect(release, isNull);

      expect(
        () => releaseParser.parse(value, isDebug: isDebug),
        throwsA(isA<UpdateConfigException>()),
      );
    });

    test('should throw exception in debug mode when invalid build_number', () {
      final value = {
        'version': '0.3.7',
        'build_number': 'invalid-number', // Некорректный тип для build_number
      };

      final release = releaseParser.parse(value, isDebug: false);
      expect(release, isNull);

      expect(
        () => releaseParser.parse(value, isDebug: isDebug),
        throwsA(isA<UpdateConfigException>()),
      );
    });

    test('should parse ReleaseConfig with missing optional fields', () {
      final value = {
        'version': '0.3.7',
        'ref_version': '0.3.6',
        // Опциональные поля отсутствуют
      };

      final result = releaseParser.parse(value, isDebug: isDebug);

      expect(result, isNotNull);
      expect(result?.version.toString(), '0.3.7');
      expect(result?.refVersion?.toString(), '0.3.6');
      expect(result?.buildNumber, isNull);
      expect(result?.status, isNull);
      expect(result?.releaseNoteTranslations, isNull);
      expect(result?.publishDateUtc, isNull);
      expect(result?.stores, isNull);
      expect(result?.customData, hasLength(0));
    });

    test('should throw exception in debug mode for invalid status', () {
      final value = {
        'version': '0.3.7',
        'status': 'invalid-status', // Некорректное значение статуса
      };

      final release = releaseParser.parse(value, isDebug: false);
      expect(release, isNull);

      expect(
        () => releaseParser.parse(value, isDebug: isDebug),
        throwsA(isA<UpdateConfigException>()),
      );
    });
  });
}
