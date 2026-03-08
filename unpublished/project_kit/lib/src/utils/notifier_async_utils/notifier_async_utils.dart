// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'package:hooks_riverpod/hooks_riverpod.dart';

extension NotifierAsyncUtils<State> on AsyncNotifier<State> {
  void setData(State newState) => state = AsyncData<State>(newState);

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
