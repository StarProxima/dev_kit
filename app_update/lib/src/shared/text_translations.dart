import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

// ignore: prefer-static-class
const kAppUpdateDefaultLocale = Locale('en');

@immutable
class TextTranslations {
  final Map<Locale, String> value;

  @override
  int get hashCode => const DeepCollectionEquality().hash(value);

  const TextTranslations(this.value);

  @override
  bool operator ==(Object other) {
    if (other is! TextTranslations) return false;

    return const DeepCollectionEquality().equals(value, other.value);
  }

  String byLocale(Locale locale) =>
      value[locale] ??
      value[kAppUpdateDefaultLocale] ??
      value.values.firstOrNull ??
      (throw Exception('At least one locale must be specified'));
}
