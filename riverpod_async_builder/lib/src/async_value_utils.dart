import 'package:riverpod/riverpod.dart';

extension AsyncValueSelectDataX<T> on AsyncValue<T> {
  /// Позволяет выбирать часть из AsyncValue, похож на whenData,
  /// но сохраняет previous-state семантику для loading/error состояний.
  AsyncValue<Selected> selectData<Selected>(
    Selected Function(T data) selector,
  ) {
    return when<AsyncValue<Selected>>(
      data: (data) {
        final asyncData = AsyncData(selector(data));

        if (isLoading) {
          // ignore: invalid_use_of_internal_member
          return AsyncLoading<Selected>().copyWithPrevious(asyncData);
        }

        return asyncData;
      },
      error: (e, s) {
        final asyncError = AsyncError<Selected>(e, s);

        if (hasValue) {
          // ignore: invalid_use_of_internal_member
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
          // ignore: invalid_use_of_internal_member
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
