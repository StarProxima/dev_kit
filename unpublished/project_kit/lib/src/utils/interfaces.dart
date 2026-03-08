import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Интерфейс для классов, которые работают с [Ref].
abstract class IRef {
  Ref get ref;
}

/// Интерфейс для [Notifier]-подобных классов.
abstract class INotifier<State> {
  State get state;
  Ref get ref;
  set state(State value);

  VoidCallback listenSelf(
    void Function(State? previous, State next) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
  });
}

/// Интерфейс для [AsyncNotifier]-подобных классов.
abstract class IAsyncNotifier<State> {
  Future<State> get future;
  AsyncValue<State> get state;
  Ref get ref;
  set state(AsyncValue<State> value);

  VoidCallback listenSelf(
    void Function(AsyncValue<State>? previous, AsyncValue<State> next) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
  });
}
