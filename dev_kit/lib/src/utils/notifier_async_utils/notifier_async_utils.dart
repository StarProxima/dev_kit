// ignore_for_file: depend_on_referenced_packages, implementation_imports, invalid_use_of_protected_member, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/src/async_notifier.dart';

extension NotifierAsyncUtils<State> on AsyncNotifierBase<State> {
  void setData(State newState) => state = AsyncData<State>(newState);

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
