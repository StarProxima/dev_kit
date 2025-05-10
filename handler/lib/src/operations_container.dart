import 'dart:async';

import 'rate_limiter/limiters/debounce.dart';
import 'rate_limiter/limiters/throttle.dart';

/// {@template operations_container}
/// Container for storing and managing operations of various types.
///
/// Allows managing [DebounceOperation] and [ThrottleOperation] operations
/// with the ability to start, cancel, and track them by keys.
///
/// Used for centralized management of asynchronous operations,
/// which simplifies their cancellation and execution.
/// {@endtemplate}
class OperationsContainer {
  /// {@macro operations_container}
  OperationsContainer();

  /// Map of debounce operations indexed by keys.
  final Map<Object, DebounceOperation> debounceOperations = {};

  /// Map of throttle operations indexed by keys.
  final Map<Object, ThrottleOperation> throttleOperations = {};

  Future<void> fire({required Object key}) async {
    final throttle = throttleOperations[key];
    throttle?.cancelCooldown();

    final debounce = debounceOperations[key];
    await debounce?.complete();
  }

  Future<void> fireAll() async {
    // Create a copy of operations to avoid concurrent modification
    final debounceOps = List<DebounceOperation>.from(debounceOperations.values);
    final futures = debounceOps.map((operation) => operation.complete());

    // Create a copy of throttle operations
    final throttleOps = List<ThrottleOperation>.from(throttleOperations.values);
    for (final operation in throttleOps) {
      operation.cancelCooldown();
    }

    await Future.wait(futures);
  }

  void cancel({required Object key}) {
    final debounce = debounceOperations[key];
    debounce?.cancel();

    final throttle = throttleOperations[key];
    throttle?.cancelCooldown();
  }

  void cancelAll() {
    // Create a copy of operations to avoid concurrent modification
    final debounceOps = List<DebounceOperation>.from(debounceOperations.values);
    for (final operation in debounceOps) {
      operation.cancel();
    }

    // Create a copy of throttle operations
    final throttleOps = List<ThrottleOperation>.from(throttleOperations.values);
    for (final operation in throttleOps) {
      operation.cancelCooldown();
    }
  }
}
