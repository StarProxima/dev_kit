import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../dev_kit.dart';
import '../../internal/logger/dev_kit_logger.dart';

/// {@template AsyncBuilder}
/// Виджет для упрощения работы с асинхронными данными.
///
/// Предоставляет билдеры по умолчанию для обработки состояний загрузки и обработки ошибок.
/// {@endtemplate}
class AsyncBuilder<T> extends StatelessWidget {
  /// {@macro AsyncBuilder}
  const AsyncBuilder(
    this.value, {
    super.key,
    this.skipLoadingOnReload = false,
    this.skipLoadingOnRefresh = true,
    this.skipError = false,
    this.onRetry,
    this.loading,
    this.error,
    this.orElse,
    required this.data,
  }) : shouldWrapInSliverAdapter = false;

  /// Обёртывает [error], [loading] и [orElse] в [SliverToBoxAdapter]
  const AsyncBuilder.sliver(
    this.value, {
    super.key,
    this.skipLoadingOnReload = false,
    this.skipLoadingOnRefresh = true,
    this.skipError = false,
    this.onRetry,
    this.loading,
    this.error,
    this.orElse,
    required this.data,
  }) : shouldWrapInSliverAdapter = true;

  final AsyncValue<T> value;
  final bool shouldWrapInSliverAdapter;

  final bool skipLoadingOnReload;
  final bool skipLoadingOnRefresh;
  final bool skipError;
  final OnRetry? onRetry;

  final Widget Function()? loading;
  final Widget Function(AsyncBuilderError e)? error;
  final Widget Function()? orElse;
  final Widget Function(T data) data;

  // static final Map<int, int> _map = {};

