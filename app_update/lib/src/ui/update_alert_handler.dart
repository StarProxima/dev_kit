// ignore_for_file: prefer-named-parameters

import 'dart:async';

import 'package:flutter/material.dart';

import '../controller/update_contoller.dart';
import '../models/update_result/update_result.dart';
import 'widgets/update_material_dialog.dart';

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
  /// Показывает primary диалог с информацией об обновлении
  static FutureOr<void> primaryDialog(
    BuildContext context,
    UpdateController controller,
    UpdateResult result,
  ) {
    // TODO: Вызов нужного метода c виджетом, который принимает Update и UpdateController
  }

  /// Показывает адаптивный диалог (Material или Cupertino в зависимости от платформы)
  static FutureOr<void> adaptiveDialog(
    BuildContext context,
    UpdateController controller,
    UpdateResult result,
  ) {
    // TODO: Вызов нужного метода c виджетом, который принимает Update и UpdateController
  }

  /// Показывает Material Design диалог с информацией об обновлении
  static Future<void> materialDialog(
    BuildContext context,
    UpdateController controller,
    UpdateResult result,
  ) async {
    final update = result.update;
    if (update == null) return;

    await showUpdateMaterialDialog(
      context: context,
      update: update,
      controller: controller,
    );
  }

  /// Показывает Cupertino диалог с информацией об обновлении (iOS стиль)
  static FutureOr<void> cupertinoDialog(
    BuildContext context,
    UpdateController controller,
    UpdateResult result,
  ) {
    // TODO: Вызов нужного метода c виджетом, который принимает Update и UpdateController
  }

  /// Показывает bottom modal sheet с информацией об обновлении
  static FutureOr<void> bottomModalSheet(
    BuildContext context,
    UpdateController controller,
    UpdateResult result,
  ) {
    // TODO: Вызов нужного метода c виджетом, который принимает Update и UpdateController
  }

  /// Показывает полноэкранный экран с информацией об обновлении
  static FutureOr<void> screen(
    BuildContext context,
    UpdateController controller,
    UpdateResult result,
  ) {
    // TODO: Вызов нужного метода c виджетом, который принимает Update и UpdateController
  }

  /// Показывает snackbar с информацией об обновлении
  static FutureOr<void> snackbar(
    BuildContext context,
    UpdateController controller,
    UpdateResult result,
  ) {
    // TODO: Вызов нужного метода c виджетом, который принимает Update и UpdateController
  }

  /// Показывает диалог выбора обновления из списка доступных обновлений
  static FutureOr<UpdateResult?> pickUpdate(
    BuildContext context,
    List<UpdateResult> updates,
    UpdateController controller,
  ) {
    // TODO: Вызов нужного метода c виджетом, который принимает список Update и UpdateController
  }
}
