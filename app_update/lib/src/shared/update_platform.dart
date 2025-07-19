import 'dart:io';

import 'package:flutter/foundation.dart';

@immutable
class UpdatePlatform {
  static const android = UpdatePlatform.custom('android');
  static const fuchsia = UpdatePlatform.custom('fuchsia');
  static const ios = UpdatePlatform.custom('ios');
  static const linux = UpdatePlatform.custom('linux');
  static const macos = UpdatePlatform.custom('macos');
  static const windows = UpdatePlatform.custom('windows');
  static const web = UpdatePlatform.custom('web');

  static const values = [
    android,
    fuchsia,
    ios,
    linux,
    macos,
    windows,
    web,
  ];

  final String _name;

  String get name => _name.toLowerCase();

  const UpdatePlatform._(this._name);

  const factory UpdatePlatform.custom(String name) = UpdatePlatform._;

  factory UpdatePlatform.current() => UpdatePlatform._(
        kIsWeb ? web.name : Platform.operatingSystem,
      );

  // ignore: member-ordering
  @override
  int get hashCode => name.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! UpdatePlatform) return false;

    return other.name == name;
  }
}
