import 'dart:async';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../dev_kit.dart';

final _cacheMap = <String, ({Timer? timer, Set<KeepAliveLink> links})>{};

final _cacheMap2 = <String,
    ({bool isValidCache, Set<KeepAliveLink> links, Set<int> hashcodes})>{};

extension RefCacheX on AutoDisposeRef {
  void listenUserChanges() {
    final ref = this;

    // Мы не можем сразу подписаться на userChangedProvider, т.к. если повайдера никто не слушает и он обновляется,
    // то падает исключение "...was disposed during loading state, yet no value could be emitted."
    //
    // Такое может произойти, например, при рефреше токена при заходе в приложение.
    switch (ref) {
      case AutoDisposeFutureProviderRef():
        ref.listenSelf((prev, next) {
          if ((prev?.hasValue ?? false) || next.hasValue) {
            ref.watch(userChangedProvider);
          }
        });

      case AutoDisposeAsyncNotifierProviderRef():
        ref.listenSelf((prev, next) {
          if ((prev?.hasValue ?? false) || next.hasValue) {
            ref.watch(userChangedProvider);
          }
        });

      default:
        ref.watch(userChangedProvider);
    }
  }

  void cacheFor(Duration duration) {
    listenUserChanges();

    final link = keepAlive();
    final timer = Timer(duration, link.close);
    onDispose(timer.cancel);
  }

  void cacheByTag(String cacheTag) {
    listenUserChanges();

    _cacheMap[cacheTag]?.timer?.cancel();
    _cacheMap[cacheTag] ??= (timer: null, links: {});
    _cacheMap[cacheTag]?.links.add(keepAlive());
  }

  @Deprecated('Пока не работает должным образом')
  void cacheByTagFor(String cacheTag, Duration duration) {
    listenUserChanges();

    final timer = Timer(duration, () {
      final item = _cacheMap2[cacheTag];
      if (item != null) {
        _cacheMap2[cacheTag] =
            (isValidCache: false, links: item.links, hashcodes: item.hashcodes);
      }
    });
    _cacheMap2[cacheTag] ??= (isValidCache: true, links: {}, hashcodes: {});
    _cacheMap2[cacheTag]?.links.add(keepAlive());

    onCancel(() {
      final item = _cacheMap2[cacheTag];
      item?.hashcodes.add(hashCode);
      if (item?.hashcodes.length == item?.links.length) {
        _cacheMap.remove(cacheTag)?.links.forEach((e) => e.close());
      }
    });

    onResume(() {
      _cacheMap2[cacheTag]?.hashcodes.remove(hashCode);
    });

    onDispose(timer.cancel);
  }
}

void useCacheFamilyProvider(String cacheTag, Duration duration) {
  useEffect(() {
    _cacheMap[cacheTag]?.timer?.cancel();
    return () {
      _cacheMap[cacheTag]?.timer?.cancel();
      _cacheMap[cacheTag] = (
        timer: Timer(duration, () {
          _cacheMap.remove(cacheTag)?.links.forEach((e) => e.close());
        }),
        links: _cacheMap[cacheTag]?.links ?? {},
      );
    };
  });
}
