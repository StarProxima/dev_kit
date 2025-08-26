import 'package:flutter/material.dart';

import 'update_entity.dart';

class UpdateLocale extends UpdateEntityName {
  static const any = UpdateLocale(null, name: 'any');

  final Locale? locale;
  const UpdateLocale(this.locale, {String name = 'direct'}) : super(name);

  static const ru = UpdateLocale(Locale('ru'), name: 'ru');
  static const en = UpdateLocale(Locale('en'), name: 'en');

  @override
  List<Object?> get params => [name, locale];

  static const values = [
    ru,
    en,
  ];

  static const allValues = [
    ...values,
    any,
  ];
}
