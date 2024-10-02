import 'dart:ui';

// ignore: prefer-static-class, prefer-prefixed-global-constants
const appUpdateDefaultLocale = Locale('en');

typedef TextTranslations = Map<Locale, String>;

extension ByLocaleX on TextTranslations {
  String byLocale(Locale locale) =>
      this[locale] ??
      this[appUpdateDefaultLocale] ??
      values.firstOrNull ??
      (throw Exception('At least one locale must be specified'));
}
