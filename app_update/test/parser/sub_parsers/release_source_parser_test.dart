// ignore_for_file: avoid-long-functions, prefer-test-matchers

import 'package:app_update/src/parser/models/update_config_exception.dart';
import 'package:app_update/src/parser/update_config_parser.dart';
import 'package:app_update/src/shared/text_translations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReleaseSourceParser', () {
    const parser = ReleaseSourceParser();
    const isDebug = true;
    const isOverride = false;

    test('parses short string syntax for source name only', () {
      const value = 'appStore';

      final result = parser.parse(value, isDebug: isDebug, isOverride: isOverride);

      expect(result?.name, 'appStore');
      expect(result?.url, isNull);
      expect(result?.platforms, isNull);
      expect(result?.release, isNull);
    });

    test('parses full syntax with name, url, and release settings', () {
      final value = {
        'name': 'ruStore',
        'url': 'https://www.example.com',
        'platforms': ['android'],
        'release': {
          'version': '1.2.1',
          'settings': {'title': 'RuStore Title'},
        },
      };

      final result = parser.parse(value, isDebug: isDebug, isOverride: isOverride);

      expect(result?.name, 'ruStore');
      expect(result?.url?.toString(), 'https://www.example.com');
      expect(result?.platforms?.length, 1);
      expect(result?.platforms?.firstOrNull?.platform.name, 'android');
      expect(result?.release?.version?.toString(), '1.2.1');
      expect(
        result?.release?.settings
            ?.getByRaw(type: 'base', status: 'base')
            ?.translations
            ?.title
            ?.byLocale(kAppUpdateDefaultLocale),
        'RuStore Title',
      );
    });

    test('parses nested platforms with different syntaxes', () {
      final value = {
        'name': 'github',
        'url': 'https://github.com/hiddify/hiddify-next/releases/',
        'release': {
          'date': '2014-10-20 12:00:00',
        },
        'platforms': [
          'macos',
          'linux',
          {
            'name': 'windows',
            'source': {
              'url': 'https://github.com/hiddify/hiddify-next/releases/download/v0.14.0/hiddify-windows-x64-setup.zip',
              'release': {
                'date': '2014-10-20 13:00:00',
                'settings': {'release_notes': 'Windows Github release notes'},
              },
            },
          },
        ],
      };

      final result = parser.parse(value, isDebug: isDebug, isOverride: isOverride);

      expect(result?.name, 'github');
      expect(
        result?.url?.toString(),
        'https://github.com/hiddify/hiddify-next/releases/',
      );
      expect(
        result?.release?.date?.toString(),
        '2014-10-20 12:00:00.000',
      );
      expect(result?.platforms?.length, 3);

      final windowsPlatform = result?.platforms?.lastOrNull;
      expect(windowsPlatform?.platform.name, 'windows');
      expect(
        windowsPlatform?.source?.url?.toString(),
        'https://github.com/hiddify/hiddify-next/releases/download/v0.14.0/hiddify-windows-x64-setup.zip',
      );

      final platformSourceRelease = windowsPlatform?.source?.release;
      expect(
        platformSourceRelease?.settings
            ?.getByRaw(type: 'base', status: 'base')
            ?.translations
            ?.releaseNote
            ?.byLocale(kAppUpdateDefaultLocale),
        'Windows Github release notes',
      );
      expect(
        platformSourceRelease?.date?.toString(),
        '2014-10-20 13:00:00.000',
      );
    });

    test('throws exception when name is missing in full syntax', () {
      final value = {
        'url': 'https://www.example.com',
      };

      expect(
        () => parser.parse(value, isDebug: isDebug, isOverride: isOverride),
        throwsA(isA<UpdateConfigException>()),
      );
    });

    test('throws exception when url is not valid', () {
      final value = {
        'name': 'googlePlay',
        'url': '::invalid-url::',
      };

      expect(
        () => parser.parse(value, isDebug: isDebug, isOverride: isOverride),
        throwsA(isA<UpdateConfigException>()),
      );
    });

    test('parses source without url when isOverride is true', () {
      final value = {
        'name': 'googlePlay',
      };

      final result = parser.parse(value, isDebug: isDebug, isOverride: true);
      expect(result?.name, 'googlePlay');
      expect(result?.url, isNull);
    });

    test('throws exception if platforms is not a list', () {
      final value = {
        'name': 'googlePlay',
        'url': 'https://www.example.com',
        'platforms': 'invalid_platform_data',
      };

      expect(
        () => parser.parse(value, isDebug: isDebug, isOverride: isOverride),
        throwsA(isA<UpdateConfigException>()),
      );
    });

    test('throws exception if release is not a map', () {
      final value = {
        'name': 'googlePlay',
        'url': 'https://www.example.com',
        'release': 'invalid_release_data',
      };

      expect(
        () => parser.parse(value, isDebug: isDebug, isOverride: isOverride),
        throwsA(isA<UpdateConfigException>()),
      );
    });
  });
}
