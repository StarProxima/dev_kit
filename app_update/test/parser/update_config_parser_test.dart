// ignore_for_file: avoid-long-functions

import 'package:app_update/src/parser/common.dart';
import 'package:app_update/src/parser/update_config_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UpdateConfigParser', () {
    const parser = UpdateConfigParser();
    const isDebug = true;

    test(
      'parses full config with settings, version settings, sources, and releases',
      () {
        final value = {
          'settings': {
            'base': {'can_skip_release': true},
            'dialog': {
              'updatable': {
                'title': 'Update Available',
                'can_skip_release': false,
              },
            },
          },
          'version_settings': {
            'unsupported_versions': ['<=4.2.0'],
            'deprecated_versions': ['>5.6.0 <5.6.7'],
          },
          'sources': [
            {
              'name': 'appStore',
              'url': 'https://example.com',
              'platforms': ['macos'],
            },
            {
              'name': 'googlePlay',
              'url': 'https://play.google.com',
            },
          ],
          'releases': [
            {
              'version': '1.0.0',
              'date': '2024-08-24T15:35:00Z',
              'settings': {
                'release_notes': 'Big update!',
                'can_skip_release': true,
              },
              'sources': ['googlePlay', 'appStore'],
            },
          ],
        };

        final result = parser.parse(value, isDebug: isDebug);

        expect(result.settingsRules, isNotNull);
        expect(result.appStatusRules, isNotNull);
        expect(result.sources?.length, 2);
        expect(result.releases.length, 1);
        expect(result.releases.firstOrNull?.version?.toString(), '1.0.0');
      },
    );

    test('throws exception if settings is invalid', () {
      final value = {
        'settings': 'invalid_settings',
        'version_settings': {
          'unsupported_versions': ['<=4.2.0'],
        },
        'sources': [],
        'releases': [],
      };

      expect(
        () => parser.parse(value, isDebug: isDebug),
        throwsA(isA<UpdateConfigException>()),
      );
    });

    test('parses config without settings and version settings', () {
      final value = {
        'sources': [
          {'name': 'appStore', 'url': 'https://example.com'},
        ],
        'releases': [
          {'version': '1.0.0', 'date': '2024-08-24T15:35:00Z', 'sources': []},
        ],
      };

      final result = parser.parse(value, isDebug: isDebug);

      expect(result.settingsRules, isNull);
      expect(result.appStatusRules, isNull);
      expect(result.sources?.length, 1);
      expect(result.releases.length, 1);
      expect(result.releases.firstOrNull?.version?.toString(), '1.0.0');
    });

    test('throws exception if version settings is not a map', () {
      final value = {
        'settings': {
          'base': {'can_skip_release': true},
        },
        'version_settings': 'invalid_version_settings',
        'sources': [],
        'releases': [],
      };

      expect(
        () => parser.parse(value, isDebug: isDebug),
        throwsA(isA<UpdateConfigException>()),
      );
    });

    test('parses config with only sources and releases', () {
      final value = {
        'sources': [
          {'name': 'appGallery', 'url': 'https://example.com'},
          {'name': 'ruStore', 'url': 'https://example.com'},
        ],
        'releases': [
          {
            'version': '0.2.6',
            'date': '2014-10-17T23:00:00Z',
            'sources': ['appGallery', 'ruStore'],
          },
          {'version': '0.3.0', 'date': '2014-10-18T23:00:00Z', 'sources': []},
        ],
      };

      final result = parser.parse(value, isDebug: isDebug);

      expect(result.sources?.length, 2);
      expect(result.releases.length, 2);
      expect(result.releases.firstOrNull?.sources?.length, 2);
    });

    test('throws exception if sources is not a list', () {
      final value = {
        'settings': {
          'base': {'can_skip_release': true},
        },
        'version_settings': {
          'unsupported_versions': ['<=4.2.0'],
        },
        'sources': 'invalid_sources',
        'releases': [],
      };

      expect(
        () => parser.parse(value, isDebug: isDebug),
        throwsA(isA<UpdateConfigException>()),
      );
    });

    test('throws exception if releases is not a list', () {
      final value = {
        'settings': {
          'base': {'can_skip_release': true},
        },
        'version_settings': {
          'unsupported_versions': ['<=4.2.0'],
        },
        'sources': [],
        'releases': 'invalid_releases',
      };

      expect(
        () => parser.parse(value, isDebug: isDebug),
        throwsA(isA<UpdateConfigException>()),
      );
    });

    test('parses config with empty sources and releases', () {
      final value = {
        'settings': {
          'base': {'can_skip_release': true},
        },
        'version_settings': {
          'unsupported_versions': ['<=4.2.0'],
        },
        'sources': [],
        'releases': [],
      };

      final result = parser.parse(value, isDebug: isDebug);

      expect(result.settingsRules, isNotNull);
      expect(result.appStatusRules, isNotNull);
      expect(result.sources, isEmpty);
      expect(result.releases, isEmpty);
    });
  });
}
