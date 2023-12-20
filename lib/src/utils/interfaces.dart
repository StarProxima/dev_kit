import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Интерфейс для классов, которые работают с [Ref].
abstract class IRef {
  Ref get ref;
}

/// Интерфейс для [Notifier]-подобных классов
abstract class INotifier<State> {
  State get state;
  set state(State value);
  Ref<State> get ref;
}

/// Интерфейс для [AsyncNotifier]-подобных классов
abstract class IAsyncNotifier<State> {
  Future<State> get future;
  AsyncValue<State> get state;
  set state(AsyncValue<State> value);
  Ref get ref;
}
