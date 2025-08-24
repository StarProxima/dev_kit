// ignore_for_file: avoid-unused-instances, avoid-non-null-assertion, avoid-missing-enum-constant-in-map

import 'package:app_update/src/controller/update_controller.dart';
import 'package:app_update/src/shared/models/update_search/update_search_config.dart';
import 'package:app_update/src/shared/update_entities/update_view_target.dart';
import 'package:app_update/src/widgets/update_handler.dart';
import 'package:flutter/material.dart';

void main() async {
  final controller = UpdateController();

  await controller.fetch();

  // ignore: unused_local_variable
  final widget = Scaffold(
    body: UpdateHandler.alert(
      controller: controller,
      onUpdateResult: (context, controller, result) {
        // ignore: avoid-unsafe-collection-methods
        final update = result.update;

        if (update == null || !result.shouldShow) return;

        controller.skipUpdate(update);

        // Postpone
        controller.postponeUpdate(update);

        // Update
        controller.launchUpdateUrl(update);
      },
      child: const SizedBox(),
    ),
  );

  // ignore: unused_local_variable
  // final widget2 = Scaffold(
  //   body: UpdateAlert(
  //     controller: controller,
  //     // ignore: avoid_redundant_argument_values
  //     type: const UpdateAlertType.screen(),
  //     child: const SizedBox(),
  //   ),
  // );

  UpdateHandler.builder(
    controller: controller,
    searchConfig: const UpdateSearchConfig(
      displayTarget: UpdateViewTarget.card,
    ),
    builder: (context, controller, result, child) {
      final update = result.update;

      final finalChild = child ?? const SizedBox();

      if (update == null || !result.shouldShow) return finalChild;

      controller.skipUpdate(update);

      return Column(
        children: [
          Text(update.content.title),
          Text(update.content.description),
          if (update.content.releaseNotes case final String releaseNotes) ...[
            Text(update.content.releaseNotesTitle),
            Text(releaseNotes),
          ],
          Row(
            children: [
              if (update.settings.canSkip)
                ElevatedButton(
                  onPressed: () => controller.skipUpdate(update),
                  child: Text(update.content.skipButton),
                ),
              if (update.settings.canPostpone)
                ElevatedButton(
                  onPressed: () => controller.postponeUpdate(update),
                  child: Text(update.content.postponeButton),
                ),
              ElevatedButton(
                onPressed: () => controller.launchUpdateUrl(update),
                child: Text(update.content.updateButton),
              ),
            ],
          ),
        ],
      );
    },
    child: const SizedBox(),
  );
}
