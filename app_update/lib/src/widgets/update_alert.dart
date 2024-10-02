// ignore_for_file: prefer-named-parameters, avoid-late-keyword

import 'dart:async';

import 'package:flutter/material.dart';

import '../controller/update_controller.dart';
import '../localizer/models/app_update.dart';
import 'update_alert_handler.dart';

typedef OnUpdateAvailable = FutureOr<void> Function(
  BuildContext context,
  AppUpdate update,
  UpdateController controller,
);

class UpdateAlert extends StatefulWidget {
  const UpdateAlert({
    super.key,
    this.enabled = true,
    this.controller,
    this.shouldCheckUpdateAfterAppResume = true,
    this.onUpdateAvailable = UpdateAlertHandler.adaptiveDialog,
    required this.child,
  });

  final bool enabled;
  final bool shouldCheckUpdateAfterAppResume;
  final UpdateController? controller;
  final OnUpdateAvailable? onUpdateAvailable;

  final Widget child;

  @override
  State<UpdateAlert> createState() => _UpdateAlertState();
}

class _UpdateAlertState extends State<UpdateAlert> {
  late final AppLifecycleListener _appLifecycleListener;
  late final UpdateController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? UpdateController(locale: Localizations.localeOf(context));

    _appLifecycleListener = AppLifecycleListener(
      onRestart: () {
        if (!widget.shouldCheckUpdateAfterAppResume) return;
        _check();
      },
    );
  }

  Future<void> _check() async {
    if (!widget.enabled) return;

    final appUpdate = await _controller.getAvailableAppUpdate();
    if (appUpdate == null) return;

    if (context.mounted) {
      // ignore: use_build_context_synchronously
      widget.onUpdateAvailable?.call(context, appUpdate, _controller);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _appLifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
