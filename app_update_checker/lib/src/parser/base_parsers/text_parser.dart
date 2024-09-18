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
    var text = value;
    if (text is! Map<String, dynamic>?) {
      if (text is String) {
        return {appUpdateDefaultLocale: text};
      }

      if (isDebug) throw const UpdateConfigException();
      text = null;
    } else if (text != null) {
      text = Map<Locale, String>.fromEntries(
        text.entries.map((e) => MapEntry(Locale(e.key), e.value)),
      );
      text as Map<Locale, String>;
      if (text.isEmpty) return null;
    }

    return text;
  }
}
