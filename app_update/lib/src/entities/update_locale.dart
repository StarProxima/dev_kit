import 'package:flutter/material.dart';

import 'update_entity.dart';

base class UpdateLocale extends UpdateEntityName {
  static const any = UpdateLocale(null, name: 'any');

  final Locale? locale;
  static const ru = UpdateLocale(Locale('ru'), name: 'ru');

  static const en = UpdateLocale(Locale('en'), name: 'en');
  static const values = [
    ru,
    en,
  ];

  static const allValues = [
    ...values,
    any,
  ];

  const UpdateLocale(this.locale, {String name = 'direct'}) : super(name);

  @override
  List<Object?> get params => [name, locale];
}
