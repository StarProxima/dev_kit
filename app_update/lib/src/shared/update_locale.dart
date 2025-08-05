import 'package:flutter/material.dart';

import 'update_entity.dart';

class UpdateLocale extends UpdateEntity {
  static const any = UpdateLocale(null, 'any');

  final Locale? locale;
  const UpdateLocale(this.locale, [super._name = 'direct']);

  @override
  List<Object?> get params => [name, locale];
}
