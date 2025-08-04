import 'package:flutter/foundation.dart';

@immutable
class UpdateViewTarget {
  final String _name;

  String get name => _name.toLowerCase();

  const UpdateViewTarget._(this._name);

  factory UpdateViewTarget.custom(String name) => UpdateViewTarget._(name);

  static const all = UpdateViewTarget._('all');
  static const card = UpdateViewTarget._('card');
  static const dialog = UpdateViewTarget._('dialog');
  static const adaptiveDialog = UpdateViewTarget._('adaptive_dialog');
  static const materialDialog = UpdateViewTarget._('material_dialog');
  static const cupertinoDialog = UpdateViewTarget._('cupertino_dialog');
  static const screen = UpdateViewTarget._('screen');
  static const bottomModalSheet = UpdateViewTarget._('bottom_modal_sheet');

  static const values = [
    all,
    card,
    dialog,
    adaptiveDialog,
    materialDialog,
    cupertinoDialog,
    screen,
    bottomModalSheet,
  ];

  // ignore: member-ordering
  @override
  int get hashCode => name.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! UpdateViewTarget) return false;

    return other.name == name;
  }
}
