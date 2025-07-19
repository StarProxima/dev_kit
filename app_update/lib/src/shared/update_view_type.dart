import 'package:flutter/foundation.dart';

@immutable
class UpdateViewType {
  final String _name;

  String get name => _name.toLowerCase();

  const UpdateViewType._(this._name);

  factory UpdateViewType.custom(String name) => UpdateViewType._(name);

  static const all = UpdateViewType._('all');
  static const card = UpdateViewType._('card');
  static const dialog = UpdateViewType._('dialog');
  static const adaptiveDialog = UpdateViewType._('adaptive_dialog');
  static const materialDialog = UpdateViewType._('material_dialog');
  static const cupertinoDialog = UpdateViewType._('cupertino_dialog');
  static const screen = UpdateViewType._('screen');
  static const bottomModalSheet = UpdateViewType._('bottom_modal_sheet');

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

    if (other is! UpdateViewType) return false;

    return other.name == name;
  }
}
