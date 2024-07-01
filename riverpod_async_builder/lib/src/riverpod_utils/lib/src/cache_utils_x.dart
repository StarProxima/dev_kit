part of 'cache_utils.dart';

/// Используется для кэширования family-провайдеров
final Map<String, _CachedFamilyProvidersContainer> _cachedFamilyTagProviders =
    {};

/// Используется для кэширования провайдеров по тегу
final Map<String, Set<KeepAliveLink>> _cachedByTag = {};

extension RefCacheUtils on AutoDisposeRef {
  KeepAliveLink cacheFor(
    Duration duration, {
    String? tag,
    int? key,
    MomentDisposeCache moment = MomentDisposeCache.immediately,
  }) {
    if (tag != null && key != null) {
      return _cacheFamilyForByTag(
        duration,
        tag: tag,
        key: key,
        moment: moment,
      );
    } else if (tag != null) {
      return _cacheForByTag(duration, tag: tag, moment: moment);
    }
    return _cacheFor(duration, moment: moment);
  }

  KeepAliveLink _cacheFor(
    Duration duration, {
    MomentDisposeCache moment = MomentDisposeCache.immediately,
  }) {
    final link = keepAlive();
    Timer? timer;
    switch (moment) {
      case MomentDisposeCache.immediately:
        timer = Timer(duration, link.close);
      case MomentDisposeCache.deffered:
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
      case MomentDisposeCache.deffered:
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

  FamilyKeepAliveLink _cacheFamilyForByTag(
    Duration duration, {
    required String tag,
    required int key,
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
      case MomentDisposeCache.deffered:
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
