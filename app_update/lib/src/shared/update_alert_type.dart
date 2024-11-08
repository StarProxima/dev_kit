// ignore_for_file: prefer-boolean-prefixes

import 'package:collection/collection.dart';

/// The status of the update.
enum UpdateAlertType {
  dialog,
  adaptiveDialog,
  materialDialog,
  cupertinoDialog,
  screen,
  bottomModalSheet,
  snackbar,
  card,
  custom,
  ;

  UpdateAlertTypeBase toBase() => UpdateAlertTypeBase.values.firstWhere((e) => e.type == this);
}

enum UpdateAlertTypeBase {
  dialog(UpdateAlertType.dialog),
  adaptiveDialog(UpdateAlertType.adaptiveDialog),
  materialDialog(UpdateAlertType.materialDialog),
  cupertinoDialog(UpdateAlertType.cupertinoDialog),
  screen(UpdateAlertType.screen),
  bottomModalSheet(UpdateAlertType.bottomModalSheet),
  snackbar(UpdateAlertType.snackbar),
  card(UpdateAlertType.card),
  custom(UpdateAlertType.custom),

  // Custom
  base(null),
  all(null),
  ;

  const UpdateAlertTypeBase(this.type);

  final UpdateAlertType? type;

  String get key => type?.name ?? name;

  static UpdateAlertTypeBase? parse(
    String str, {
    bool includeBase = true,
  }) =>
      values.where((e) => includeBase || e != base).firstWhereOrNull(
            (e) => str.replaceAll('_', '').toLowerCase() == e.name.toLowerCase(),
          );
}
