import 'package:flutter/widgets.dart';

@immutable
abstract base class UpdateEntityName extends UpdateEntity {
  final String _name;

  // ignore: no-empty-string
  String get name => _name.replaceAll(' ', '').toLowerCase();

  // ignore: match-getter-setter-field-names
  String get originalName => _name;

  @override
  List<Object?> get params => [name];

  const UpdateEntityName(this._name);
}

@immutable
abstract base class UpdateEntity {
  const UpdateEntity();

  List<Object?> get params;

  @override
  int get hashCode => Object.hashAll(params);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! UpdateEntityName) return false;

    return other.params.length == params.length &&
        other.params.every((param) => params.contains(param));
  }

  String get debugString;

  @override
  String toString() => debugString;
}
