import 'package:flutter/widgets.dart';

import '../controller/update_contoller_base.dart';
import '../controller/update_controller.dart';

class UpdateAlert extends StatefulWidget {
  const UpdateAlert({
    super.key,
    this.enabled = true,
    this.shouldCheckUpdateAfterAppResume = true,
    required this.controller,
    this.onUpdateAvailable,
    required this.child,
  });

  final bool enabled;
  final bool shouldCheckUpdateAfterAppResume;
  final UpdateController controller;
  final OnUpdateAvailable? onUpdateAvailable;

  final Widget child;

  @override
  State<UpdateAlert> createState() => _UpdateAlertState();
}

class _UpdateAlertState extends State<UpdateAlert> {
  // ignore: avoid-late-keyword
  late final AppLifecycleListener _appLifecycleListener;

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
    await widget.controller.fetch();
    final updateData = await widget.controller.findAvailableUpdate();

    if (updateData == null) return;

    widget.onUpdateAvailable?.call(updateData);
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
