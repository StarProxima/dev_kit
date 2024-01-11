import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../core_dev_kit.dart';

/// {@template [ValidatorMixin]}
/// Предоставляет методы для создания и проверки обычных и асинхронных валидаторов.
/// {@endtemplate}
mixin ValidatorMixin implements IRef {
  @protected
  List<SingleValidatorBase> get allValidators =>
      UnmodifiableListView(_allValidators.values);

  final Map<String, SingleValidatorBase> _allValidators = {};

  String get validatorTag => '$hashCode${StackTrace.current}';

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
    String? label,
    List<SingleValidatorBase> relatedValidators = const [],
  }) {
    final validator = SingleValidator(
      ref,
      validatorFn,
      tag: validatorTag,
      label: label,
      relatedValidators: relatedValidators,
    );
    final a1 = _allValidators.length;

    _allValidators[validator.tag] = validator;

    final a2 = _allValidators.length;

    if (a1 == a2) {
      print('Validator already added');
    }

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
    String? label,
    List<SingleValidatorBase> relatedValidators = const [],
  }) {
    final validator = SingleAsyncValidator(
      ref,
      label: label,
      tag: validatorTag,
      validatorFn,
      relatedValidators: relatedValidators,
    );

    _allValidators[validator.tag] = validator;

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
