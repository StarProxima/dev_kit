// ignore_for_file: avoid-unused-instances, avoid-non-null-assertion

import 'package:flutter/material.dart';
import 'package:update_check/src/controller/update_controller.dart';
import 'package:update_check/src/shared/update_status.dart';
import 'package:update_check/src/widgets/update_alert.dart';
import 'package:update_check/src/widgets/update_alert_handler.dart';

void main() async {
  final controller = UpdateController(locale: Locale('en'));

  await controller.fetch();

  // ignore: unused_local_variable
  final widget = Scaffold(
    body: UpdateAlert(
      controller: controller,
      onUpdateAvailable: (context, update, controller) {
        // ignore: avoid-unsafe-collection-methods
        final releaseData = update.config.releases.first;

        // Release.localizedFromReleaseData(
        //   releaseData: releaseData,
        //   locale: update.appLocale,
        //   appName: update.appName,
        //   appVersion: update.appVersion,
        // );

        controller.skipRelease(releaseData);

        final release = update.availableRelease;

        // Skip
        controller.skipRelease(release!);

        // Later
        // controller.postponeRelease(release,);

        // Update
        controller.launchReleaseSource(release);
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

  UpdateAlert(
    onUpdateAvailable: (context, update, controller) {
      switch (update.availableRelease!.status) {
        case UpdateStatus.required:
          UpdateAlertHandler.screen(context, update, controller);

        case UpdateStatus.recommended:
          UpdateAlertHandler.adaptiveDialog(context, update, controller);

        case UpdateStatus.available:
          if (DateTime.now().difference(update.availableRelease!.dateUtc!) > const Duration(days: 7)) {
            // Show custom dialog
            return;
          }

          UpdateAlertHandler.snackbar(context, update, controller);

        default:
      }
    },
    child: const SizedBox(),
  );
}
