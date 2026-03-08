// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

import 'dart:async';

import 'validator_riverpod_adapter.dart';

/// {@template [SingleValidatorBase]}
/// Базовый класс для валидаторов
/// {@endtemplate}
abstract class SingleValidatorBase<T> {
  /// {@macro [SingleValidatorBase]}
  SingleValidatorBase(
    this._riverpod, {
    String? label,
    String? initialError,
    List<SingleValidatorBase> relatedValidators = const [],
  })  : _initialError = initialError,
        _label = label,
        _relatedValidators = relatedValidators;

  final ValidatorRiverpodAdapter _riverpod;
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
    final currentError = _riverpod.read(errorProvider);

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
  late final errorProvider = _riverpod.createErrorProvider(
    hashcode: hashCode,
    initialError: _initialError,
  );

  /// Текущая ошибка в валидаторе
  String? get errorText => _riverpod.read(errorProvider);

  /// Устанавливает ошибку в провайдер.
  void setError(String? error) {
    if (_riverpod.exists(errorProvider)) {
      _riverpod.setError(
        hashCode,
        error,
        initialError: _initialError,
      );
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

/// {@template [SingleValidator]}
/// Вариант валидора с синхронной валидацией
/// {@endtemplate}
class SingleValidator<T> extends SingleValidatorBase<T> {
  /// {@macro [SingleValidator]}
  SingleValidator(
    super._riverpod,
    this._getState,
    this._validatorFn, {
    super.label,
    super.initialError,
    super.relatedValidators,
  });

  final T Function() _getState;
  final String? Function(T state) _validatorFn;

  @override
  String? softValidate() =>
      _internalValidate(_validatorFn(_getState()), softMode: true);

  @override
  String? validate() =>
      _internalValidate(_validatorFn(_getState()), softMode: false);
}

/// {@template [SingleAsyncValidator]}
/// Вариант валидора с асинхронной валидацией
/// {@endtemplate}
class SingleAsyncValidator<T> extends SingleValidatorBase<T> {
  /// {@macro [SingleAsyncValidator]}
  SingleAsyncValidator(
    super._riverpod,
    this._getState,
    this._validatorFn, {
    super.label,
    super.initialError,
    super.relatedValidators,
  });

  final FutureOr<T> Function() _getState;
  final FutureOr<String?> Function(T state, {required bool softMode})
      _validatorFn;

  /// Провайдер загрузки - true, если валидация в процессе
  late final loadingProvider = _riverpod.createLoadingProvider(hashCode);

  late final _countProvider = _riverpod.createValidationCountProvider(hashCode);

  FutureOr<String?> _internalAsyncValidate({bool softMode = false}) async {
    final initialExist = _riverpod.exists(_countProvider);

    // ignore: unawaited_futures
    Future(() {
      if (initialExist && _riverpod.exists(_countProvider)) {
        _riverpod.incrementValidationCount(
          hashCode,
          initialError: _initialError,
        );
      }
    });

    final state = await _getState();
    final newError = await _validatorFn(state, softMode: softMode);

    if (initialExist && _riverpod.exists(_countProvider)) {
      _riverpod.decrementValidationCount(
        hashCode,
        initialError: _initialError,
      );
    }

    return _internalValidate(newError, softMode: softMode);
  }

  @override
  FutureOr<String?> softValidate() => _internalAsyncValidate(softMode: true);

  @override
  FutureOr<String?> validate() => _internalAsyncValidate();
}
