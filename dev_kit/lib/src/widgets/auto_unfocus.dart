import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AutoUnfocus extends StatelessWidget {
  const AutoUnfocus({
    required this.child,
    super.key,
    this.enabled = true,
  });

  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled
          ? () {
              final currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
            }
          : null,
      child: child,
    );
  }
}
