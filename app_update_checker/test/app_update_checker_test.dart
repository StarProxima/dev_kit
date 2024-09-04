import 'package:app_update_checker/src/controller/update_controller.dart';
import 'package:app_update_checker/src/widgets/update_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() async {
  final controller = UpdateController(
    updateConfigProvider: null,
  );

  await controller.fetch();

  final widget = Scaffold(
    body: UpdateAlert(
      controller: controller,
      onUpdateAvailable: (update) {
        final release = update.release;

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
}
