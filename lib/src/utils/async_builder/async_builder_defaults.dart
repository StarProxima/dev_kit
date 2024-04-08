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
    required this.itemAnimation,
    required this.paginationPointer,
    this.paginationLoading,
    this.paginationError,
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
  final ItemAnimationSettingsDefaults itemAnimation;

  /// Page or offset
  final int Function(int index, int pageSize) paginationPointer;
  final Widget Function()? paginationLoading;
  final Widget Function(AsyncBuilderError error)? paginationError;
}

class ItemAnimationSettingsDefaults {
  ItemAnimationSettingsDefaults({
    required this.itemAnimationDuration,
    required this.delayBeforeStartAnimation,
    required this.concurrentAnimationsCount,
    required this.animationAutoStart,
    required this.shouldAnimateOnlyAfterLoading,
    required this.builder,
  });

  final Duration itemAnimationDuration;
  final Duration delayBeforeStartAnimation;
  final int concurrentAnimationsCount;
  final bool animationAutoStart;
  final bool shouldAnimateOnlyAfterLoading;
  final Widget Function(Widget child, Animation<double> animation) builder;
}

class ItemAnimationSettings {
  /// Получает параметры по умолчанию из [ItemAnimationSettingsDefaults]
  ItemAnimationSettings({
    required this.animationController,
    this.itemAnimationDuration,
    this.delayBeforeStartAnimation,
    this.concurrentAnimationsCount,
    this.animationAutoStart,
    this.shouldAnimateOnlyAfterLoading,
    this.builder,
  });

  /// Для всех элементов должен передаваться один [AnimationController],
  /// управление происходит внутри [AsyncBuilder.paginated], передавать duration не нужно.
  final AnimationController animationController;
  final Duration? itemAnimationDuration;
  final Duration? delayBeforeStartAnimation;

  /// Количество одновременных анимаций в списке.
  /// По умолчанию, элементы анимируются поочерёдно. Увеличение этого значения позволяет запускать
  /// несколько анимаций одновременно. Например, при значении 2, вторая анимация начнётся
  /// после завершения половины времени первой анимации.
  final int? concurrentAnimationsCount;
  final bool? animationAutoStart;
  final bool? shouldAnimateOnlyAfterLoading;

  final Widget Function(Widget child, Animation<double> animation)? builder;
}
