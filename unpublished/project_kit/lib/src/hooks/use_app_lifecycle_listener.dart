import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// ignore: avoid-long-parameter-list
void useAppLifecycleListener({
  VoidCallback? onResume,
  VoidCallback? onInactive,
  VoidCallback? onHide,
  VoidCallback? onShow,
  VoidCallback? onPause,
  VoidCallback? onRestart,
  VoidCallback? onDetach,
}) {
  useEffect(
    () {
      final listener = AppLifecycleListener(
        onResume: onResume,
        onInactive: onInactive,
        onHide: onHide,
        onShow: onShow,
        onPause: onPause,
        onRestart: onRestart,
        onDetach: onDetach,
      );

      return listener.dispose;
    },
    const [],
  );
}
