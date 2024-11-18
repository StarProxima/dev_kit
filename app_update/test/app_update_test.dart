// ignore_for_file: avoid-unused-instances, avoid-non-null-assertion, avoid-missing-enum-constant-in-map

import 'package:app_update/src/controller/update_controller.dart';
import 'package:app_update/src/linker/models/release_settings_data.dart';
import 'package:app_update/src/linker/models/update_settings_data_container.dart';
import 'package:app_update/src/shared/update_alert_type.dart';
import 'package:app_update/src/shared/version_status.dart';
import 'package:app_update/src/widgets/update_alert.dart';
import 'package:app_update/src/widgets/update_alert_handler.dart';
import 'package:flutter/material.dart';

void main() async {
  final controller = UpdateController(
    updateSettings: const UpdateSettingsDataContainer({
      UpdateAlertTypeBase.base: {
        VersionStatusBase.base: UpdateSettingsData(),
      },
    }),
  );

  await controller.fetchUpdateConfig();

  // ignore: unused_local_variable
  final widget = Scaffold(
    body: UpdateAlert(
      controller: controller,
      onUpdateAvailable: (context, update, controller) {
        // ignore: avoid-unsafe-collection-methods
        final releaseData = update.config.releases.first;

        // ignore: unused_local_variable
        final settings = update.release.settings.getBy(
          type: UpdateAlertType.dialog,
          status: update.appVersionStatus,
        );

        // final texts = update.release.texts.getBy(
        //   type: UpdateAlertType.dialog,
        //   status: update.appVersionStatus,
        //   locale:  const Locale('en'),
        // );

        // final settings = update.release.settings.getBy(
        //   type: UpdateAlertType.adaptiveDialog,
        //   status: VersionStatus.updatable,
        // );

        // final text = settings.translations.byLocale(const Locale('en'));

        // Release.localizedFromReleaseData(
        //   releaseData: releaseData,
        //   locale: update.appLocale,
        //   appName: update.appName,
        //   appVersion: update.appVersion,
        // );

        controller.skipRelease(releaseData);

        final release = update.release;

        // Skip
        controller.skipRelease(release);

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
      switch (update.appVersionStatus) {
        case VersionStatus.unsupported:
          UpdateAlertHandler.screen(context, update, controller);

        case VersionStatus.deprecated:
          UpdateAlertHandler.adaptiveDialog(context, update, controller);

        case VersionStatus.updatable:
          if (DateTime.now().difference(update.release.date!) > const Duration(days: 7)) {
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
