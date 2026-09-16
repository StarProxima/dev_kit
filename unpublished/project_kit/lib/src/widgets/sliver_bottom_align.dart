import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Прижимает [child] к низу вьюпорта, а когда контент выше оставшегося
/// места - растёт вместе с ним и уезжает под скролл.
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
    // Не SliverFillRemaining: он спрашивает у поддерева intrinsic-высоту, а
    // LayoutBuilder на такой запрос кидает assertion - экран не строится.
    // Остаток вьюпорта считаем сами и отдаём нижней границей высоты.
    return SliverLayoutBuilder(
      builder:
          (context, constraints) => SliverToBoxAdapter(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: math.max(
                  0,
                  constraints.viewportMainAxisExtent -
                      constraints.precedingScrollExtent,
                ),
              ),
              child: Padding(
                padding: padding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: crossAxisAlignment,
                  children: [child],
                ),
              ),
            ),
          ),
    );
  }
}
