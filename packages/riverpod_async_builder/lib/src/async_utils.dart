// ignore_for_file: depend_on_referenced_packages, implementation_imports, invalid_use_of_protected_member, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod/src/async_notifier.dart';

extension AsyncUtils<State> on AsyncNotifierBase<State> {
  @protected
  void setData(State newState) => state = AsyncData<State>(newState);

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

extension ProviderSelectDataX<T> on ProviderListenable<AsyncValue<T>> {
  /// Позволяет выбирать часть из состояния провайдера, похож на AsyncValue.whenData,
  /// но поддерживает skipLoadingOnReload, skipLoadingOnRefresh и skipError
  ProviderListenable<AsyncValue<Selected>> selectData<Selected>(
    Selected Function(T data) selector,
  ) {
    return select(
      (value) => value.selectData(selector),
    );
  }
}

extension AsyncValueUtils<T> on AsyncValue<T> {
  /// Позволяет выбирать часть из состояния провайдера, похож на AsyncValue.whenData,
  /// но поддерживает skipLoadingOnReload, skipLoadingOnRefresh и skipError
  AsyncValue<Selected> selectData<Selected>(
    Selected Function(T data) selector,
  ) {
    return when<AsyncValue<Selected>>(
      data: (data) {
        final asyncData = AsyncData(selector(data));

        if (isLoading) {
          return AsyncLoading<Selected>().copyWithPrevious(asyncData);
        }

        return asyncData;
      },
      error: (e, s) {
        final asyncError = AsyncError<Selected>(e, s);

        if (hasValue) {
          return asyncError.copyWithPrevious(
            AsyncData(selector(value as T)),
            isRefresh: false,
          );
        }

        return asyncError;
      },
      loading: () {
        final asyncLoading = AsyncLoading<Selected>();

        if (hasValue) {
          return asyncLoading.copyWithPrevious(
            AsyncData(selector(value as T)),
            isRefresh: false,
          );
        }

        return asyncLoading;
      },
    );
  }
}
