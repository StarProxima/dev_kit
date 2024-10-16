import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_async_builder/riverpod_async_builder.dart';
import 'package:riverpod_async_builder/riverpod_utils.dart';

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
  const AsyncBuilder.sliverAdapter(
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

  /// Возвращает виджеты напрямую, сохраняя их ключи
  static Widget keyed<T>(
    AsyncValue<T> value, {
    required BuildContext context,
    bool shouldWrapInSliverAdapter = false,
    bool skipLoadingOnReload = false,
    bool skipLoadingOnRefresh = true,
    bool skipError = false,
    OnRetry? onRetry,
    Widget Function()? loading,
    Widget Function(AsyncBuilderError e)? error,
    Widget Function()? orElse,
    required Widget Function(T data) data,
  }) {
    final asyncBuilder = AsyncBuilder(
      value,
      skipLoadingOnReload: skipLoadingOnReload,
      skipLoadingOnRefresh: skipLoadingOnRefresh,
      skipError: skipError,
      onRetry: onRetry,
      loading: loading,
      error: error,
      orElse: orElse,
      data: data,
    );

    // Возращаем результат build, а не сам виджет, чтобы сохранить переданные ключи
    return asyncBuilder.build(context);
  }

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

  /// Анимирует элементы списка с разной задержкой
  static Widget? animatedItem<Item>(
    Iterable<Item> items, {
    required BuildContext context,
    required int index,
    int? indexForAnimation,
    AnimationController? animationController,
    ItemAnimationSettings? animationSettings,
    required Widget Function(Item item, ListData<Item> data) data,
  }) {
    final defaults = AsyncBuilderDefaults.of(context);

    if (index >= items.length) {
      return null;
    }

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

    // Анимация элементов
    if (animationController != null && settings.enabled) {
      animatedDataFn = (data) {
        final itemCountForDuration =
            settings.animatedItemsCount ?? items.length;
        final animatedItemsCount = settings.animatedItemsCount;

        if (animationController.isDismissed) {
          animationController.duration =
              settings.itemAnimationDuration * itemCountForDuration;

          if (settings.animationAutoStart) {
            Future.delayed(settings.delayBeforeStartAnimation, () {
              if (context.mounted && animationController.isDismissed) {
                animationController.forward();
              }
            });
          }
        }

        final indexForAnim = indexForAnimation ?? index;

        final isLimited =
            animatedItemsCount != null && indexForAnim > animatedItemsCount;

        final limitedIndex = isLimited ? animatedItemsCount : indexForAnim;

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

  /// For synk list use [AsyncBuilder.animatedItem]
  ///
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
  /// которого начнется предзагрузка следующей страницы, чтобы избежать загрузки. По умолчанию 0.
  ///
  /// [preloadPrevPageOffset] - количество элементов от начала текущего списка, при достижении
  /// которого начнется предзагрузка предыдущей страницы, чтобы избежать загрузки. По умолчанию 0.
  ///
  /// [canStop] - если `true`, то страницы будут загружаться подряд, а при загрузке скролл будет ограничен.
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
  /// управление происходит внутри [AsyncBuilder.paginatedItem], передавать duration не нужно.
  static Widget? paginatedItem<Item>(
    AsyncValue<Iterable<Item>> Function(int pointer) value, {
    required BuildContext context,
    required int index,
    required int pageSize,
    int preloadNextPageOffset = 0,
    int preloadPrevPageOffset = 0,
    bool canStop = true,
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
    required Widget Function(Item item, PaginatedListData<Item> data) data,
  }) {
    final defaults = AsyncBuilderDefaults.of(context);

    final calculatePointer =
        calculatePaginationPointer ?? defaults.paginationPointer;
    final pointer = calculatePointer(index, pageSize);

    final indexOnPage = index % pageSize;

    final asyncItems = value(pointer);

    if (asyncItems.hasValue && indexOnPage >= asyncItems.requireValue.length) {
      return canStop ? null : const SizedBox.shrink();
    }

    final asyncItem =
        asyncItems.selectData((items) => items.elementAt(indexOnPage));

    final stop = asyncItem.when(
      skipLoadingOnReload: skipLoadingOnReload,
      skipLoadingOnRefresh: skipLoadingOnRefresh,
      skipError: skipError,
      error: (_, __) => false,
      loading: () => canStop && indexOnPage != 0,
      data: (items) => false,
    );

    if (stop) return null;

    final loadingBuilder =
        loading ?? defaults.paginationLoading ?? defaults.loading;

    final errorBuilder = useSingleError && indexOnPage != 0
        ? (_) => const SizedBox.shrink()
        : error ?? defaults.paginationError ?? defaults.paginationError;

    // Preload - предзагрузка предыдущей или следующей страницы, чтобы избежать загрузок
    final prevPagePointer =
        index >= pageSize ? calculatePointer(index - pageSize, pageSize) : null;

    if (indexOnPage <= preloadPrevPageOffset &&
        index % pageSize > 1 &&
        prevPagePointer != null) {
      // Просто вызываем метод value, ui должен подписаться, элементы начать грузиться
      value(prevPagePointer);
    }

    final nextPagePointer = calculatePointer(index + pageSize, pageSize);
    if (pageSize - indexOnPage <= preloadNextPageOffset) {
      value(nextPagePointer);
    }

    // Добавляем PaginatedListData, чтобы можно было использовать эти данные при построении виджета
    Widget dataFn(Item item) => data(
          item,
          PaginatedListData(
            index: index,
            pageSize: pageSize,
            pointer: pointer,
            indexOnPage: indexOnPage,
            // Должно быть безопасно, т.к. если вызвался dataFn, то данные есть
            itemsOnPage: asyncItems.requireValue.toList(),
            itemsOnPrevPageFn: () => prevPagePointer != null
                ? value(prevPagePointer).valueOrNull?.toList()
                : null,
            itemsOnNextPageFn: () =>
                value(nextPagePointer).valueOrNull?.toList(),
            item: item,
          ),
        );

    // Анимация элементов
    Widget animatedDataFn(Item item) => animationController != null
        ? AsyncBuilder.animatedItem<Item>(
            asyncItems.requireValue,
            context: context,
            index: indexOnPage,
            // Нужно, чтобы разные страницы анимироваль подряд, а не одновременно
            indexForAnimation: index,
            animationController: animationController,
            animationSettings: animationSettings,
            data: (item, _) => dataFn(item),
            // Результат точно не null, т.к. indexOnPage < asyncItems.requireValue.length
          )!
        : dataFn(item);

    // Созздаём AsyncBuilder для нашего элемента на странице
    final asyncBuilder = AsyncBuilder(
      asyncItem,
      skipLoadingOnReload: skipLoadingOnReload,
      skipLoadingOnRefresh: skipLoadingOnRefresh,
      skipError: skipError,
      onRetry: onRetry,
      loading: loadingBuilder,
      error: errorBuilder,
      orElse: orElse,
      data: animatedDataFn,
    );

    // Возращаем результат build, а не сам виджет, чтобы сохранить переданные ключи
    return asyncBuilder.build(context);
  }

  @override
  Widget build(BuildContext context) {
    final defaults = AsyncBuilderDefaults.of(context);

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

    final widget = orElse != null
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

    return widget;
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
