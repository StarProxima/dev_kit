import 'package:flutter/material.dart';

import 'update_entity.dart';

class UpdateLocale extends UpdateEntity {
  static const any = UpdateLocale(null, name: 'any');

  final Locale? locale;
  const UpdateLocale(this.locale, {String name = 'direct'}) : super(name);

  @override
  List<Object?> get params => [name, locale];

  static const values = [
    any,
  ];
}
