import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_async_builder/riverpod_utils.dart' as utils;

import '../../project_kit.dart';

extension RefCacheX on AutoDisposeRef {
  void listenUserChanges({String? id}) {
    final ref = this;

    // Мы не можем сразу подписаться на userChangedProvider, т.к. если повайдера никто не слушает и он обновляется,
    // то падает исключение "...was disposed during loading state, yet no value could be emitted."
    //
    // Такое может произойти, например, при рефреше токена при заходе в приложение.
    switch (ref) {
      case AutoDisposeFutureProviderRef():
        ref.listenSelf((prev, next) {
          if ((prev?.hasValue ?? false) || next.hasValue) {
            ref.watch(userChangedProvider(id: id));
          }
        });

      case AutoDisposeAsyncNotifierProviderRef():
        ref.listenSelf((prev, next) {
          if ((prev?.hasValue ?? false) || next.hasValue) {
            ref.watch(userChangedProvider(id: id));
          }
        });

      default:
        ref.watch(userChangedProvider(id: id));
    }
  }

  KeepAliveLink cacheFor(
    Duration duration, {
    String? tag,
    utils.StartCacheTimer start = utils.StartCacheTimer.immediately,
  }) {
    listenUserChanges();

    return utils.RefCacheUtils(this).cacheFor(
      duration,
      tag: tag,
      start: start,
    );
  }
}
