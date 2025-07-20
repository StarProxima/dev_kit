import 'package:flutter/foundation.dart';

@immutable
class AppStatus {
  final String _name;

  String get name => _name.toLowerCase();

  const AppStatus._(this._name);

  const factory AppStatus.custom(String name) = AppStatus._;

  static const all = AppStatus._('all');

  static const unsupported = AppStatus._('unsupported');
  static const outdated = AppStatus._('outdated');
  static const active = AppStatus._('active');

  static const values = [
    unsupported,
    outdated,
    active,
  ];

  // ignore: member-ordering
  @override
  int get hashCode => name.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! AppStatus) return false;

    return other.name == name;
  }
}
