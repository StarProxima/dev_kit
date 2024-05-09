import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

typedef FutureVoidCallback = FutureOr<void> Function();

class AppOnboardingController {
  AppOnboardingController();

  int currentIndex = 0;
  final Map<int, OverlayPortalController> _overlayControllers = {};
  final Map<int, FutureVoidCallback?> _onEntryShows = {};
  final Map<int, FutureVoidCallback?> _onEntryHide = {};
  FutureVoidCallback? _onStart;
  FutureVoidCallback? _onDone;
  FutureVoidCallback? _onAutoHiddenStart;
  FutureVoidCallback? _onAutoHiddenDone;
  int? firstAutoHiddenIndex;
  int countAutoHidden = 0;

  Future<void> start({int startIndex = 0}) async {
    currentIndex = startIndex;
    for (var controller in _overlayControllers.values) {
      if (controller.isShowing) controller.hide();
    }
    await _onStart?.call();
    show();
  }

  void next() {
    if (currentIndex < _overlayControllers.length) {
      currentIndex++;
    }
  }

  void prev() {
    if (currentIndex > 0) {
      currentIndex--;
    }
  }

  Future<void> show() async {
    await _onEntryShows[currentIndex]?.call();
    _overlayControllers[currentIndex]?.show();
  }

  Future<void> startAutoHidden() async {
    await hide();
    if (firstAutoHiddenIndex == null) return;
    await _onAutoHiddenStart?.call();
    currentIndex = firstAutoHiddenIndex!;
    await show();
  }

  Future<void> hide({bool isDone = false}) async {
    await _onEntryHide[currentIndex]?.call();
    _overlayControllers[currentIndex]?.hide();
    if (isDone || currentIndex == ((firstAutoHiddenIndex ?? 0) - 1)) {
      await _onDone?.call();
    }
    if (currentIndex == _overlayControllers.length - 1) {
      await _onAutoHiddenDone?.call();
    }
  }

  Future<void> cancel({
    bool isDone = false,
    bool isAutoHiddenDone = false,
  }) async {
    if (isDone) {
      _onDone?.call();
    }
    if (isAutoHiddenDone) {
      _onAutoHiddenDone?.call();
    }
    for (final controller in _overlayControllers.values) {
      controller.hide();
    }
  }

  Future<void> showNext() async {
    await hide();
    next();
    if (currentIndex < _overlayControllers.length) await show();
  }

  Future<void> showPrev() async {
    await hide();
    prev();
    await show();
  }

  void addEntry(int index) {
    _overlayControllers[index] =
        OverlayPortalController(debugLabel: 'AppOnboardingController  $index');
  }

  void _registerOnEntryShows(int index, FutureVoidCallback? callback) {
    _onEntryShows[index] = callback;
  }

  void _registerOnEntryHide(int index, FutureVoidCallback? callback) {
    _onEntryHide[index] = callback;
  }

  OverlayPortalController get(int index) {
    final controller = _overlayControllers[index];
    if (controller == null) {
      throw Exception('No OverlayPortalController by $index');
    }
    return controller;
  }

  void dispose() {
    _overlayControllers.clear();
  }
}

class AppOnboarding extends StatefulWidget {
  const AppOnboarding({
    super.key,
    required this.child,
    required this.controller,
    this.onDone,
    this.onStart,
    this.onAutoHiddenStart,
    this.onAutoHiddenDone,
  });

  final AppOnboardingController controller;
  final Widget child;
  final FutureVoidCallback? onDone;
  final FutureVoidCallback? onStart;
  final FutureVoidCallback? onAutoHiddenStart;
  final FutureVoidCallback? onAutoHiddenDone;

  static AppOnboardingState of(BuildContext context) {
    final state = context.findAncestorStateOfType<AppOnboardingState>();
    if (state == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary(
          'AppOnboarding.of() called with a context that does not contain a AppOnboarding.',
        ),
        ErrorDescription(
          'No AppOnboarding ancestor could be found starting from the context that was passed to AppOnboarding.of(). '
          'This usually happens when the context provided is from the same StatefulWidget as that '
          'whose build function actually creates the AppOnboarding widget being sought.',
        ),
        context.describeElement('The context used was'),
      ]);
    }
    return state;
  }

  @override
  State<AppOnboarding> createState() => AppOnboardingState();
}

class AppOnboardingState extends State<AppOnboarding> {
  int get stepsLength => widget.controller._overlayControllers.length;

  int get currentIndex => widget.controller.currentIndex;

  int get countAutoHidden => widget.controller.countAutoHidden;

  int? get firstAutoHiddenIndex => widget.controller.firstAutoHiddenIndex;

  OverlayPortalController getOverlayController(int index) {
    return widget.controller.get(index);
  }

  void show() {
    widget.controller.show();
  }

  void startAutoHidden() {
    widget.controller.startAutoHidden();
  }

  void hide({bool isDone = false}) {
    widget.controller.hide();
  }

  void next() {
    widget.controller.next();
  }

  void prev() {
    widget.controller.prev();
  }

  void add(int index) {
    widget.controller.addEntry(index);
  }

  void addAutoHidden(int index) {
    widget.controller.addEntry(index);
    widget.controller.firstAutoHiddenIndex ??= index;
    widget.controller.firstAutoHiddenIndex =
        min(widget.controller.firstAutoHiddenIndex!, index);
    widget.controller.countAutoHidden++;
  }

  void start({int startIndex = 0}) {
    widget.controller.start(startIndex: startIndex);
  }

  void showNext() {
    widget.controller.showNext();
  }

  void showPrev() {
    widget.controller.showPrev();
  }

  void cancel({
    bool isDone = false,
    bool isAutoHiddenDone = false,
  }) {
    widget.controller.cancel(
      isDone: isDone,
      isAutoHiddenDone: isAutoHiddenDone,
    );
  }

  void registerOnEntryShow(int index, FutureVoidCallback? callback) {
    widget.controller._registerOnEntryShows(index, callback);
  }

  void registerOnEntryHide(int index, FutureVoidCallback? callback) {
    widget.controller._registerOnEntryHide(index, callback);
  }

  @override
  void initState() {
    super.initState();
    widget.controller
      .._onStart = widget.onStart
      .._onDone = widget.onDone
      .._onAutoHiddenDone = widget.onAutoHiddenDone
      .._onAutoHiddenStart = widget.onAutoHiddenStart;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
