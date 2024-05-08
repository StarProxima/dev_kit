import 'package:flutter/widgets.dart';

class SliverBottomAlign extends StatelessWidget {
  const SliverBottomAlign({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  final Widget child;
  final EdgeInsets padding;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: crossAxisAlignment,
          children: [
            child,
          ],
        ),
      ),
    );
  }
}
