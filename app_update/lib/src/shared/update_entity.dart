import 'package:flutter/widgets.dart';

@immutable
abstract class UpdateEntity {
  final String _name;

  String get name => _name.toLowerCase();

  List<Object?> get params => [name];

  const UpdateEntity(this._name);

  // ignore: member-ordering
  @override
  int get hashCode => Object.hashAll(params);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! UpdateEntity) return false;

    return other.params.length == params.length && other.params.every((param) => params.contains(param));
  }
}
