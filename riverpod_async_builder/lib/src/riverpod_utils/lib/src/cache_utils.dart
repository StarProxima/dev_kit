import 'dart:async';

import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';

class FamilyKeepAliveLink implements KeepAliveLink {
  FamilyKeepAliveLink(this._close);

  final void Function() _close;

  @override
  void close() => _close();
}

/// Перечисление, для определения момента закрытия связанного [KeepAliveLink] с провайдером.
enum MomentDisposeCache {
  /// Запускаем таймер сразу
  immediately,

  /// Запускаем таймер, когда нет слушателей (отложенно)
  deferred;
}

/// Представляет закешированный провайдер.
/// Хранит [link] для кэширования провайдера и [timer] для закрытия [link]
@immutable
class _CachedProvider {
  const _CachedProvider({
    required this.link,
    required this.timer,
    this.hasCanceled = false,
    this.hasDisposed = false,
  });

  final KeepAliveLink? link;
  final Timer? timer;

  /// Был ли вызван onCancel и закрыт [link]
  final bool hasCanceled;

  /// Был ли вызван onDispose, закрыт [link] и отменен [timer]
  final bool hasDisposed;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CachedProvider &&
          runtimeType == other.runtimeType &&
          link == other.link &&
          timer == other.timer;

  @override
  int get hashCode => link.hashCode ^ timer.hashCode;

  _CachedProvider copyWith({
    KeepAliveLink? link,
    Timer? timer,
    bool? hasCanceled,
    bool? hasDisposed,
  }) {
    return _CachedProvider(
      link: link ?? this.link,
      timer: timer ?? this.timer,
      hasCanceled: hasCanceled ?? this.hasCanceled,
      hasDisposed: hasDisposed ?? this.hasDisposed,
    );
  }

  void close() => link?.close();

  void cancel() => timer?.cancel();

  void dispose() {
    close();
    cancel();
  }
}

/// Используется для кэширования family-провайдеров
class _CachedFamilyProvidersContainer {
  _CachedFamilyProvidersContainer() : cachedProviders = {};

  /// Закэшированные провайдеры
  Map<int, _CachedProvider> cachedProviders;

  /// Количество отмененных провайдеров
  int get countCanceled =>
      cachedProviders.values.where((p) => p.hasCanceled).length;

  /// Количество очищеных провайдеров
  int get countDisposed =>
      cachedProviders.values.where((p) => p.hasDisposed).length;

  /// Необходимо ли очистить все провайдеры
  bool get isAllCanceled => countCanceled == cachedProviders.length;

  /// Очищены ли все провайдеры
  bool get hasAllDisposed => countDisposed == cachedProviders.length;

  void dispose(int key) {
    if (cachedProviders.isEmpty) return;
    final provider = cachedProviders[key];
    if (provider == null) return;

    /// Помечаем провайдер, как очищенный
    cachedProviders[key] = provider.copyWith(hasDisposed: true);

    /// Если все провайдеры отменены, то сразу очищаем все провайдеры.
    /// Иначе очищаем конкретный провайдер по [key]
    if (isAllCanceled) {
      for (final p in cachedProviders.values) {
        p.dispose();
      }
      cachedProviders.updateAll(
        (key, value) => value.copyWith(hasDisposed: true),
      );
    } else {
      final provider = cachedProviders[key];
      provider?.dispose();
    }

    /// Если еще не все провайдеры очищены, то выходим,
    /// иначе очищаем [cachedProviders]
    if (!hasAllDisposed) return;
    cachedProviders.clear();
  }

  void addProvider(int key, _CachedProvider provider) {
    cachedProviders[key] = provider;
  }

  void onCancel(int key) {
    final provider = cachedProviders[key];
    if (provider == null) return;
    cachedProviders[key] = provider.copyWith(hasCanceled: true);

    /// Если все провайдеры отменены, то закрываем связанные с ними KeepAliveLink
    if (isAllCanceled) {
      for (final provider in cachedProviders.values) {
        provider.close();
      }
    }
  }

  void onResume(int key) {
    final provider = cachedProviders[key];
    if (provider == null) return;
    cachedProviders[key] = provider.copyWith(
      hasCanceled: false,
      hasDisposed: false,
    );
  }

  void closeLinkByKey(int key) {
    final provider = cachedProviders[key];
    provider?.close();
  }

  void closeLinks() {
    for (final provider in cachedProviders.values) {
      provider.close();
    }
  }

  void cancelTimerByKey(int key) {
    final provider = cachedProviders[key];
    provider?.close();
  }

  void updateProviderByKey(
    int key, {
    Timer? timer,
    KeepAliveLink? link,
  }) {
    final provider = cachedProviders[key];
    if (provider == null) {
      cachedProviders[key] = _CachedProvider(link: link, timer: timer);
    } else {
      final newProvider = provider.copyWith(
        timer: timer,
        link: link,
        hasCanceled: false,
        hasDisposed: false,
      );
      cachedProviders[key] = newProvider;
    }
  }
}

