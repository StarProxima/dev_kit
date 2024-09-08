import 'dart:async';

import 'package:flutter/material.dart';

import '../builder/models/app_update.dart';
import '../controller/update_controller.dart';
import 'update_alert_type.dart';

// ignore: prefer-named-parameters
typedef OnUpdateAvailable = FutureOr<void> Function(AppUpdate update, UpdateController controller);

// Отдельные виджеты, принимающие AppUpdate и UpdateController?
// enum UpdateAlertType {
//   adaptiveDialog,
//   // materialDialog,
//   // cupertinoDialog,
//   // bottomModalSheet,
//   // screen,
//   // snackbar,
// }

class UpdateAlert extends StatefulWidget {
  const UpdateAlert({
    super.key,
    this.enabled = true,
    this.controller,
    UpdateAlertType this.type = const UpdateAlertType.adaptiveDialog(),
    this.shouldCheckUpdateAfterAppResume = true,
    required this.child,
  }) : onUpdateAvailable = null;

  const UpdateAlert.custom({
    super.key,
    this.enabled = true,
    this.controller,
    this.shouldCheckUpdateAfterAppResume = true,
    this.onUpdateAvailable,
    required this.child,
  }) : type = null;

  final bool enabled;
  final bool shouldCheckUpdateAfterAppResume;
  final UpdateController? controller;
  final OnUpdateAvailable? onUpdateAvailable;
  final UpdateAlertType? type;
  final Widget child;

  @override
  State<UpdateAlert> createState() => _UpdateAlertState();
}

class _UpdateAlertState extends State<UpdateAlert> {
  // ignore: avoid-late-keyword
  late final AppLifecycleListener _appLifecycleListener;

  late final _controller = widget.controller ?? UpdateController();

  @override
  void initState() {
    super.initState();

    _appLifecycleListener = AppLifecycleListener(
      onRestart: () {
        if (!widget.shouldCheckUpdateAfterAppResume) return;
        _check();
      },
    );
  }

  Future<void> _check() async {
    await _controller.fetch();
    final updateData = await _controller.findAvailableUpdate();

    if (updateData == null) return;

    widget.onUpdateAvailable?.call(updateData, _controller);
  }

  @override
  void dispose() {
    _appLifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
