import 'package:flutter/material.dart';

import 'update_entity.dart';

// ignore: prefer-overriding-parent-equality
base class UpdateLocale extends UpdateEntityName {
  final Locale? locale;

  static const ru = UpdateLocale(Locale('ru'));
  static const en = UpdateLocale(Locale('en'));
  static const any = UpdateLocale(null, name: 'any');

  static const values = [
    ru,
    en,
  ];

  static const valuesWithAny = [
    ...values,
    any,
  ];

  const UpdateLocale(this.locale, {String name = 'direct'}) : super(name);

  @override
  List<Object?> get params => [name, locale?.languageCode];

  @override
  String toString() => '${locale ?? name}';
}
