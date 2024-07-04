import 'dart:async';

import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';

part 'cache_utils_source.dart';

/// Перечисление, для определения момента запуска таймера для закрытия связанного [KeepAliveLink] с провайдером.
enum StartCacheTimer {
  /// Запускаем таймер сразу
  immediately,

  /// Запускаем таймер, когда нет слушателей (отложенно)
  afterCancel;
}

extension RefCacheUtils on AutoDisposeRef {
  KeepAliveLink cacheFor(
    Duration duration, {
    String? tag,
    int? key,
    StartCacheTimer start = StartCacheTimer.immediately,
  }) {
    if (tag != null && key != null) {
      return _cacheFamilyForByTag(
        duration,
        tag: tag,
        key: key,
        start: start,
      );
    } else if (tag != null) {
      return _cacheForByTag(duration, tag: tag, start: start);
    }
    return _cacheFor(duration, start: start);
  }

  KeepAliveLink _cacheFor(
    Duration duration, {
    StartCacheTimer start = StartCacheTimer.immediately,
  }) {
    final link = keepAlive();
    Timer? timer;
    switch (start) {
      case StartCacheTimer.immediately:
        timer = Timer(duration, link.close);
      case StartCacheTimer.afterCancel:
        onCancel(
          () {
            timer = Timer(duration, link.close);
          },
        );
    }
    onDispose(() => timer?.cancel);
    return link;
  }

  FamilyKeepAliveLink _cacheForByTag(
    Duration duration, {
    required String tag,
    StartCacheTimer start = StartCacheTimer.immediately,
  }) {
    _cachedByTag[tag] ??= {};
    final link = keepAlive();
    _cachedByTag[tag]?.add(link);
    Timer? timer;
    if (duration != Duration.zero) {
      switch (start) {
        case StartCacheTimer.immediately:
          timer = Timer(
            duration,
            () => _cachedByTag[tag]?.forEach((e) => e.close()),
          );
        case StartCacheTimer.afterCancel:
          onCancel(
            () {
              timer = Timer(
                duration,
                () => _cachedByTag[tag]?.forEach((e) => e.close()),
              );
            },
          );
      }
    }
    onCancel(
      () {
        final isDurationEqZero = duration == Duration.zero;
        final isNotTimerActive =
            !(timer?.isActive ?? false) && start != StartCacheTimer.afterCancel;
        if (isDurationEqZero || isNotTimerActive) {
          _cachedByTag[tag]?.forEach((e) => e.close());
        }
      },
    );
    onDispose(() => timer?.cancel());

    return FamilyKeepAliveLink(
      () => _cachedByTag[tag]?.forEach((e) => e.close()),
    );
  }

  FamilyKeepAliveLink _cacheFamilyForByTag(
    Duration duration, {
    required String tag,
    required int key,
    StartCacheTimer start = StartCacheTimer.immediately,
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

    if (duration != Duration.zero) {
      switch (start) {
        case StartCacheTimer.immediately:
          createProviderImmediately();
        case StartCacheTimer.afterCancel:
          createProviderDeferred();
      }
    } else {
      final cachedProvider = _CachedProvider(link: link, timer: null);
      _cachedFamilyTagProviders[tag]?.addProvider(key, cachedProvider);
    }

    void resume() {
      if (duration == Duration.zero) {
        _cachedFamilyTagProviders[tag]?.onResume(key);
        return;
      }

      Timer? timer;

      /// Отменяем предыдущий таймер
      _cachedFamilyTagProviders[tag]?.cancelTimerByKey(key);
      if (start == StartCacheTimer.immediately) {
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
    onDispose(() {
      _cachedFamilyTagProviders[tag]?.dispose(key);
      if (_cachedFamilyTagProviders[tag]?.isEmpty ?? false) {
        _cachedFamilyTagProviders.remove(tag);
      }
    });

    return FamilyKeepAliveLink(
      () => _cachedFamilyTagProviders.remove(tag)?.closeLinks(),
    );
  }
}

/// Используется для кэширования family-провайдеров
final Map<String, _CachedFamilyProvidersContainer> _cachedFamilyTagProviders =
    {};

/// Используется для кэширования провайдеров по тегу
final Map<String, Set<KeepAliveLink>> _cachedByTag = {};
