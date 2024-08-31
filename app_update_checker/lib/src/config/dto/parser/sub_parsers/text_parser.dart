// ignore_for_file: prefer-type-over-var

part of '../checker_config_dto_parser.dart';

class _TextParser {
  const _TextParser();

  Map<Locale, String> parse(
    // ignore: avoid-dynamic
    dynamic value, {
    required bool isDebug,
  }) {
    var text = value;
    if (text is! Map<String, dynamic>?) {
      if (text is String) {
        return {const Locale('en'): text};
      }

      if (isDebug) throw const DtoParserException();
      text = null;
    } else if (text != null) {
      text = Map<Locale, String>.fromEntries(
        text.entries.map((e) => MapEntry(Locale(e.key), e.value)),
      );
      text as Map<Locale, Object>?;
      text as Map<Locale, String>?;
    }

    return text;
  }
}
