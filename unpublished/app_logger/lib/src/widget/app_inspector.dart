import 'package:app_logger/src/app_logger_helper.dart';
import 'package:flutter/material.dart';
import 'package:inspector/inspector.dart';

class AppInspector extends StatelessWidget {
  const AppInspector({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppLoggerHelper.instance.inspectorNotifier,
      // ignore: Prefer-trailing-comma
      builder: (_, enabled, __) => Inspector(
        isEnabled: enabled,
        child: child,
      ),
    );
  }
}
