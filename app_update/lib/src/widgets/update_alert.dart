// ignore_for_file: prefer-named-parameters, avoid-late-keyword

import 'dart:async';

import 'package:flutter/material.dart';

import '../controller/update_contoller_base.dart';
import '../controller/update_controller.dart';
import '../localizer/models/app_update.dart';
import 'update_alert_handler.dart';

typedef OnUpdateAvailable = FutureOr<void> Function(
  BuildContext context,
  AppUpdate update,
  UpdateControllerBase controller,
);

typedef OnPickUpdateSource = FutureOr<AppUpdate?> Function(
  BuildContext context,
  List<AppUpdate> updates,
  UpdateControllerBase controller,
);

class UpdateAlert extends StatefulWidget {
  const UpdateAlert({
    super.key,
    this.controller,
    this.enabled = true,
    this.shouldCheckUpdateAfterAppResume = true,
    this.onUpdateAvailable = UpdateAlertHandler.adaptiveDialog,
    this.shouldPickUpdateWhenSourceIsNotDefined = true,
    this.onPickUpdateSource = UpdateAlertHandler.pickUpdate,
    required this.child,
  });

  final bool enabled;
  final bool shouldCheckUpdateAfterAppResume;
  final UpdateControllerBase? controller;
  final OnUpdateAvailable onUpdateAvailable;
  final bool shouldPickUpdateWhenSourceIsNotDefined;
  final OnPickUpdateSource onPickUpdateSource;

  final Widget child;

  @override
  State<UpdateAlert> createState() => _UpdateAlertState();
}

class _UpdateAlertState extends State<UpdateAlert> {
  late final AppLifecycleListener _appLifecycleListener;
  late final UpdateControllerBase _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? UpdateController();

    const throttleTime = Duration(seconds: 60);

    _controller.fetchUpdateConfig(throttleTime: throttleTime);
    _controller.fetchGlobalSourceReleases(throttleTime: throttleTime);

    _appLifecycleListener = AppLifecycleListener(
      onRestart: () {
        if (!widget.shouldCheckUpdateAfterAppResume) return;

        _controller.fetchUpdateConfig(throttleTime: throttleTime);
        _controller.fetchGlobalSourceReleases(throttleTime: throttleTime);

        _check();
      },
    );
  }

  Future<void> _check() async {
    if (!widget.enabled) return;

    final locale = Localizations.localeOf(context);

    var appUpdate = await _controller.tryFindUpdate();

    if (appUpdate == null) {
      final onPickUpdateSource = widget.onPickUpdateSource;
      if (widget.shouldPickUpdateWhenSourceIsNotDefined) return;

      final appUpdates = await _controller.findAllAvailableUpdates(locale: locale);

      if (!mounted) return;

      appUpdate = await onPickUpdateSource(context, appUpdates, _controller);
    }

    if (appUpdate == null) return;
    if (!mounted) return;

    await widget.onUpdateAvailable.call(context, appUpdate, _controller);
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
