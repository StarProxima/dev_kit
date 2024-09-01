import 'package:app_update_checker/src/controller/update_controller.dart';
import 'package:flutter/cupertino.dart';

void main() {
  final controller = UpdateController(
    updateConfigProvider: null,
    onUpdate: (data) {},
  );

  controller.fetch();
}
