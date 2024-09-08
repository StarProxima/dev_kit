import 'dart:ui';

typedef LocalizedText = Map<Locale, String>;

extension ByLocaleX on LocalizedText {
  String byLocale(Locale locale) =>
      this[locale] ?? this[const Locale('en')] ?? values.firstOrNull ?? (throw Exception('At least one locale must be specified'));
}
