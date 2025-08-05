// ignore_for_file: prefer-named-parameters, avoid-late-keyword

import 'dart:async';

import 'package:flutter/material.dart';

import '../controller/update_contoller_base.dart';
import '../controller/update_controller.dart';
import '../finalizer/models/update_response.dart';
import '../shared/update_view_target.dart';
import 'update_alert_handler.dart';

typedef OnUpdateAvailable = FutureOr<void> Function(
  BuildContext context,
  UpdateResponse update,
  UpdateControllerBase controller,
);

class UpdateHandler extends StatefulWidget {
  const UpdateHandler.alert({
    super.key,
    this.controller,
    this.enabled = true,
    this.shouldCheckUpdateAfterAppResume = true,
    this.viewTargets = const [UpdateViewTarget.any],
    this.onUpdateResponse = UpdateAlertHandler.adaptiveDialog,
    required this.child,
  }) : builder = null;

  UpdateHandler.builder({
    super.key,
    this.controller,
    this.enabled = true,
    this.shouldCheckUpdateAfterAppResume = true,
    this.onUpdateResponse = UpdateAlertHandler.adaptiveDialog,
    UpdateViewTarget viewTarget = UpdateViewTarget.card,
    required this.builder,
    this.child,
  }) : viewTargets = [viewTarget];

  final bool enabled;
  final bool shouldCheckUpdateAfterAppResume;
  final UpdateControllerBase? controller;
  final List<UpdateViewTarget> viewTargets;
  final OnUpdateAvailable onUpdateResponse;
  final Widget Function(BuildContext context, UpdateResponse update, Widget? child)? builder;
  final Widget? child;

  @override
  State<UpdateHandler> createState() => _UpdateHandlerState();
}

class _UpdateHandlerState extends State<UpdateHandler> {
  late final AppLifecycleListener _appLifecycleListener;
  late final UpdateControllerBase _controller;

  Locale get _locale => Localizations.localeOf(context);

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? UpdateController();

    _controller.fetch(locale: _locale);

    _appLifecycleListener = AppLifecycleListener(
      onRestart: () {
        if (!widget.shouldCheckUpdateAfterAppResume) return;

        _controller.fetch(locale: _locale);

        _check();
      },
    );
  }

  Future<void> _check() async {
    if (!widget.enabled) return;

    UpdateResponse? appUpdate = await _controller.tryFindUpdate();

    if (appUpdate == null) return;
    if (!mounted) return;

    final futurOr = widget.onUpdateResponse(context, appUpdate, _controller);
    if (futurOr is Future) await futurOr;
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
