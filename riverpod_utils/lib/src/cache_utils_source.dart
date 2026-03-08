part of 'cache_utils.dart';

/// Равен обычному [KeepAliveLink], но с открытым конструктором для задачи [_close] извне riverpod
class FamilyKeepAliveLink implements KeepAliveLink {
  FamilyKeepAliveLink(this._close);

  final void Function() _close;

  @override
  void close() => _close();
}

/// Представляет закешированный провайдер.
/// Хранит [link] для кэширования провайдера
class _CachedProvider {
  const _CachedProvider({
    required this.link,
    this.hasCanceled = false,
  });

  final KeepAliveLink? link;

  /// Был ли вызван onCancel
  final bool hasCanceled;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CachedProvider &&
          runtimeType == other.runtimeType &&
          link == other.link;

  @override
  int get hashCode => link.hashCode;

  _CachedProvider copyWith({
    KeepAliveLink? link,
    bool? hasCanceled,
  }) {
    return _CachedProvider(
      link: link ?? this.link,
      hasCanceled: hasCanceled ?? this.hasCanceled,
    );
  }

  /// Закрыть [link]
  void dispose() {
    link?.close();
  }
}

class _CachedByTagProvidersContainer {
  _CachedByTagProvidersContainer() : cachedProviders = [];

  /// Список закешированных [_CachedProvider]
  final List<_CachedProvider> cachedProviders;

  /// Таймер, который используется для кеширования на определенную длительность
  Timer? timer;

  /// Количество отмененных провайдеров
  int get countCanceled => cachedProviders.where((p) => p.hasCanceled).length;

  /// Необходимо ли очистить все провайдеры
  bool get isAllCanceled =>
      countCanceled == cachedProviders.length && cachedProviders.isNotEmpty;

  /// Активен ли таймер
  bool get isActive => timer?.isActive ?? false;

  /// Был ли вызван метод [dispose]
  bool wasDisposed = false;

  /// Добавляем [cachedProvider] в [cachedProviders]
  void addProvider(_CachedProvider cachedProvider) {
    cachedProviders.add(cachedProvider);

    // Откладываем сброс флага, чтобы invalidate family-провайдера не потерял
    // только что добавленные инстансы из-за серии onDispose в том же цикле.
    Future(() => wasDisposed = false);
  }

  /// Уничтожает все закешированные провайдеры и отменяет текущий таймер.
  void dispose() {
    if (cachedProviders.isEmpty || wasDisposed) return;

    for (final p in cachedProviders) {
      p.dispose();
    }
    cancelTimer();
    timer = null;
    cachedProviders.clear();
    wasDisposed = true;
  }

  /// Метод, для совершения попытки уничтожения (очищения) контейнера
  void tryDispose() {
    /// Если не все [_CachedProvider] помечены как отмененные или активен таймер, то выходим
    if (!isAllCanceled || isActive) return;
    dispose();
  }

  void cancelTimer() {
    timer?.cancel();
  }

  /// Помечаем [_CachedProvider] как отмененный (hasCanceled = true) по связанному [KeepAliveLink]
  void closeByLink(KeepAliveLink link) {
    final provider = cachedProviders.firstWhereOrNull((p) => p.link == link);
    if (provider == null) return;
    final index = cachedProviders.indexOf(provider);
    cachedProviders[index] = provider.copyWith(hasCanceled: true);
  }

  /// Помечаем [_CachedProvider] как активный (hasCanceled = false) по связанному [KeepAliveLink]
  void resumeByLink(KeepAliveLink link) {
    final provider = cachedProviders.firstWhereOrNull((p) => p.link == link);
    if (provider == null) return;
    final index = cachedProviders.indexOf(provider);
    cachedProviders[index] = provider.copyWith(hasCanceled: false);
  }
}

extension<T> on Iterable<T> {
  /// The first element satisfying [test], or `null` if there are none.
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
