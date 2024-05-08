import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_async_builder/riverpod_async_builder.dart';

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

  static final Map<int, int> _animationControllerMap = {};

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
    required BuildContext context,
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

    if (asyncValue.hasValue && indexOnPage >= asyncValue.value!.length) {
      return null;
    }

    final asyncItem =
        value(pointer).selectData((items) => items.elementAt(indexOnPage));

    final stop = asyncItem.when(
      skipLoadingOnReload: skipLoadingOnReload,
      skipLoadingOnRefresh: skipLoadingOnRefresh,
      skipError: skipError,
      error: (_, __) => false,
      loading: () => stopOnLoad && indexOnPage != 0,
      data: (items) => false,
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

    if (animationController != null && settings.enabled) {
      dataFn = (item) {
        final itemCountForDuration = settings.animatedItemsCount ?? pageSize;
        final animatedItemsCount = settings.animatedItemsCount;

        if (animationController.isDismissed) {
          animationController.duration =
              settings.itemAnimationDuration * itemCountForDuration;
          final hash = animationController.hashCode;
          _animationControllerMap[context.hashCode] = hash;

          if (settings.animationAutoStart) {
            Future.delayed(settings.delayBeforeStartAnimation, () {
              if (context.mounted &&
                  _animationControllerMap[context.hashCode] == hash) {
                animationController.forward();
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

        final animation = animationController.drive(
          CurveTween(curve: Interval(begin, end)),
        );

        final child = data(item);
        return SizedBox(
          key: child.key,
          child: settings.builder(child, animation),
        );
      };
    }

    return AsyncBuilder(
      asyncItem,
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

  static final _groupGlobalKeys = <int, GlobalKey>{};

  static Widget _groupBuilder<T>({
    bool skipLoadingOnReload = false,
    bool skipLoadingOnRefresh = true,
    bool skipError = false,
    OnRetry? onRetry,
    Widget Function()? loading,
    Widget Function(AsyncBuilderError e)? error,
    Widget Function()? orElse,
    required Widget Function(
      Widget Function<D>(AsyncValue<D> value, Widget Function(D data) data)
          asyncBuilder,
    ) builder,
  }) =>
      Builder(
        builder: (context) {
          final hashcode = context.hashCode;
          _groupGlobalKeys.putIfAbsent(hashcode, GlobalKey.new);
          final gk = _groupGlobalKeys[hashcode]!;

          return builder(
            <D>(value, data) => AsyncBuilder<D>(
              value,
              skipLoadingOnReload: skipLoadingOnReload,
              skipLoadingOnRefresh: skipLoadingOnRefresh,
              skipError: skipError,
              onRetry: onRetry,
              loading: loading != null
                  ? () => SizedBox(key: gk, child: loading())
                  : null,
              error: error,
              orElse: orElse,
              data: data,
            ),
          );
        },
      );

  static Widget group2<T1, T2>(
    AsyncValue<T1> value1,
    AsyncValue<T2> value2, {
    bool skipLoadingOnReload = false,
    bool skipLoadingOnRefresh = true,
    bool skipError = false,
    OnRetry? onRetry,
    Widget Function()? loading,
    Widget Function(AsyncBuilderError e)? error,
    Widget Function()? orElse,
    required Widget Function(T1 data1, T2 data2) data,
  }) =>
      _groupBuilder(
        skipLoadingOnReload: skipLoadingOnReload,
        skipLoadingOnRefresh: skipLoadingOnRefresh,
        skipError: skipError,
        onRetry: onRetry,
        loading: loading,
        error: error,
        orElse: orElse,
        builder: (asyncBuilder) => asyncBuilder(
          value1,
          (data1) => asyncBuilder(value2, (data2) => data(data1, data2)),
        ),
      );

  static Widget group3<T1, T2, T3>(
    AsyncValue<T1> value1,
    AsyncValue<T2> value2,
    AsyncValue<T3> value3, {
    bool skipLoadingOnReload = false,
    bool skipLoadingOnRefresh = true,
    bool skipError = false,
    OnRetry? onRetry,
    Widget Function()? loading,
    Widget Function(AsyncBuilderError e)? error,
    Widget Function()? orElse,
    required Widget Function(T1 data1, T2 data2, T3 data3) data,
  }) =>
      _groupBuilder(
        skipLoadingOnReload: skipLoadingOnReload,
        skipLoadingOnRefresh: skipLoadingOnRefresh,
        skipError: skipError,
        onRetry: onRetry,
        loading: loading,
        error: error,
        orElse: orElse,
        builder: (asyncBuilder) => asyncBuilder(
          value1,
          (data1) => asyncBuilder(
            value2,
            (data2) =>
                asyncBuilder(value3, (data3) => data(data1, data2, data3)),
          ),
        ),
      );

  static Widget group4<T1, T2, T3, T4>(
    AsyncValue<T1> value1,
    AsyncValue<T2> value2,
    AsyncValue<T3> value3,
    AsyncValue<T4> value4, {
    bool skipLoadingOnReload = false,
    bool skipLoadingOnRefresh = true,
    bool skipError = false,
    OnRetry? onRetry,
    Widget Function()? loading,
    Widget Function(AsyncBuilderError e)? error,
    Widget Function()? orElse,
    required Widget Function(T1 data1, T2 data2, T3 data3, T4 data4) data,
  }) =>
      _groupBuilder(
        skipLoadingOnReload: skipLoadingOnReload,
        skipLoadingOnRefresh: skipLoadingOnRefresh,
        skipError: skipError,
        onRetry: onRetry,
        loading: loading,
        error: error,
        orElse: orElse,
        builder: (asyncBuilder) => asyncBuilder(
          value1,
          (data1) => asyncBuilder(
            value2,
            (data2) => asyncBuilder(
              value3,
              (data3) => asyncBuilder(
                value4,
                (data4) => data(data1, data2, data3, data4),
              ),
            ),
          ),
        ),
      );

  static Widget group5<T1, T2, T3, T4, T5>(
    AsyncValue<T1> value1,
    AsyncValue<T2> value2,
    AsyncValue<T3> value3,
    AsyncValue<T4> value4,
    AsyncValue<T5> value5, {
    bool skipLoadingOnReload = false,
    bool skipLoadingOnRefresh = true,
    bool skipError = false,
    OnRetry? onRetry,
    Widget Function()? loading,
    Widget Function(AsyncBuilderError e)? error,
    Widget Function()? orElse,
    required Widget Function(T1 data1, T2 data2, T3 data3, T4 data4, T5 data5)
        data,
  }) =>
      _groupBuilder(
        skipLoadingOnReload: skipLoadingOnReload,
        skipLoadingOnRefresh: skipLoadingOnRefresh,
        skipError: skipError,
        onRetry: onRetry,
        loading: loading,
        error: error,
        orElse: orElse,
        builder: (asyncBuilder) => asyncBuilder(
          value1,
          (data1) => asyncBuilder(
            value2,
            (data2) => asyncBuilder(
              value3,
              (data3) => asyncBuilder(
                value4,
                (data4) => asyncBuilder(
                  value5,
                  (data5) => data(data1, data2, data3, data4, data5),
                ),
              ),
            ),
          ),
        ),
      );
}
