import 'dart:math';

import 'package:flutter/material.dart';
import 'package:riverpod_async_builder/riverpod_async_builder.dart';

/// For async list use [AsyncBuilder.paginated]
class AnimatedListBuilder<Item> extends StatelessWidget {
  const AnimatedListBuilder(
    this.items, {
    super.key,
    required this.index,
    required this.animationController,
    required this.animationSettings,
    required this.data,
  });

  final Iterable<Item> items;
  final int index;

  final AnimationController? animationController;
  final ItemAnimationSettings? animationSettings;

  final Widget Function(Item item, ListData<Item> data) data;

  @override
  Widget build(BuildContext context) {
    final defaults = AsyncBuilderDefaults.of(context);

    // Добавляем ListData, чтобы можно было использовать эти данные при построении виджета
    Widget dataFn(Item item) => data(
          item,
          ListData(
            index: index,
            items: items.toList(),
            item: item,
          ),
        );

    Widget Function(Item)? animatedDataFn;

    final settings = defaults.animationSettings.apply(animationSettings);

    final controller = animationController;

    // Анимация элементов
    if (controller != null && settings.enabled) {
      animatedDataFn = (data) {
        final itemCountForDuration =
            settings.animatedItemsCount ?? items.length;
        final animatedItemsCount = settings.animatedItemsCount;

        if (controller.isDismissed) {
          controller.duration =
              settings.itemAnimationDuration * itemCountForDuration;

          if (settings.animationAutoStart) {
            Future.delayed(settings.delayBeforeStartAnimation, () {
              if (context.mounted && controller.isDismissed) {
                controller.forward();
              }
            });
          }
        }

        final isLimited =
            animatedItemsCount != null && index > animatedItemsCount;

        final limitedIndex = isLimited ? animatedItemsCount : index;

        final curConcurrentAnimationsCount = max(
          settings.concurrentAnimationsCount +
              limitedIndex * settings.itemIndexConcurrentFactor,
          0.01,
        );

        final animationBegin = limitedIndex / curConcurrentAnimationsCount;

        final begin =
            min(animationBegin, itemCountForDuration) / itemCountForDuration;
        final end = min(animationBegin + 1, itemCountForDuration) /
            itemCountForDuration;

        final animation = controller.drive(
          CurveTween(curve: Interval(begin, end)),
        );

        final child = dataFn(data);
        return SizedBox(
          key: child.key,
          child: settings.builder(child, animation),
        );
      };
    }

    final item = items.elementAt(index);

    final child = animatedDataFn?.call(item) ?? dataFn(item);
    return child;
  }
}
