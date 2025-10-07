// ignore_for_file: prefer-static-class

import 'package:flutter/material.dart';

import '../../controller/update_contoller.dart';
import '../../models/release/update.dart';

/// Показывает Material Design диалог с информацией об обновлении
///
/// Использует стандартный [AlertDialog] с адаптацией под доступные действия
/// (обновить, пропустить, отложить) в зависимости от настроек обновления.
///
/// При закрытии диалога через barrier или кнопку "Назад" (если `canPostpone` = true),
/// автоматически вызывается [UpdateController.postponeUpdate].
Future<void> showUpdateMaterialDialog({
  required BuildContext context,
  required Update update,
  required UpdateController controller,
}) async {
  final wasActionTaken = await showDialog<bool>(
    context: context,
    barrierDismissible: update.settings.canClose,
    builder: (context) => UpdateMaterialDialog(
      update: update,
      controller: controller,
    ),
  );

  // Если диалог закрыт без явного действия (wasActionTaken == null) и можно отложить
  if (wasActionTaken == null && update.settings.canPostpone) {
    await controller.postponeUpdate(update);
  }
}

/// Material Design диалог для отображения информации об обновлении
class UpdateMaterialDialog extends StatelessWidget {
  const UpdateMaterialDialog({
    super.key,
    required this.update,
    required this.controller,
  });

  final Update update;
  final UpdateController controller;

  @override
  Widget build(BuildContext context) {
    final content = update.content;
    final settings = update.settings;

    return PopScope(
      canPop: settings.canClose,
      child: AlertDialog(
        title: Text(content.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(content.description),
              if (content.releaseNotes case final releaseNotes?) ...[
                const SizedBox(height: 16),
                Text(
                  content.releaseNotesTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Text(releaseNotes),
              ],
            ],
          ),
        ),
        actions: [
          if (settings.canSkip)
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(true);
                await controller.skipUpdate(update);
              },
              child: Text(content.skipButton),
            ),
          if (settings.canPostpone)
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(true);
                await controller.postponeUpdate(update);
              },
              child: Text(content.postponeButton),
            ),
          FilledButton(
            onPressed: () async {
              await controller.launchUpdateUrl(update);
            },
            child: Text(content.updateButton),
          ),
        ],
      ),
    );
  }
}
