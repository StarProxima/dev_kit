import 'dart:async';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _cacheMap = <String, ({Timer? timer, Set<KeepAliveLink> links})>{};

final _cacheMap2 = <String,
    ({bool isValidCache, Set<KeepAliveLink> links, Set<int> hashcodes})>{};

extension RefCacheX on AutoDisposeRef {
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

  void cacheByTagFor(String cacheTag, Duration duration) {
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
