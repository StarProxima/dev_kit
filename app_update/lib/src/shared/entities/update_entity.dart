import 'package:flutter/widgets.dart';

@immutable
abstract class UpdateEntityName extends UpdateEntityBase {
  final String _name;

  String get name => _name.toLowerCase();

  @override
  List<Object?> get params => [name];

  const UpdateEntityName(this._name);
}

@immutable
abstract class UpdateEntityBase {
  const UpdateEntityBase();

  List<Object?> get params;

  // ignore: member-ordering
  @override
  int get hashCode => Object.hashAll(params);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! UpdateEntityName) return false;

    return other.params.length == params.length &&
        other.params.every((param) => params.contains(param));
  }
}
