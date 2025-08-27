import 'dart:io';

import 'package:flutter/foundation.dart';

import 'update_entity.dart';

@immutable
base class UpdatePlatform extends UpdateEntityName {
  static const android = UpdatePlatform._('android');
  static const fuchsia = UpdatePlatform._('fuchsia');
  static const ios = UpdatePlatform._('ios');
  static const linux = UpdatePlatform._('linux');
  static const macos = UpdatePlatform._('macos');
  static const windows = UpdatePlatform._('windows');
  static const web = UpdatePlatform._('web');
  static const any = UpdatePlatform._('any');

  static const values = [
    android,
    fuchsia,
    ios,
    linux,
    macos,
    windows,
    web,
  ];

  static const valuesWithAny = [
    ...values,
    any,
  ];

  const UpdatePlatform._(super._name);

  const factory UpdatePlatform.custom(String name) = UpdatePlatform._;

  factory UpdatePlatform.current() => UpdatePlatform._(
        kIsWeb ? web.name : Platform.operatingSystem,
      );
}
