import 'package:flutter/foundation.dart';

@immutable
class ReleaseStatus {
  final String _name;

  String get name => _name.toLowerCase();

  const ReleaseStatus._(this._name);

  const factory ReleaseStatus.custom(String name) = ReleaseStatus._;

  static const all = ReleaseStatus._('all');

  static const discontinued = ReleaseStatus._('discontinued');
  static const active = ReleaseStatus._('active');

  static const values = [
    discontinued,
    active,
  ];

  // ignore: member-ordering
  @override
  int get hashCode => name.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! ReleaseStatus) return false;

    return other.name == name;
  }
}
