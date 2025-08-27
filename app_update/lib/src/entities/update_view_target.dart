import 'package:flutter/foundation.dart';

import 'update_entity.dart';

@immutable
base class UpdateViewTarget extends UpdateEntityName {
  static const card = UpdateViewTarget._('card');
  static const dialog = UpdateViewTarget._('dialog');
  static const adaptiveDialog = UpdateViewTarget._('adaptiveDialog');
  static const materialDialog = UpdateViewTarget._('materialDialog');
  static const cupertinoDialog = UpdateViewTarget._('cupertinoDialog');
  static const screen = UpdateViewTarget._('screen');
  static const bottomModalSheet = UpdateViewTarget._('bottomModalSheet');
  static const any = UpdateViewTarget._('any');

  static const values = [
    card,
    dialog,
    adaptiveDialog,
    materialDialog,
    cupertinoDialog,
    screen,
  ];

  static const allValues = [
    ...values,
    any,
  ];

  const UpdateViewTarget._(super._name);

  factory UpdateViewTarget.custom(String name) => UpdateViewTarget._(name);

  @override
  String get debugString => 'UpdateViewTarget($name)';
}
