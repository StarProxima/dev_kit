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

  final List<SingleValidatorBase> _allValidators = [];

  /// Метод для создания [SingleValidator].
  /// Необходимо вызывать только при инициализации класса.
  /// Пример:
  /// ```dart
  /// late final password = validator(
  ///   () => shared.validatePassword(_regState.password),
  ///   relatedValidators: [repeatPassword],
  /// );
  /// ```
  @protected
  SingleValidator validator(
    String? Function() validatorFn, {
    String? name,
    List<SingleValidatorBase> relatedValidators = const [],
  }) {
    final validator = SingleValidator(
      ref,
      validatorFn,
      name: name,
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
  /// late final email = asyncValidator(
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
  SingleAsyncValidator asyncValidator(
    FutureOr<String?> Function(SetError setError) validatorFn, {
    String? name,
    List<SingleValidatorBase> relatedValidators = const [],
  }) {
    final validator = SingleAsyncValidator(
      ref,
      name: name,
      validatorFn,
      relatedValidators: relatedValidators,
    );

    _allValidators.add(validator);

    return validator;
  }

  /// Метод для вызова валидации у переданных валидаторов.
  /// Возвращает список ошибок, если они есть.
  @protected
  Future<List<({String? name, String error})>> processValidators(
    List<SingleValidatorBase> validators, {
    bool softMode = false,
  }) async {
    final errors = <({String? name, String error})>[];

    for (final validator in validators) {
      final String? error;

      if (softMode) {
        error = await validator.softValidate();
      } else {
        error = await validator.validate();
      }

      if (error != null) errors.add((name: validator.name, error: error));
    }

    return errors;
  }
}
