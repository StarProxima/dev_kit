import 'dart:async';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _cacheMap = <String, ({Timer? timer, Set<KeepAliveLink> links})>{};

extension CacheRef on AutoDisposeRef {
  void cacheFor(Duration duration) {
    final link = keepAlive();

    final timer = Timer(duration, link.close);

    onDispose(timer.cancel);
  }

  void cacheByTag(String cacheTag) {
    _cacheMap[cacheTag]?.timer?.cancel();
    _cacheMap[cacheTag] ??= (timer: null, links: {});
    _cacheMap[cacheTag]?.links.add(keepAlive());
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
