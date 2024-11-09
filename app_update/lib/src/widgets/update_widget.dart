// ignore_for_file: prefer-named-parameters

import 'package:flutter/material.dart';

import '../controller/update_contoller_base.dart';
import '../finalizer/models/app_update.dart';
import 'update_widget_builder.dart';

// ignore: avoid-unnecessary-stateful-widgets
class UpdateWidget extends StatefulWidget {
  const UpdateWidget({super.key, this.builder = UpdateWidgetBuilder.card});

  final Widget Function(BuildContext context, AppUpdate update, UpdateControllerBase controller) builder;

  @override
  State<UpdateWidget> createState() => _UpdateWidgetState();
}

class _UpdateWidgetState extends State<UpdateWidget> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
