//ignore_for_file: unused_element
import 'package:flutter/material.dart';

enum AppOnboardingTooltipDirection {
  top,
  bottom,
  left,
  right,
}

enum AppOnboardingTooltipArrowPosition {
  left,
  center,
  right;
}

class AppOnboardingTooltip extends StatelessWidget {
  const AppOnboardingTooltip({
    super.key,
    required this.direction,
    required this.child,
    this.arrowPosition = AppOnboardingTooltipArrowPosition.center,
    this.backgroundColor,
  });

  final AppOnboardingTooltipDirection direction;
  final AppOnboardingTooltipArrowPosition arrowPosition;
  final Widget child;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CustomTooltip(
        direction: direction,
        arrowPosition: arrowPosition,
        color: backgroundColor ?? Theme.of(context).primaryColor,
      ),
      child: child,
    );
  }
}

class _CustomTooltip extends CustomPainter {
  _CustomTooltip({
    required this.direction,
    required this.color,
    required this.arrowPosition,
    this.borderRadius = 10,
    this.arrowLength = 7,
    this.arrowBase = 12,
  });

  final AppOnboardingTooltipDirection direction;
  final AppOnboardingTooltipArrowPosition arrowPosition;
  final Color color;
  final double borderRadius;
  final double arrowLength;
  final double arrowBase;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final width = size.width;
    final height = size.height;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(width / 2, height / 2),
            width: width,
            height: height,
          ),
          Radius.circular(borderRadius),
        ),
      );
    final startArrowX = switch (arrowPosition) {
      AppOnboardingTooltipArrowPosition.left => 25.0,
      AppOnboardingTooltipArrowPosition.center => width / 2,
      AppOnboardingTooltipArrowPosition.right => width - 25,
    };
    switch (direction) {
      case AppOnboardingTooltipDirection.top:
        path
          ..moveTo(startArrowX - arrowBase / 2, 0)
          ..lineTo(startArrowX, -arrowLength)
          ..lineTo(startArrowX + arrowBase / 2, 0);
      case AppOnboardingTooltipDirection.bottom:
        path
          ..moveTo(startArrowX - arrowBase / 2, height)
          ..lineTo(startArrowX, arrowLength + height)
          ..lineTo(startArrowX + arrowBase / 2, height);
      case AppOnboardingTooltipDirection.left:
        path
          ..moveTo(0, height / 2 - arrowBase / 2)
          ..lineTo(-arrowLength, height / 2)
          ..lineTo(0, height / 2 + arrowBase / 2);
      case AppOnboardingTooltipDirection.right:
        path
          ..moveTo(width, height / 2 - arrowBase / 2)
          ..lineTo(width + arrowLength, height / 2)
          ..lineTo(width, height / 2 + arrowBase / 2);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CustomTooltip oldDelegate) =>
      direction != oldDelegate.direction ||
      color != oldDelegate.color ||
      borderRadius != oldDelegate.borderRadius ||
      arrowLength != oldDelegate.arrowLength ||
      arrowBase != oldDelegate.arrowBase;
}
