import 'package:update_check/src/controller/update_controller.dart';

void main() async {
  final controller = UpdateController();

  await controller.fetch();

  // final widget = Scaffold(
  //   body: UpdateAlert(
  //     controller: controller,
  //     onUpdateAvailable: (update) {
  //       final release = update.release;

  //       // Skip
  //       controller.skipRelease(release);

  //       // Later
  //       controller.postponeRelease(release);

  //       // Update
  //       controller.launchReleaseStore(release);
  //     },
  //     child: const SizedBox(),
  //   ),
  // );
}
