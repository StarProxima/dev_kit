// ignore_for_file: prefer-named-parameters, avoid-late-keyword

import 'dart:async';

import 'package:flutter/material.dart';

import '../controller/update_contoller_base.dart';
import '../controller/update_controller.dart';
import '../shared/models/update_result/update_result.dart';
import '../shared/models/update_search/update_search_config.dart';
import '../shared/models/update_status/update_status.dart';
import '../shared/update_entities/update_locale.dart';
import 'update_alert_handler.dart';

class UpdateHandler extends StatefulWidget {
  const UpdateHandler.alert({
    super.key,
    this.enabled = true,
    this.controller,
    this.searchConfig,
    this.shouldCheckUpdateAfterAppResume = true,
    OnUpdateResult this.onUpdateResult = UpdateAlertHandler.adaptiveDialog,
    this.child,
  }) : builder = null;

  const UpdateHandler.builder({
    super.key,
    this.enabled = true,
    this.controller,
    this.searchConfig,
    this.shouldCheckUpdateAfterAppResume = true,
    required UpdateWidgetBuilder this.builder,
    this.child,
  }) : onUpdateResult = null;

  final bool enabled;
  final bool shouldCheckUpdateAfterAppResume;
  final UpdateControllerBase? controller;
  final UpdateSearchConfig? searchConfig;
  final OnUpdateResult? onUpdateResult;
  final UpdateWidgetBuilder? builder;
  final Widget? child;

  @override
  State<UpdateHandler> createState() => _UpdateHandlerState();
}

class _UpdateHandlerState extends State<UpdateHandler> {
  Locale get _locale => Localizations.localeOf(context);

  late final AppLifecycleListener _appLifecycleListener;
  late final StreamSubscription<void> _onFetchSubscription;
  late final UpdateControllerBase _controller;
  late UpdateSearchConfig _searchConfig;

  late UpdateResult _updateResult = const UpdateResult(
    update: null,
    searchData: null,
    updateStatus: UpdateInitialStatus(),
  );

  @override
  Future<void> initState() async {
    super.initState();
    _controller = widget.controller ?? UpdateController();
    _searchConfig = widget.searchConfig ?? const UpdateSearchConfig();

    _onFetchSubscription = _controller.onFetch.listen((_) {
      checkUpdate();
    });

    _appLifecycleListener = AppLifecycleListener(
      onRestart: () async {
        if (!widget.shouldCheckUpdateAfterAppResume) return;

        await fetch();
      },
    );

    await fetch();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final locale = UpdateLocale(_locale);

    final searchConfig = widget.searchConfig;

    if (searchConfig != null) {
      _searchConfig = searchConfig;

      if (_searchConfig.locale == null) {
        _searchConfig = _searchConfig.copyWith(locale: locale);
      }
    } else {
      if (locale != _searchConfig.locale) {
        _searchConfig = _searchConfig.copyWith(locale: locale);
      }
    }
  }

  Future<void> fetch() async {
    await _controller.fetch(_searchConfig);
  }

  void checkUpdate() {
    if (!widget.enabled) return;
    if (!mounted) return;

    final updateResult = _controller.findUpdate(_searchConfig);

    setState(() {
      _updateResult = updateResult;
    });

    widget.onUpdateResult?.call(
      context,
      _controller,
      updateResult,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _appLifecycleListener.dispose();
    _onFetchSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder?.call(context, _controller, _updateResult, widget.child) ??
      widget.child ??
      const SizedBox.shrink();
}

typedef OnUpdateResult = FutureOr<void> Function(
  BuildContext context,
  UpdateControllerBase controller,
  UpdateResult result,
);

typedef UpdateWidgetBuilder = Widget Function(
  BuildContext context,
  UpdateControllerBase controller,
  UpdateResult result,
  Widget? child,
);
