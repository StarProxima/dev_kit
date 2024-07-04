part of 'cache_utils.dart';

/// Равен обычному [KeepAliveLink], но с открытым конструктором для задачи [_close] извне riverpod
class FamilyKeepAliveLink implements KeepAliveLink {
  FamilyKeepAliveLink(this._close);

  final void Function() _close;

  @override
  void close() => _close();
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

  bool get isEmpty => cachedProviders.isEmpty;

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
      closeLinks();
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
