// ignore_for_file: avoid-long-functions, no-equal-arguments

import 'package:app_update/src/parser/common.dart';
import 'package:app_update/src/parser/update_config_parser.dart';
import 'package:app_update/src/shared/text_translations.dart';
import 'package:app_update/src/shared/update_alert_type.dart';
import 'package:app_update/src/shared/version_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GlobalSourceParser', () {
    const parser = GlobalSourceParser();
    const isDebug = true;

    test('parses valid data with multiple sources', () {
      final value = {
        'name': 'googlePlay',
        'url': 'https://example.com',
      };

      final result = parser.parse(value, isDebug: isDebug, isOverride: false);

      expect(result?.name, 'googlePlay');
      expect(result?.url?.toString(), 'https://example.com');
      expect(result?.platforms, isNull);
      expect(result?.settings, isNull);
      expect(result?.versionSettings, isNull);
    });

    test('parses source with update and version settings', () {
      final value = {
        'name': 'ruStore',
        'url': 'https://example.com',
        'text': {'title': 'Title'},
        'version_settings': {
          'unsupported_versions': ['<=4.2.0'],
        },
      };

      final result = parser.parse(value, isDebug: isDebug, isOverride: false);

      expect(result?.name, 'ruStore');
      expect(result?.url?.toString(), 'https://example.com');
      expect(
        result?.text
            ?.getByBase(
              type: UpdateAlertTypeBase.base,
              status: VersionStatusBase.base,
              locale: kAppUpdateDefaultLocale,
            )
            ?.title,
        'Title',
      );
      expect(result?.versionSettings?.unsupportedVersions, isNotEmpty);
      expect(
        result?.versionSettings?.unsupportedVersions?.firstOrNull?.toString(),
        '<=4.2.0',
      );
    });

    test('parses source with nested platforms (full and short syntax)', () {
      final value = {
        'name': 'gitHub',
        'url': 'https://example.com',
        'platforms': [
          {
            'name': 'android',
            'source': {
              'url': 'https://example.com/android',
              'text': {'title': 'Title'},
              'settings': {'can_skip_release': false},
              'version_settings': {
                'deprecated_versions': ['>5.6.0 <5.6.7'],
              },
            },
          },
          'windows',
          'macos',
          'linux',
        ],
      };

      final result = parser.parse(value, isDebug: isDebug, isOverride: false);

      expect(result?.name, 'gitHub');
      expect(result?.url?.toString(), 'https://example.com');
      expect(result?.platforms?.length, 4);

      final androidPlatform = result?.platforms?.firstOrNull;
      expect(androidPlatform?.platform.name, 'android');
      expect(
        androidPlatform?.sourceOverride?.url?.toString(),
        'https://example.com/android',
      );
      expect(
        androidPlatform?.sourceOverride?.text
            ?.getByBase(
              type: UpdateAlertTypeBase.base,
              status: VersionStatusBase.base,
              locale: kAppUpdateDefaultLocale,
            )
            ?.title,
        'Title',
      );
      expect(
        androidPlatform?.sourceOverride?.settings
            ?.getByBase(
              type: UpdateAlertTypeBase.base,
              status: VersionStatusBase.base,
            )
            ?.canSkipRelease,
        false,
      );
      expect(
        androidPlatform?.sourceOverride?.versionSettings?.deprecatedVersions?.firstOrNull
            ?.toString(),
        '>5.6.0 <5.6.7',
      );
    });

    test('parses source with single platform using short syntax', () {
      final value = {
        'name': 'site',
        'platforms': ['android'],
        'url': 'https://example.com',
      };

      final result = parser.parse(value, isDebug: isDebug, isOverride: false);

      expect(result?.name, 'site');
      expect(result?.url?.toString(), 'https://example.com');
      expect(result?.platforms?.length, 1);
      expect(result?.platforms?.firstOrNull?.platform.name, 'android');
    });

    test('throws exception when name is missing', () {
      final value = {
        'url': 'https://example.com',
      };

      expect(
        () => parser.parse(value, isDebug: isDebug, isOverride: false),
        throwsA(isA<UpdateConfigException>()),
      );
    });

    test('throws exception when url is not valid', () {
      final value = {
        'name': 'googlePlay',
        'url': '::not-a-valid-url::',
      };

      expect(
        () => parser.parse(value, isDebug: isDebug, isOverride: false),
        throwsA(isA<UpdateConfigException>()),
      );
    });

    test('throws exception when url is missing', () {
      final value = {
        'name': 'googlePlay',
      };

      expect(
        () => parser.parse(value, isDebug: isDebug, isOverride: false),
        throwsA(isA<UpdateConfigException>()),
      );
    });

    test('throws exception when platforms is not a list', () {
      final value = {
        'name': 'googlePlay',
        'url': 'https://example.com',
        'platforms': 'invalid_platform_data',
      };

      expect(
        () => parser.parse(value, isDebug: isDebug, isOverride: false),
        throwsA(isA<UpdateConfigException>()),
      );
    });

    test('throws exception when settings is not a map', () {
      final value = {
        'name': 'googlePlay',
        'url': 'https://example.com',
        'settings': 'invalid_settings_data',
      };

      expect(
        () => parser.parse(value, isDebug: isDebug, isOverride: false),
        throwsA(isA<UpdateConfigException>()),
      );
    });

    test('throws exception when version_settings is not a map', () {
      final value = {
        'name': 'googlePlay',
        'url': 'https://example.com',
        'version_settings': 'invalid_version_settings',
      };

      expect(
        () => parser.parse(value, isDebug: isDebug, isOverride: false),
        throwsA(isA<UpdateConfigException>()),
      );
    });
  });
}
