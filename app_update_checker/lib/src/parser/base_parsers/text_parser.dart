// ignore_for_file: prefer-type-over-var

import 'dart:ui';

import '../../shared/text_translations.dart';
import '../../shared/update_status_wrapper.dart';
import '../models/update_config_exception.dart';
import '../update_config_parser.dart';

class TextTranslationsParser {
  UpdateStatusWrapperParser get updateStatusWrapperParser => const UpdateStatusWrapperParser();

  const TextTranslationsParser();

  UpdateStatusWrapper<TextTranslations?> parseWithStatuses(
    // ignore: avoid-dynamic
    dynamic value, {
    required bool isDebug,
    required WrapperMode mode,
  }) {
    // ignore: avoid-inferrable-type-arguments
    return updateStatusWrapperParser.parse<TextTranslations?>(
      value,
      parse: (value) => parse(value, isDebug: isDebug),
      mode: mode,
    );
  }

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
