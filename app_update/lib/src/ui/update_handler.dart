import 'dart:async';

import 'package:flutter/material.dart';

import '../controller/update_contoller.dart';
import '../controller/update_controller_impl.dart';
import '../entities/update_locale.dart';
import '../models/update_result/update_result.dart';
import '../models/update_search/update_search_config.dart';
import '../models/update_status/update_status.dart';
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
  final UpdateController? controller;
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
  // ignore: prefer-correct-callback-field-name
  late final StreamSubscription<void> _onFetchSubscription;
  late final UpdateController _controller;
  late UpdateSearchConfig _searchConfig;

  late UpdateResult _updateResult = const UpdateResult(
    updateStatus: UpdateInitialStatus(),
    searchData: null,
    update: null,
  );

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
  void initState() {
    super.initState();
    _controller = widget.controller ?? UpdateControllerImpl();
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

    fetch();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final locale = UpdateLocale(_locale);

    final searchConfig = widget.searchConfig;

    if (searchConfig == null) {
      if (locale != _searchConfig.locale) {
        _searchConfig = _searchConfig.copyWith(locale: locale);
      }
    } else {
      _searchConfig = searchConfig;

      if (_searchConfig.locale == null) {
        _searchConfig = _searchConfig.copyWith(locale: locale);
      }
    }
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

// ignore: prefer-named-parameters
typedef OnUpdateResult = FutureOr<void> Function(
  BuildContext context,
  UpdateController controller,
  UpdateResult result,
);

// ignore: prefer-named-parameters
typedef UpdateWidgetBuilder = Widget Function(
  BuildContext context,
  UpdateController controller,
  UpdateResult result,
  Widget? child,
);
