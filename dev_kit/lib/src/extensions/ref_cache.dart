import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_utils/riverpod_utils.dart' as cu;

import '../../dev_kit.dart';

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

  KeepAliveLink cacheFor(
    Duration duration, {
    String? tag,
    int? key,
    cu.MomentDisposeCache moment = cu.MomentDisposeCache.immediately,
  }) {
    listenUserChanges();

    return cu.RefCacheUtils(this).cacheFor(
      duration,
      tag: tag,
      key: key,
      moment: moment,
    );
  }
}