  /// Функция для организации пагинации списков с дополнительным функционалом.
  ///
  /// Этот метод помогает управлять загрузкой данных с пагинацией, предоставляя
  /// удобный интерфейс для отображения загруженных элементов, обработки состояний
  /// загрузки и ошибок, а также предварительной загрузки данных для следующих страниц.
  /// Он обеспечивает гибкое и мощное средство для реализации пагинации с возможностью
  /// настройки различных аспектов отображения и обработки данных.
  ///
  /// [value] - функция, которая принимает указатель страницы/смещения и возвращает
  /// `AsyncValue` с итерируемым списком элементов.
  ///
  /// [index] - абсолютный индекс элемента.
  ///
  /// [pageSize] - размер страницы.
  ///
  /// [preloadNextPageOffset] - количество элементов от конца текущего списка, при достижении
  /// которого начнется предзагрузка следующей страницы. По умолчанию равно 0.
  ///
  /// [preloadPrevPageOffset] - количество элементов от начала текущего списка, при достижении
  /// которого начнется предзагрузка предыдущей страницы. По умолчанию равно 0.
  ///
  /// [stopOnLoad] - если `true`, то страницы будут загружаться подряд, а при загрузке скролл будет ограничен.
  /// По умолчанию равно `true`.
  ///
  /// [useSingleError] - если `true`, при возникновении ошибки будет отображаться только первый элемент,
  /// а для остальных скрыты, загрузка при это не прерывается. По умолчанию равно `true`.
  ///
  /// [calculatePaginationPointer] - функция для вычисления указателя пагинации (например, номера страницы
  /// или смещения) на основе текущего индекса и размера страницы. Если не предоставлена, используется
  /// стандартная логика вычисления.
  ///
  /// [onRetry] - функция обратного вызова, вызываемая при попытке повторного выполнения операции
  /// после возникновения ошибки.
  ///
  /// [animationController] - Для отложенной анимации элементов должен передаваться один [AnimationController],
  /// управление происходит внутри [AsyncBuilder.paginated], передавать duration не нужно.
  static AsyncBuilder<Item>? paginated<Item>(
    AsyncValue<Iterable<Item>> Function(int pointer) value, {
    BuildContext? context,
    required int index,
    required int pageSize,
    int preloadNextPageOffset = 0,
    int preloadPrevPageOffset = 0,
    bool stopOnLoad = true,
    bool useSingleError = true,
    int Function(int index, int pageSize)? calculatePaginationPointer,
    bool skipLoadingOnReload = false,
    bool skipLoadingOnRefresh = true,
    bool skipError = false,
    OnRetry? onRetry,
    Widget Function()? loading,
    Widget Function(AsyncBuilderError e)? error,
    Widget Function()? orElse,
    AnimationController? animationController,
    ItemAnimationSettings? animationSettings,
    required Widget Function(Item item) data,
  }) {
    final defaults = AsyncBuilderDefaults.instance;

    final calculatePointer =
        calculatePaginationPointer ?? defaults.paginationPointer;
    final pointer = calculatePointer(index, pageSize);
    final indexOnPage = index % pageSize;
    final asyncValue = value(pointer);

    final stop = asyncValue.when(
      skipLoadingOnReload: skipLoadingOnReload,
      skipLoadingOnRefresh: skipLoadingOnRefresh,
      skipError: skipError,
      error: (_, __) => false,
      loading: () => stopOnLoad && indexOnPage != 0,
      data: (items) => indexOnPage >= items.length,
    );

    if (stop) return null;

    final loadingBuilder =
        loading ?? defaults.paginationLoading ?? defaults.loading;

    final errorBuilder = useSingleError && indexOnPage != 0
        ? (_) => const SizedBox.shrink()
        : error ?? defaults.paginationError ?? defaults.paginationError;

    if (pageSize - indexOnPage <= preloadNextPageOffset) {
      value(calculatePointer(index + pageSize, pageSize));
    }
    if (indexOnPage <= preloadPrevPageOffset && index % pageSize > 1) {
      value(calculatePointer(index - pageSize, pageSize));
    }

    var dataFn = data;
    final settings = defaults.animationSettings.apply(animationSettings);

    if (animationController != null && !animationController.isCompleted) {
      dataFn = (item) {
        final itemCountForDuration = settings.animatedItemsCount ?? pageSize;
        final animatedItemsCount = settings.animatedItemsCount;

        if (animationController.isDismissed) {
          animationController.duration =
              settings.itemAnimationDuration * itemCountForDuration;

          if (settings.animationAutoStart) {
            Future.delayed(settings.delayBeforeStartAnimation, () {
              if (context?.mounted ?? true) animationController.forward();
            });
          }
        }

        final limitedIndex =
            animatedItemsCount != null && index > animatedItemsCount
                ? animatedItemsCount
                : index;

        final curConcurrentAnimationsCount = max(
          settings.concurrentAnimationsCount +
              limitedIndex * settings.itemIndexConcurrentFactor,
          0.01,
        );

        final animationBegin = limitedIndex / curConcurrentAnimationsCount;

        if (animationController.value >
            1 / curConcurrentAnimationsCount +
                (1 / itemCountForDuration) * 0.5) {
          logger.debug('animationController Complete');
          Future(() => animationController.value = 1);
        }

        final begin =
            min(animationBegin, itemCountForDuration) / itemCountForDuration;
        final end = min(animationBegin + 1, itemCountForDuration) /
            itemCountForDuration;

        final animation = animationController.drive(
          CurveTween(curve: Interval(begin, end)),
        );

        return settings.builder(data(item), animation);
      };
    }

    return AsyncBuilder(
      asyncValue.whenData((items) => items.elementAt(indexOnPage)),
      skipLoadingOnReload: skipLoadingOnReload,
      skipLoadingOnRefresh: skipLoadingOnRefresh,
      skipError: skipError,
      onRetry: onRetry,
      loading: loadingBuilder,
      error: errorBuilder,
      orElse: orElse,
      data: dataFn,
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaults = AsyncBuilderDefaults.instance;

    Widget loadingBuilder() {
      final child = loading?.call() ?? defaults.loading();
      return shouldWrapInSliverAdapter
          ? SliverToBoxAdapter(child: child)
          : child;
    }

    Widget errorBuilder(e, s) {
      final err = AsyncBuilderError(
        error: e,
        stackTrace: s,
        onRetry: onRetry,
      );

      final child = error?.call(err) ?? defaults.error(err);
      return shouldWrapInSliverAdapter
          ? SliverToBoxAdapter(child: child)
          : child;
    }

    return orElse != null
        ? value.maybeWhen(
            skipLoadingOnReload: skipLoadingOnReload,
            skipLoadingOnRefresh: skipLoadingOnRefresh,
            skipError: skipError,
            error: error != null ? errorBuilder : null,
            loading: loading != null ? loadingBuilder : null,
            orElse: () {
              final child = orElse!();
              return shouldWrapInSliverAdapter
                  ? SliverToBoxAdapter(child: child)
                  : child;
            },
            data: data,
          )
        : value.when(
            skipLoadingOnReload: skipLoadingOnReload,
            skipLoadingOnRefresh: skipLoadingOnRefresh,
            skipError: skipError,
            error: errorBuilder,
            loading: loadingBuilder,
            data: data,
          );
  }
}
