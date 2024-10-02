// ignore_for_file: avoid-long-functions, prefer-test-matchers, prefer-moving-to-variable, avoid-misused-test-matchers

import 'package:app_update/src/parser/models/update_config_exception.dart';
import 'package:app_update/src/parser/update_config_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UpdateConfigParser', () {
    const updateConfigParser = UpdateConfigParser();
    const isDebug = true;

    test('should parse valid UpdateConfigModel', () {
      final configMap = {
        'release_settings': {
          'title': {
            'en': 'New version available',
          },
          'description': 'Update to the latest version!',
        },
        'stores': [
          {
            'name': 'googlePlay',
            'url': 'https://play.google.com',
          },
          {
            'name': 'appStore',
            'url': 'https://apps.apple.com',
          },
        ],
        'releases': [
          {
            'version': '1.0.0',
            'status': 'active',
          },
          {
            'version': '1.1.0',
            'status': 'required',
          },
        ],
        'customField': 'customValue',
      };

      final result = updateConfigParser.parseConfig(configMap, isDebug: isDebug);

      expect(result, isNotNull);
      expect(result.settings, isNotNull);
      expect(result.sources, hasLength(2));
      expect(result.releases, hasLength(2));
      expect(result.customData?['customField'], 'customValue');
    });

    test('should throw exception if short store syntax for global store', () {
      final configMap = {
        'stores': [
          'googlePlay',
          {
            'name': 'appStore',
            'url': 'https://apps.apple.com',
          },
        ],
        'releases': [],
      };

      expect(
        () => updateConfigParser.parseConfig(configMap, isDebug: false),
        throwsA(isA<UpdateConfigException>()),
      );
    });

    test('should throw exception if releases are missing', () {
      final configMap = {
        'release_settings': {
          'title': {
            'en': 'New version available',
          },
          'description': 'Update to the latest version!',
        },
        'stores': [
          {
            'name': 'googlePlay',
            'url': 'https://play.google.com',
          },
        ],
      };

      expect(
        () => updateConfigParser.parseConfig(configMap, isDebug: false),
        throwsA(isA<UpdateConfigException>()),
      );
    });

    test('should handle invalid stores format', () {
      final configMap = {
        'release_settings': {
          'title': {
            'en': 'New version available',
          },
          'description': 'Update to the latest version!',
        },
        'stores': 'invalid-format', // Некорректный формат
        'releases': [
          {
            'version': '1.0.0',
            'status': 'active',
          },
        ],
      };

      expect(
        () => updateConfigParser.parseConfig(configMap, isDebug: false),
        throwsA(isA<UpdateConfigException>()),
      );
    });

    test('should parse UpdateConfigModel with missing optional fields', () {
      final configMap = {
        'releases': [
          {
            'version': '1.0.0',
            'status': 'active',
          },
        ],
      };

      final result = updateConfigParser.parseConfig(configMap, isDebug: isDebug);

      expect(result.settings, isNull);
      expect(result.sources, isNull);
      expect(result.releases, hasLength(1));
      expect(result.releases.firstOrNull?.version.toString(), '1.0.0');
      expect(result.customData, isEmpty);
    });

    test('should throw exception for invalid release format', () {
      final configMap = {
        'release_settings': {
          'title': {
            'en': 'New version available',
          },
          'description': 'Update to the latest version!',
        },
        'stores': [
          {
            'name': 'googlePlay',
            'url': 'https://play.google.com',
          },
        ],
        'releases': 'invalid-format', // Некорректный формат
      };

      expect(
        () => updateConfigParser.parseConfig(configMap, isDebug: false),
        throwsA(isA<UpdateConfigException>()),
      );
    });
  });
}
