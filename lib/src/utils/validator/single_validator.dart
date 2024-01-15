import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app_dev_kit.dart';

part 'single_validator.g.dart';

@riverpod
class _Error extends _$Error {
  @override
  String? build(int hashcode, String? initialError) => initialError;

  // ignore: use_setters_to_change_properties
  void setError(String? error) => state = error;
}

/// {@template [SingleValidatorBase]}
/// Базовый класс для валидаторов
/// {@endtemplate}
abstract class SingleValidatorBase<T> {
  /// {@macro [SingleValidatorBase]}
  SingleValidatorBase(
    this._ref,
    this._getState, {
    String? label,
    String? initialError,
    List<SingleValidatorBase> relatedValidators = const [],
  })  : _initialError = initialError,
        _label = label,
        _relatedValidators = relatedValidators;

  final Ref _ref;
  final FutureOr<T> Function() _getState;
  final String? _initialError;
  String? _label;
  String? get label => _label;

  // ignore: use_setters_to_change_properties
  void setLabel(String? label) => _label = label;

  /// Список связанных валидаторов, которые также будут валидироваться при валидации текущего
  final List<SingleValidatorBase> _relatedValidators;

  /// Внутренний метод валидации - принимает новую ошибку, обновляет провайдер и возвращает её.
  /// Также валидирует все связанные валидаторы.
  /// Если указано [softMode], то при успешной валидации убирает ошибку или меняет на новую, если текущая она уже присутствует.
  /// Не устанавливает новую ошибку, если текущей нет.
  String? _internalValidate(
    String? error, {
    required bool softMode,
  }) {
    final currentError = _ref.read(errorProvider);

    final errorsEqual = error == currentError;
    final softModeBlock = softMode && currentError == null;

    if (!errorsEqual && !softModeBlock) {
      setError(error);
    }

    for (final validator in _relatedValidators) {
      validator.softValidate();
    }

    return error;
  }

  /// Провайдер ошибки
  late final errorProvider = _errorProvider(hashCode, _initialError);

  /// Текущая ошибка в валидаторе
  String? get errorText => _ref.read(errorProvider);

  /// Устанавливает ошибку в провайдер.
  Future<void> setError(String? error) async {
    if (_ref.exists(errorProvider)) {
      _ref.read(errorProvider.notifier).setError(error);
    }
  }

  void clearError() => setError(null);

  /// Метод валидации - обновляет провайдер и возвращает ошибку
  FutureOr<String?> validate();

  /// Вариант метода [validate] с  `softMode`.
  /// Может поменять текущую ненулевую ошибку на другую, но не установить новую.
  /// При успешной валидации убирает ошибку или меняет на новую, если текущая она уже присутствует.
  /// Не устанавливает новую ошибку, если текущей нет.
  ///
  /// Может быть полезно при валадации ввода каждого символа.
  FutureOr<String?> softValidate();
}

@riverpod
class _ValidationCount extends _$ValidationCount {
  @override
  int build(int hashcode) => 0;

  void increment() => state++;
  void decrement() => state--;
}

@riverpod
bool _loading(_LoadingRef ref, int hashcode) =>
    ref.watch(_validationCountProvider(hashcode)) > 0;

/// {@template [SingleValidator]}
/// Вариант валидора с асинхронной валидацией
/// {@endtemplate}
class SingleValidator<T> extends SingleValidatorBase<T> {
  /// {@macro [SingleValidator]}
  SingleValidator(
    super._ref,
    super._getState, {
    required this.validateFn,
    this.postValidateFn,
    this.debounce,
    super.label,
    super.initialError,
    super.relatedValidators,
  });

  final FutureOr<String?> Function(T state) validateFn;
  final FutureOr<String?> Function(T state)? postValidateFn;
  final Debounce? debounce;

  /// Провайдер загрузки - true, если валидация в процессе
  // ignore: library_private_types_in_public_api
  _LoadingProvider get loadingProvider => _loadingProvider(hashCode);

  _ValidationCountProvider get _countProvider =>
      _validationCountProvider(hashCode);

  final _apiWrapper = ApiWrapper();

  FutureOr<String?> _internalAsyncValidate({required bool softMode}) async {
    final notifier = _ref.read(_countProvider.notifier);

    final initialExsit = _ref.exists(_countProvider);
    // ignore: unawaited_futures
    Future(() {
      if (initialExsit && _ref.exists(_countProvider)) {
        notifier.increment();
      }
    });

    final state = await _getState();
    var newError = await validateFn(state);

    var isCancel = false;

    newError ??= await _apiWrapper.apiWrapSingle<String?>(
      () => postValidateFn?.call(state),
      rateLimiter: debounce != null && softMode
          ? Debounce(
              tag: debounce!.tag,
              shouldCancelRunningOperations:
                  debounce!.shouldCancelRunningOperations,
              milliseconds: debounce!.inMilliseconds,
              onCancelOperation: () {
                debounce!.onCancelOperation?.call();
                isCancel = true;
              },
            )
          : null,
      onError: (e) => throw e,
    );

    if (initialExsit && _ref.exists(_countProvider)) {
      notifier.decrement();
    }

    return _internalValidate(newError, softMode: softMode);
  }

  @override
  FutureOr<String?> softValidate() => _internalAsyncValidate(softMode: true);

  @override
  FutureOr<String?> validate() => _internalAsyncValidate(softMode: false);
}
