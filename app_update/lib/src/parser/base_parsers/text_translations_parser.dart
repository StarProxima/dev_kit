// ignore_for_file: prefer-type-over-var

import 'dart:ui';

import '../../shared/text_translations.dart';
import '../models/update_config_exception.dart';

class TextTranslationsParser {
  const TextTranslationsParser();

  TextTranslations? parse(
    // ignore: avoid-dynamic
    dynamic value, {
    required bool isDebug,
  }) {
    TextTranslations? text;
    if (value is! Map<String, dynamic>?) {
      if (value is String) {
        return TextTranslations({kAppUpdateDefaultLocale: value});
      }

      if (isDebug) throw const UpdateConfigException();
      text = null;
    } else if (value != null) {
      final map = Map<Locale, String>.fromEntries(
        value.entries.map((e) => MapEntry(Locale(e.key), e.value)),
      );

      if (map.isEmpty) return null;

      text = TextTranslations(map);
    }

    return text;
  }
}
