import 'dart:ui';

import '../update_config_exception.dart';

class LocaleParser {
  const LocaleParser();

  // ignore: prefer-boolean-prefixes
  Locale? parse(
    // ignore: avoid-dynamic
    dynamic value,
  ) {
    if (value is! String?) throw const UpdateConfigException();

    if (value == null) return null;

    final list = value.split('_');

    final (languageCode, countryCode) = (list.first, list.lastOrNull);

    final locale = Locale(languageCode, countryCode);

    return locale;
  }
}
