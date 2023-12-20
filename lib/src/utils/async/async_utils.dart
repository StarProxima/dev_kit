// ignore_for_file: depend_on_referenced_packages, implementation_imports, invalid_use_of_protected_member, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/src/async_notifier.dart';

extension AsyncUtils<State> on AsyncNotifierBase<State> {
  @protected
  void setLoading() => state = AsyncLoading<State>();

  @protected
  void setData(State newState) => state = AsyncData<State>(newState);

  @protected
  void restoreLastState([Object? error]) {
    if (state is AsyncLoading<State> && state.hasValue && state.value != null) {
      setData(state.value as State);
    } else {
      setError(Exception('No last state found: $error'));
    }
  }

  @protected
  void setError(Object error, [StackTrace? stackTrace]) =>
      state = AsyncError<State>(error, stackTrace ?? StackTrace.current);

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

extension RefAsyncRefresh on Ref {
  Future<void> refreshAsync<State>(
    AsyncNotifierProviderBase<dynamic, State> provider,
  ) async {
    return await refresh(provider.future);
  }
}

extension WidgetRefAsyncRefresh on WidgetRef {
  Future<void> refreshAsync<State>(
    AsyncNotifierProviderBase<dynamic, State> provider,
  ) async {
    return await refresh(provider.future);
  }
}
