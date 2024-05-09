//ignore_for_file: unused_element
import 'package:flutter/material.dart';

enum AppCustomTooltipDirection {
  top,
  bottom,
  left,
  right,
}

enum AppCustomArrowPosition {
  left,
  center,
  right;
}

class AppCustomTooltip extends StatelessWidget {
  const AppCustomTooltip({
    super.key,
    required this.direction,
    required this.child,
    this.arrowPosition = AppCustomArrowPosition.center,
    this.backgroundColor,
  });

  final AppCustomTooltipDirection direction;
  final AppCustomArrowPosition arrowPosition;
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

  final AppCustomTooltipDirection direction;
  final AppCustomArrowPosition arrowPosition;
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
    final startArrowX = switch(arrowPosition) {
      AppCustomArrowPosition.left => 25.0,
      AppCustomArrowPosition.center => width / 2,
      AppCustomArrowPosition.right => width - 25,
    };
    switch (direction) {
      case AppCustomTooltipDirection.top:
        path
          ..moveTo(startArrowX - arrowBase / 2, 0)
          ..lineTo(startArrowX, -arrowLength)
          ..lineTo(startArrowX + arrowBase / 2, 0);
      case AppCustomTooltipDirection.bottom:
        path
          ..moveTo(startArrowX - arrowBase / 2, height)
          ..lineTo(startArrowX, arrowLength + height)
          ..lineTo(startArrowX + arrowBase / 2, height);
      case AppCustomTooltipDirection.left:
        path
          ..moveTo(0, height / 2 - arrowBase / 2)
          ..lineTo(-arrowLength, height / 2)
          ..lineTo(0, height / 2 + arrowBase / 2);
      case AppCustomTooltipDirection.right:
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
