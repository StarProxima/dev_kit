// ignore_for_file: prefer-named-parameters

import 'dart:async';

import 'package:flutter/material.dart';

import '../controller/update_contoller_base.dart';
import '../localizer/models/app_update.dart';

/// Нужен, чтобы можно было использовать отдельные методы в onUpdateAvailable.
///
/// Пример:
/// ```dart
///  UpdateAlert(
///    onUpdateAvailable: (context, update, controller) {
///      switch (update.availableRelease.status) {
///        case ReleaseStatus.required:
///          UpdateAlertHandler.screen(context, update, controller);
///
///        case ReleaseStatus.recommended:
///          UpdateAlertHandler.adaptiveDialog(context, update, controller);
///
///        case ReleaseStatus.active:
///          if (DateTime.now().difference(update.availableRelease.publishDateUtc ?? DateTime.now()) >
///              const Duration(days: 7)) {
///            // Show custom dialog
///            return;
///          }
///
///          UpdateAlertHandler.snackbar(context, update, controller);
///
///        default:
///      }
///    },
///    child: const SizedBox(),
///  );
/// ```
abstract final class UpdateAlertHandler {
  // Куча примеров, что вообще может быть, пока необязательно для реализации

  static FutureOr<void> primaryDialog(
    BuildContext context,
    AppUpdate update,
    UpdateControllerBase controller,
  ) {
    // TODO: Вызов нужного метода c виджетом, который принимает AppUpdate и UpdateController
  }

  static FutureOr<void> adaptiveDialog(
    BuildContext context,
    AppUpdate update,
    UpdateControllerBase controller,
  ) {
    // TODO: Вызов нужного метода c виджетом, который принимает AppUpdate и UpdateController
  }

  static FutureOr<void> materialDialog(
    BuildContext context,
    AppUpdate update,
    UpdateControllerBase controller,
  ) {
    // TODO: Вызов нужного метода c виджетом, который принимает AppUpdate и UpdateController
  }

  static FutureOr<void> cupertinoDialog(
    BuildContext context,
    AppUpdate update,
    UpdateControllerBase controller,
  ) {
    // TODO: Вызов нужного метода c виджетом, который принимает AppUpdate и UpdateController
  }

  static FutureOr<void> bottomModalSheet(
    BuildContext context,
    AppUpdate update,
    UpdateControllerBase controller,
  ) {
    // TODO: Вызов нужного метода c виджетом, который принимает AppUpdate и UpdateController
  }

  static FutureOr<void> screen(
    BuildContext context,
    AppUpdate update,
    UpdateControllerBase controller,
  ) {
    // TODO: Вызов нужного метода c виджетом, который принимает AppUpdate и UpdateController
  }

  static FutureOr<void> snackbar(
    BuildContext context,
    AppUpdate update,
    UpdateControllerBase controller,
  ) {
    // TODO: Вызов нужного метода c с виджетом, который принимает AppUpdate и UpdateController
  }

  static FutureOr<AppUpdate?> pickUpdate(
    BuildContext context,
    List<AppUpdate> updates,
    UpdateControllerBase controller,
  ) {
    // TODO: Вызов нужного метода c виджетом, который принимает AppUpdate и UpdateController
  }
}
