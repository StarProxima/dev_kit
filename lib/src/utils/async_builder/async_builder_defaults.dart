import 'package:flutter/widgets.dart';

import '../../../dev_kit.dart';

typedef OnRetry = Future<void> Function();

/// Класс для предоставления информации об ошибке в [AsyncBuilder]
class AsyncBuilderError {
  AsyncBuilderError({
    required this.error,
    required this.stackTrace,
    this.onRetry,
  });

  final Object error;
  final StackTrace stackTrace;
  final OnRetry? onRetry;

  @override
  String toString() =>
      '$error${error is InternalError ? '' : '\n\n$stackTrace'}';
}

/// Класс для предоставления дефолтных билдеров загрзки и ошибки для [AsyncBuilder]
class AsyncBuilderDefaults {
  AsyncBuilderDefaults.init({
    required this.loading,
    required this.error,
    required this.paginationPointer,
    this.paginationLoading,
    this.paginationError,
    required this.animationSettings,
  }) {
    _instance = this;
  }

  static AsyncBuilderDefaults? _instance;

  static AsyncBuilderDefaults get instance =>
      _instance ??
      (throw Exception(
        'AsyncBuilderDefaults is not initialized. '
        'You should use AsyncBuilderDefaults.init',
      ));

  final Widget Function() loading;
  final Widget Function(AsyncBuilderError error) error;
  final ItemAnimationSettingsDefaults animationSettings;

  /// Page or offset
  final int Function(int index, int pageSize) paginationPointer;
  final Widget Function()? paginationLoading;
  final Widget Function(AsyncBuilderError error)? paginationError;
}

class ItemAnimationSettingsDefaults {
  ItemAnimationSettingsDefaults({
    required this.itemAnimationDuration,
    required this.delayBeforeStartAnimation,
    this.animatedItemsCount,
    this.itemIndexConcurrentFactor = 0,
    required this.concurrentAnimationsCount,
    required this.animationAutoStart,
    required this.shouldAnimateOnlyAfterLoading,
    required this.builder,
  });

  final Duration itemAnimationDuration;
  final Duration delayBeforeStartAnimation;
  final int? animatedItemsCount;
  final double itemIndexConcurrentFactor;
  final int concurrentAnimationsCount;
  final bool animationAutoStart;
  final bool shouldAnimateOnlyAfterLoading;
  final Widget Function(Widget child, Animation<double> animation) builder;

  ItemAnimationSettingsDefaults apply(ItemAnimationSettings? settings) {
    final defaults = ItemAnimationSettingsDefaults(
      itemAnimationDuration:
          settings?.itemAnimationDuration ?? itemAnimationDuration,
      delayBeforeStartAnimation:
          settings?.delayBeforeStartAnimation ?? delayBeforeStartAnimation,
      animatedItemsCount: settings?.animatedItemsCount ?? animatedItemsCount,
      itemIndexConcurrentFactor:
          settings?.itemIndexDurationFactor ?? itemIndexConcurrentFactor,
      concurrentAnimationsCount:
          settings?.concurrentAnimationsCount ?? concurrentAnimationsCount,
      animationAutoStart: settings?.animationAutoStart ?? animationAutoStart,
      shouldAnimateOnlyAfterLoading: settings?.shouldAnimateOnlyAfterLoading ??
          shouldAnimateOnlyAfterLoading,
      builder: settings?.builder ?? builder,
    );

    assert(
      defaults.itemIndexConcurrentFactor < 0 &&
          defaults.animatedItemsCount != null,
      'При itemIndexConcurrentFactor меньше нуля, необходимо указать количество анимируемых элементов для расчёта продолжительности всей анимации',
    );

    return defaults;
  }
}

class ItemAnimationSettings {
  /// Получает параметры по умолчанию из [ItemAnimationSettingsDefaults]
  ItemAnimationSettings({
    this.itemAnimationDuration,
    this.delayBeforeStartAnimation,
    this.animatedItemsCount,
    this.itemIndexDurationFactor,
    this.concurrentAnimationsCount,
    this.animationAutoStart,
    this.shouldAnimateOnlyAfterLoading,
    this.builder,
  });

  final Duration? itemAnimationDuration;
  final Duration? delayBeforeStartAnimation;

  /// Количество первых элементов, которые будут анимированы.
  final int? animatedItemsCount;

  /// Устанавливает изменение продолжительности анимации в зависимости от индекса элемента.
  /// Если 0.1, то чем дальше, тем быстрее будут анимароваться элементы.
  final double? itemIndexDurationFactor;

  /// Количество одновременных анимаций в списке.
  /// По умолчанию, элементы анимируются поочерёдно. Увеличение этого значения позволяет запускать
  /// несколько анимаций одновременно. Например, при значении 2, вторая анимация начнётся
  /// после завершения половины времени первой анимации.
  final int? concurrentAnimationsCount;
  final bool? animationAutoStart;
  final bool? shouldAnimateOnlyAfterLoading;

  final Widget Function(Widget child, Animation<double> animation)? builder;
}
