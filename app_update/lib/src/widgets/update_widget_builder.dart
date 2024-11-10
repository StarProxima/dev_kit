// ignore_for_file: prefer-named-parameters

import 'package:flutter/material.dart';

import '../controller/update_contoller_base.dart';
import '../finalizer/models/app_update.dart';

abstract final class UpdateWidgetBuilder {
  static Widget card(BuildContext context, AppUpdate update, UpdateControllerBase controller) {
    throw UnimplementedError();
  }
}
