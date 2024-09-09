import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:update_check/src/parser/models/update_config_exception.dart';
import 'package:update_check/src/parser/update_config_parser.dart';
import 'package:update_check/src/shared/text_translations.dart';

void main() {
  group('TextParser', () {
    const textParser = TextParser();
    const isDebug = true;

    const enText = 'English text';
    const esText = 'Texto en español';
    const ruText = 'Текст на русском';
    const mixedLocalesMap = {
      'de': 'Neue Version verfügbar',
      'en': 'Version available',
      'fr': 'Nouvelle version disponible',
    };

    test('should return default Locale (en) when value is a String', () {
      const value = 'This is a simple string';
      final result = textParser.parse(value, isDebug: isDebug);
      expect(result, equals({appUpdateDefaultLocale: value}));
    });

    test('should return map of Locale to String when value is a Map', () {
      final value = {
        'en': enText,
        'es': esText,
        'ru': ruText,
      };
      final result = textParser.parse(value, isDebug: isDebug);
      expect(
        result,
        equals({
          const Locale('en'): enText,
          const Locale('es'): esText,
          const Locale('ru'): ruText,
        }),
      );
    });

    test(
      'should throw UpdateConfigException when value is not String or Map and in debug mode',
      () {
        const value = 123; // wrong type
        expect(
          () => textParser.parse(value, isDebug: isDebug),
          throwsA(isA<UpdateConfigException>()),
        );
      },
    );

    test(
      'should return null when value is not String or Map and not in debug mode',
      () {
        const value = 123; // wrong type
        final result = textParser.parse(value, isDebug: false);
        expect(result, isNull);
      },
    );

    test('should return null when value is null', () {
      final result = textParser.parse(null, isDebug: isDebug);
      expect(result, isNull);
    });

    // TODO: Что должно быть при пустой мапе? Null?
    test('should handle empty Map and return empty map', () {
      final value = <String, String>{};
      final result = textParser.parse(value, isDebug: isDebug);
      expect(result, isNull);
    });

    test('should handle mixed locales and values correctly', () {
      final result = textParser.parse(mixedLocalesMap, isDebug: isDebug);
      expect(
        result,
        equals({
          const Locale('en'): mixedLocalesMap['en'],
          const Locale('fr'): mixedLocalesMap['fr'],
          const Locale('de'): mixedLocalesMap['de'],
        }),
      );
    });
  });
}
