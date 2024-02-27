import 'package:flutter/widgets.dart';

import '../../../dev_kit.dart';

typedef OnRetry = Future<void> Function();

/// Класс для предоставления информации об ошибке в [AsyncBuilder]
class AsyncBuilderError {
  AsyncBuilderError({
    required this.error,
    required this.stackTrace,
    this.onRetry,
  });

  final Object error;
  final StackTrace stackTrace;
  final OnRetry? onRetry;

  @override
  String toString() =>
      '$error${error is InternalError ? '' : '\n\n$stackTrace'}';
}

/// Класс для предоставления дефолтных билдеров загрзки и ошибки для [AsyncBuilder]
class AsyncBuilderDefaults {
  AsyncBuilderDefaults.init({
    required this.loading,
    required this.error,
    required this.paginationPointer,
    this.paginationLoading,
    this.paginationError,
  }) {
    _instance = this;
  }

  static AsyncBuilderDefaults? _instance;

  static AsyncBuilderDefaults get instance =>
      _instance ??
      (throw Exception(
        'AsyncBuilderDefaults is not initialized. '
        'You should use AsyncBuilderDefaults.init',
      ));

  final Widget Function() loading;
  final Widget Function(AsyncBuilderError error) error;

  /// Page or offset
  final int Function(int index, int pageSize) paginationPointer;
  final Widget Function()? paginationLoading;
  final Widget Function(AsyncBuilderError error)? paginationError;
}
