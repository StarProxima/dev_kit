import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../../core_dev_kit.dart';

/// {@template [ValidatorMixin]}
/// Предоставляет методы для создания и проверки обычных и асинхронных валидаторов.
/// {@endtemplate}
mixin ValidatorMixin implements IRef {
  @protected
  List<SingleValidatorBase> get allValidators =>
      UnmodifiableListView(_allValidators);

  final Set<SingleValidatorBase> _allValidators = {};

  /// Метод для создания [SingleValidator].
  /// Необходимо вызывать только при инициализации класса.
  /// Пример:
  /// ```dart
  /// late final passwordValidator = createValidator(
  ///   () => shared.validatePassword(_regState.password),
  ///   relatedValidators: [repeatPassword],
  /// );
  /// ```
  @protected
  SingleValidator<T> createValidator<T>(
    T Function() getState,
    String? Function(T state) validatorFn, {
    String? label,
    List<SingleValidatorBase> relatedValidators = const [],
  }) {
    final validator = SingleValidator<T>(
      ref,
      getState,
      validatorFn,
      label: label,
      relatedValidators: relatedValidators,
    );

    _allValidators.add(validator);

    return validator;
  }

  /// Метод для создания [SingleAsyncValidator].
  /// Необходимо вызывать только при инициализации класса.
  ///
  /// Пример:
  /// ```dart
  /// late final emailValidator = createAsyncValidator(
  ///   (setError) async {
  ///     var error = shared.validateEmail(_controlleState.email);
  ///     if (error != null) return error;
  ///
  ///     if (_isRegistration) {
  ///       error ??= await setError(
  ///         () => shared.checkExistsEmail(_controlleState.email),
  ///         debounce: const Duration(milliseconds: 1500),
  ///       );
  ///     }
  ///
  ///     return error;
  ///   },
  /// );
  /// ```
  @protected
  SingleAsyncValidator<T> createAsyncValidator<T>(
    FutureOr<T> Function() getState,
    FutureOr<String?> Function(T state, {required bool softMode}) validatorFn, {
    String? label,
    List<SingleValidatorBase> relatedValidators = const [],
  }) {
    final validator = SingleAsyncValidator<T>(
      ref,
      getState,
      validatorFn,
      label: label,
      relatedValidators: relatedValidators,
    );

    _allValidators.add(validator);

    return validator;
  }

  /// Метод для вызова валидации у переданных валидаторов.
  /// Возвращает список ошибок, если они есть.
  @protected
  Future<List<({String? label, String error})>> processValidators(
    List<SingleValidatorBase> validators, {
    bool softMode = false,
  }) async {
    final errors = <({String? label, String error})>[];

    for (final validator in validators) {
      final String? error;

      if (softMode) {
        error = await validator.softValidate();
      } else {
        error = await validator.validate();
      }

      if (error != null) errors.add((label: validator.label, error: error));
    }

    return errors;
  }
}
