import 'package:flutter/material.dart';
import 'package:update_check/src/controller/update_controller.dart';
import 'package:update_check/src/widgets/update_alert.dart';

void main() async {
  final controller = UpdateController();

  await controller.fetch();

  // ignore: unused_local_variable
  final widget = Scaffold(
    body: UpdateAlert.custom(
      controller: controller,
      onUpdateAvailable: (update, controller) {
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
        controller.skipRelease(release);

        // Later
        controller.postponeRelease(release);

        // Update
        controller.launchReleaseStore(release);
      },
      child: const SizedBox(),
    ),
  );

  // ignore: unused_local_variable, avoid-similar-names
  final widget2 = Scaffold(
    body: UpdateAlert(
      controller: controller,
      // ignore: avoid_redundant_argument_values
      type: UpdateAlertType.adaptiveDialog,
      child: const SizedBox(),
    ),
  );
}
