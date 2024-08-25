// ignore_for_file: prefer-type-over-var

part of '../checker_config_dto_parser.dart';

class _TextParser {
  final bool isDebug;

  const _TextParser({required this.isDebug});

  // ignore: avoid-dynamic
  Map<Locale, String> parse(dynamic textWithLocales) {
    var text = textWithLocales;
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
