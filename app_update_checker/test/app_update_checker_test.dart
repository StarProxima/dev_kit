import 'package:app_update_checker/src/controller/update_controller.dart';

void main() {
  final controller = UpdateController(
    updateConfigProvider: null,
    onUpdate: (data) {},
  );

  controller.fetch();
}
