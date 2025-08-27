import 'dart:ui';

import '../parse_config_exeption.dart';

class LocaleParser {
  const LocaleParser();

  Locale? parse(
    Object? value,
  ) {
    if (value == null) return null;

    if (value is! String) {
      throw ParseConfigException.wrongType(
        rightType: String,
        wrongType: value.runtimeType,
        parserType: LocaleParser,
        configs: [value],
      );
    }

    // split by _ or -
    final list = value.split(RegExp('[-_]'));

    final (languageCode, countryCode) = (
      list.firstOrNull ?? (throw const ParseConfigException()),
      list.lastOrNull,
    );

    final locale = Locale(languageCode, countryCode);

    return locale;
  }
}
