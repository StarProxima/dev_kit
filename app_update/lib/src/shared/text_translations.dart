import 'dart:ui';

// ignore: prefer-static-class
const kAppUpdateDefaultLocale = Locale('en');

class TextTranslations {
  final Map<Locale, String> value;

  const TextTranslations(this.value);

  String byLocale(Locale locale) =>
      value[locale] ??
      value[kAppUpdateDefaultLocale] ??
      value.values.firstOrNull ??
      (throw Exception('At least one locale must be specified'));
}
