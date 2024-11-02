// ignore_for_file: prefer-boolean-prefixes

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
  base(null),
  ;

  const UpdateAlertTypeBase(this.type);

  final UpdateAlertType? type;

  String get key => type?.name ?? name;
}
