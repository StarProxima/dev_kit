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
  ///
  /// A debounce operation delays function execution until
  /// a specified time has passed since the last call.
  final Map<Object, DebounceOperation> debounceOperations = {};

  /// Map of throttle operations indexed by keys.
  ///
  /// A throttle operation limits the frequency of function execution,
  /// ensuring a minimum interval between executions.
  final Map<Object, ThrottleOperation> throttleOperations = {};

  /// {@template operations_container.fire}
  /// Executes an operation with the specified [key].
  ///
  /// If an operation exists for the given key:
  /// - throttle operation - cancels its cooldown period
  /// - debounce operation - executes it immediately
  ///
  /// Returns a [Future] that completes after all operations are started.
  /// {@endtemplate}
  Future<void> fire({required Object key}) async {
    final throttle = throttleOperations[key];
    throttle?.cancelCooldown();

    final debounce = debounceOperations[key];
    await debounce?.complete();
  }

  /// {@template operations_container.fireAll}
  /// Executes all registered operations.
  ///
  /// Cancels the cooldown period for all throttle operations
  /// and immediately executes all debounce operations.
  ///
  /// Returns a [Future] that completes after all operations are started.
  /// {@endtemplate}
  Future<void> fireAll() async {
    final futures = debounceOperations.values.map(
      (operation) => operation.complete(),
    );

    for (final operation in throttleOperations.values) {
      operation.cancelCooldown();
    }

    await Future.wait(futures);
  }

  /// {@template operations_container.cancel}
  /// Cancels operations with the specified [key].
  ///
  /// If an operation exists for the given key:
  /// - debounce operation - cancels its execution
  /// - throttle operation - cancels its cooldown period
  /// {@endtemplate}
  void cancel({required Object key}) {
    final debounce = debounceOperations[key];
    debounce?.cancel();

    final throttle = throttleOperations[key];
    throttle?.cancelCooldown();
  }

  /// {@template operations_container.cancelAll}
  /// Cancels all registered operations.
  ///
  /// Cancels execution of all debounce operations and
  /// cooldown periods for all throttle operations.
  /// {@endtemplate}
  void cancelAll() {
    for (final operation in debounceOperations.values) {
      operation.cancel();
    }

    for (final operation in throttleOperations.values) {
      operation.cancelCooldown();
    }
  }
}
