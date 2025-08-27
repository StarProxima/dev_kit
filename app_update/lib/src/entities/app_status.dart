import 'package:flutter/foundation.dart';

import 'update_entity.dart';

@immutable
base class AppStatus extends UpdateEntityName {
  static const unsupported = AppStatus._('unsupported');

  static const outdated = AppStatus._('outdated');

  static const active = AppStatus._('active');
  static const any = AppStatus._('any');
  static const values = [
    unsupported,
    outdated,
    active,
  ];
  static const valuesWithAny = [
    ...values,
    any,
  ];

  const AppStatus._(super._name);

  const factory AppStatus.custom(String name) = AppStatus._;

  @override
  String get debugString => 'AppStatus($name)';
}
