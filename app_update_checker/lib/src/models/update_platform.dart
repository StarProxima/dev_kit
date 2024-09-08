import 'dart:io';

import 'package:flutter/foundation.dart';

@immutable
class UpdatePlatform {
  static const android = UpdatePlatform('android');
  static const fuchsia = UpdatePlatform('fuchsia');
  static const ios = UpdatePlatform('ios');
  static const linux = UpdatePlatform('linux');
  static const macos = UpdatePlatform('macos');
  static const windows = UpdatePlatform('windows');
  static const web = UpdatePlatform('web');

  static const values = [android, fuchsia, ios, linux, macos, windows, web];

  final String _platform;

  String get platform => _platform.toLowerCase();

  const UpdatePlatform(this._platform);

  factory UpdatePlatform.current() => UpdatePlatform(
        kIsWeb ? web.platform : Platform.operatingSystem,
      );

  // ignore: member-ordering
  @override
  int get hashCode => platform.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! UpdatePlatform) return false;

    return other.platform == platform;
  }
}
