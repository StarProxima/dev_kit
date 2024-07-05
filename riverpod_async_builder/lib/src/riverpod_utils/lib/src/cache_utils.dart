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
  /// Метод для кеширования провайдеров. Может использоваться как для обычного
  /// кеширования на определенное время [duration], так и по тэгу [tag] (например, для family-провайдеров)
  /// Если [tag] не задан (null), то будет использоваться кеширование по длительности, иначе кеширование по тегу
  /// [start] - определяет момент запуска таймера, после выполнения которого будет закрыт связанный [KeepAliveLink] с провайдером.
  /// Особенности типов кеширования описаны над методами [_cacheForByTag] и [_cacheFor]
  /// Возвращает [KeepAliveLink], что дает возможность вручную уничтожать закешированные провайдеры.
  KeepAliveLink cacheFor(
    Duration duration, {
    String? tag,
    StartCacheTimer start = StartCacheTimer.immediately,
  }) {
    if (tag != null) {
      return _cacheForByTag(duration, tag: tag, start: start);
    }
    return _cacheFor(duration, start: start);
  }

  /// Метод для обычного кеширования на определенную длительность [duration] с определенным моментом старта таймера [start].
  /// [duration] - длительность таймера, после которого будут закрыт [KeepAliveLink], связанный с провайдером.
  /// [start] - определяет момент запуска таймера, после выполнения которого будет закрыт связанный [KeepAliveLink] с провайдером.
  /// При [StartCacheTimer.immediately] таймер будет запущен сразу после создания провайдера.
  /// При [StartCacheTimer.afterCancel] таймер будет запущен после того, как не останется ни одного слушателя для провайдера.
  /// Если появится слушатель, то текущий таймер будет отменен, а после запущен новый.
  /// Возвращает [KeepAliveLink], что дает возможность вручную уничтожать закешированные провайдеры.
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
    onResume(
      () {
        if (start == StartCacheTimer.afterCancel) {
          timer?.cancel();
        }
      },
    );
    onDispose(() => timer?.cancel);
    return link;
  }

  /// Метод для кеширования по тэгу [tag] на определенную длительность [duration]
  /// с определенным моментом старта таймера [start].
  /// Кеширование работает по системе "Всё или ничего", то есть, если хотя бы один из провайдеров по тегу [tag] все еще активен,
  /// то и остальные провайдеры остаются закешированными. Это может быть полезным, например, для кеширования списков (family-провайдеры).
  /// Для представления закешированных провайдеров используется [_CachedProvider] и для их управления [_CachedByTagProvidersContainer].
  /// Алгоритм кеширования при различных значениях [start] :
  /// a) [start] = StartCacheTimer.immediately:
  /// 1. При кешировании первого провайдера по тегу [tag] создается контейнер [_CachedByTagProvidersContainer].
  /// В него добавляются все закешированные провайдеры по тегу [tag]
  /// 2. Создается [KeepAliveLink] для провайдера. Создается [_CachedProvider] с этим [KeepAliveLink]
  /// 3. Созданный [_CachedProvider] добавляется в контейнер [_CachedByTagProvidersContainer]
  /// 4. Региструрется таймер с длительностью [duration], по окончании которого будет выполнена попытка уничтожить (задиспоузить) все провайдеры по тегу [tag]
  /// 5. При [onCancel] помечаем [_CachedProvider] как отменный [hasCanceled] = true.
  /// Пытаемся уничтожить все провайдеры tryDispose(), так как в этот момент все провайдеры могут быть отменены.
  /// 6. При [onResume] создаем новый [KeepAliveLink], и обновляем [_CachedProvider], также помечаем его как активный [hasCanceled] = false.
  /// b) [start] = StartCacheTimer.afterCancel:
  /// 1. При кешировании первого провайдера по тегу [tag] создается контейнер [_CachedByTagProvidersContainer].
  /// В него добавляются все закешированные провайдеры по тегу [tag]
  /// 2. Создается [KeepAliveLink] для провайдера. Создается [_CachedProvider] с этим [KeepAliveLink]
  /// 3. Созданный [_CachedProvider] добавляется в контейнер [_CachedByTagProvidersContainer]
  /// 4. Создается колбек на [onCancel] для попытки регистрации таймера с длительностью [duration],
  /// по окончании которого будет выполнена попытка уничтожить (задиспоузить) все провайдеры по тегу [tag]
  /// Условия регистрации таймера: Все [_CachedProvider] должны быть отменены [hasCanceled] = true, а также не должно быть действующего таймера
  /// 5. При [onCancel] помечаем [_CachedProvider] как отменный [hasCanceled] = true.
  /// Пробуем запустить таймер [startTimerAfterCancel], так как в этот момент все провайдеры могут быть отменены.
  /// 6. При [onResume] создаем новый [KeepAliveLink], и обновляем [_CachedProvider], также помечаем его как активный [hasCanceled] = false.
  /// Также, если все [_CachedProvider] были отменены, то обнуляем таймер.
  /// При [onDispose] очищаем список [_CachedProvider] в контейнере [_CachedByTagProvidersContainer], также уничтожаем таймеры
  /// Возвращает [FamilyKeepAliveLink], что дает возможность вручную уничтожать закешированные провайдеры.
  FamilyKeepAliveLink _cacheForByTag(
    Duration duration, {
    required String tag,
    StartCacheTimer start = StartCacheTimer.immediately,
  }) {
    /// Создаем контейнер [_CachedByTagProvidersContainer], если его еще нет
    _cachedByTag[tag] ??= _CachedByTagProvidersContainer();

    /// Создаем [KeepAliveLink]
    final link = keepAlive();

    /// Создаем [_CachedProvider] и добавляем в контейнер
    final cachedProvider = _CachedProvider(link: link);
    _cachedByTag[tag]?.addProvider(cachedProvider);

    void tryDispose() {
      final container = _cachedByTag[tag];
      if (container == null) return;

      /// Пытаемся уничтожить провайдеры, если они все отменены
      if (container.isAllCanceled) {
        /// Используем Future, чтобы таймер успел перейти в неактивное состояние до вызова tryDispose
        Future(container.tryDispose);
      }
    }

    /// Метод для запуска таймера при [start] = StartCacheTimer.immediately
    void startTimerImmediately() {
      /// Если таймер уже есть, то выходим
      if (_cachedByTag[tag]?.timer != null) return;
      final timer = Timer(duration, tryDispose);
      _cachedByTag[tag]?.timer = timer;
    }

    void startTimerAfterCancel() {
      /// Если еще не отменены все провайдеры, то выходим
      if (!(_cachedByTag[tag]?.isAllCanceled ?? false)) return;

      /// Если таймер уже есть, то выходим
      if (_cachedByTag[tag]?.timer != null) return;
      final timer = Timer(duration, tryDispose);

      /// отменяем предыдущий таймер и задаем новый
      _cachedByTag[tag]?.cancelTimer();
      _cachedByTag[tag]?.timer = timer;
    }

    switch (start) {
      case StartCacheTimer.immediately:
        startTimerImmediately();
      case StartCacheTimer.afterCancel:
        onCancel(startTimerAfterCancel);
    }

    /// Если нет ни одного слушателя на провайдер (например, проскроллили до 5-й страницы,
    /// то 2-я перестанет прослушиваться, и будет вызван для него [onCancel])
    onCancel(
      () {
        final container = _cachedByTag[tag];
        if (container == null) return;

        /// Помечаем [_CachedProvider] как отмененный (hasCanceled = true)
        container.closeByLink(link);

        /// Пытаемся запустить таймер, так как все [_CachedProvider] могут быть уже отменены
        if (start == StartCacheTimer.afterCancel) {
          startTimerAfterCancel();
        }

        /// Пытаемся уничтожить провайдеры
        container.tryDispose();
      },
    );

    /// Вызывается, если снова появился слушатель провайдера
    onResume(
      () {
        final container = _cachedByTag[tag];
        if (container == null) return;

        /// Если начинаем заново прослушивать провайдеры по тегу [tag] и [start] = StartCacheTimer.afterCancel,
        /// то отменяем старый таймер.
        if (container.isAllCanceled && start == StartCacheTimer.afterCancel) {
          _cachedByTag[tag]?.cancelTimer();
          _cachedByTag[tag]?.timer = null;
        }

        container.resumeByLink(link);
      },
    );

    onDispose(() {
      _cachedByTag[tag]?.dispose();
    });

    return FamilyKeepAliveLink(
      () => _cachedByTag[tag]?.dispose(),
    );
  }
}

/// Используется для кэширования провайдеров по тегу
final Map<String, _CachedByTagProvidersContainer> _cachedByTag = {};