/// Используется для кэширования family-провайдеров
final Map<String, _CachedFamilyProvidersContainer> _cachedFamilyTagProviders =
    {};

/// Используется для кэширования провайдеров по тегу
final Map<String, Set<KeepAliveLink>> _cachedByTag = {};

extension RefCacheUtils on AutoDisposeRef {
  KeepAliveLink cacheFor({
    Duration duration = const Duration(minutes: 60),
    String? tag,
    int? key,
    MomentDisposeCache moment = MomentDisposeCache.immediately,
  }) {
    if (tag != null && key != null) {
      return _cacheFamilyForByTag(
        tag: tag,
        key: key,
        duration: duration,
        moment: moment,
      );
    } else if (tag != null) {
      return _cacheForByTag(tag: tag, duration: duration, moment: moment);
    }
    return _cacheFor(duration: duration, moment: moment);
  }

  KeepAliveLink _cacheFor({
    Duration duration = const Duration(minutes: 60),
    MomentDisposeCache moment = MomentDisposeCache.immediately,
  }) {
    final link = keepAlive();
    Timer? timer;
    switch (moment) {
      case MomentDisposeCache.immediately:
        timer = Timer(duration, link.close);
      case MomentDisposeCache.deferred:
        onCancel(
          () {
            timer = Timer(duration, link.close);
          },
        );
    }
    onDispose(() => timer?.cancel);
    return link;
  }

  FamilyKeepAliveLink _cacheForByTag({
    required String tag,
    Duration duration = const Duration(minutes: 60),
    MomentDisposeCache moment = MomentDisposeCache.immediately,
  }) {
    _cachedByTag[tag] ??= {};
    final link = keepAlive();
    _cachedByTag[tag]?.add(link);
    Timer? timer;
    switch (moment) {
      case MomentDisposeCache.immediately:
        timer = Timer(
          duration,
          () => _cachedByTag[tag]?.forEach((e) => e.close),
        );
      case MomentDisposeCache.deferred:
        onCancel(
          () {
            timer = Timer(
              duration,
              () => _cachedByTag[tag]?.forEach((e) => e.close),
            );
          },
        );
    }
    onDispose(() => timer?.cancel);
    return FamilyKeepAliveLink(
      () => _cachedByTag[tag]?.forEach((e) => e.close),
    );
  }

  FamilyKeepAliveLink _cacheFamilyForByTag({
    required String tag,
    required int key,
    Duration duration = const Duration(minutes: 60),
    MomentDisposeCache moment = MomentDisposeCache.immediately,
  }) {
    _cachedFamilyTagProviders[tag] ??= _CachedFamilyProvidersContainer();
    var link = keepAlive();

    void createProviderImmediately() {
      final timer = Timer(
        duration,
        () {
          _cachedFamilyTagProviders[tag]?.closeLinkByKey(key);
        },
      );
      final cachedProvider = _CachedProvider(link: link, timer: timer);
      _cachedFamilyTagProviders[tag]?.addProvider(key, cachedProvider);
    }

    void createProviderDeferred() {
      Timer? timer;
      final cachedProvider = _CachedProvider(link: link, timer: timer);
      _cachedFamilyTagProviders[tag]?.addProvider(key, cachedProvider);
      onCancel(
        () {
          /// Создаем таймер при отмене и обновляем провайдер по [key]
          timer = Timer(
            duration,
            () {
              _cachedFamilyTagProviders[tag]?.closeLinkByKey(key);
            },
          );
          _cachedFamilyTagProviders[tag]
              ?.updateProviderByKey(key, timer: timer);
        },
      );
    }

    switch (moment) {
      case MomentDisposeCache.immediately:
        createProviderImmediately();
      case MomentDisposeCache.deferred:
        createProviderDeferred();
    }

    void resume() {
      Timer? timer;

      /// Отменяем предыдущий таймер
      _cachedFamilyTagProviders[tag]?.cancelTimerByKey(key);
      if (moment == MomentDisposeCache.immediately) {
        /// Запускаем новый таймер
        timer = Timer(
          duration,
          () {
            _cachedFamilyTagProviders[tag]?.closeLinkByKey(key);
          },
        );
      }

      /// Закрываем старый [link] и создаем новый KeepAliveLink
      final newLink = keepAlive();
      _cachedFamilyTagProviders[tag]
          ?.updateProviderByKey(key, link: newLink, timer: timer);
      link.close();
      link = newLink;
      _cachedFamilyTagProviders[tag]?.onResume(key);
    }

    onCancel(() => _cachedFamilyTagProviders[tag]?.onCancel(key));
    onResume(resume);
    onDispose(() => _cachedFamilyTagProviders[tag]?.dispose(key));

    return FamilyKeepAliveLink(
      () => _cachedFamilyTagProviders[tag]?.closeLinks(),
    );
  }
}
