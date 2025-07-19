import 'package:flutter/foundation.dart';

@immutable
class AppVersionStatus {
  final String _name;

  String get name => _name.toLowerCase();

  const AppVersionStatus._(this._name);

  const factory AppVersionStatus.custom(String name) = AppVersionStatus._;

  static const all = AppVersionStatus._('all');

  static const unsupported = AppVersionStatus._('unsupported');
  static const deprecated = AppVersionStatus._('deprecated');
  static const outdated = AppVersionStatus._('outdated');
  static const active = AppVersionStatus._('active');

  static const values = [
    unsupported,
    deprecated,
    outdated,
    active,
  ];

  // ignore: member-ordering
  @override
  int get hashCode => name.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! AppVersionStatus) return false;

    return other.name == name;
  }
}
