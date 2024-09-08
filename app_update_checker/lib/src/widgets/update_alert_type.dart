// Каждый класс соответствует виджеты,
sealed class UpdateAlertType {
  const UpdateAlertType();

  const factory UpdateAlertType.adaptiveDialog() = AdaptiveDialogAlertType;

  const factory UpdateAlertType.materialDialog() = MaterialDialogAlertType;

  const factory UpdateAlertType.cupertinoDialog() = CupertinoDialogAlertType;

  const factory UpdateAlertType.bottomModalSheet() = BottomModalSheetAlertType;

  const factory UpdateAlertType.screen() = ScreenAlertType;

  const factory UpdateAlertType.snackbar() = SnackbarAlertType;
}

class AdaptiveDialogAlertType extends UpdateAlertType {
  const AdaptiveDialogAlertType();
}

class MaterialDialogAlertType extends UpdateAlertType {
  const MaterialDialogAlertType();
}

class CupertinoDialogAlertType extends UpdateAlertType {
  const CupertinoDialogAlertType();
}

class BottomModalSheetAlertType extends UpdateAlertType {
  const BottomModalSheetAlertType();
}

class ScreenAlertType extends UpdateAlertType {
  const ScreenAlertType();
}

class SnackbarAlertType extends UpdateAlertType {
  const SnackbarAlertType();
}
