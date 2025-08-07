import 'dart:ui';

import '../common.dart';

class LocaleParser {
  const LocaleParser();

  // ignore: prefer-boolean-prefixes
  Locale? parse(
    // ignore: avoid-dynamic
    dynamic value,
  ) {
    if (value == null) return null;

    if (value is! String) throw const UpdateConfigException();

    final list = value.split('_');

    final (languageCode, countryCode) = (list.first, list.lastOrNull);

    final locale = Locale(languageCode, countryCode);

    return locale;
  }
}
