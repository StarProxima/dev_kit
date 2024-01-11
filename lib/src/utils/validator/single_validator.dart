import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core_dev_kit.dart';

part 'single_validator.g.dart';

/// Метод для установки ошибки вручную в AsyncValidator
/// [Debounce] работает только в softMode. Если операция прерывается, то текущая ошибка убирается.
/// В обычном режиме валидация не может быть прервана, что бы не было false positive результатов.
typedef SetError = FutureOr<String?> Function(
  FutureOr<String?> Function() error, {
  Debounce? softDebounce,
});

@Riverpod(keepAlive: true)
class _Error2 extends _$Error2 {
  @override
  Future<String?> build() async => 'initialError';

  // ignore: use_setters_to_change_properties
  void setError(String? error) => state = error as AsyncValue<String?>;
}

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
abstract class SingleValidatorBase {
  /// {@macro [SingleValidatorBase]}
  SingleValidatorBase(
    this._ref, {
    this.name,
    String? initialError,
    List<SingleValidatorBase> relatedValidators = const [],
  })  : _initialError = initialError,
        _relatedValidators = relatedValidators;

  final Ref _ref;
  final String? _initialError;
  String? name;

  /// Список связанных валидаторов, которые также будут валидироваться при валидации текущего
  final List<SingleValidatorBase> _relatedValidators;

  final _apiUtils = ApiWrapper();

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
      setError(() => error);
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
  /// Если указан [debounce], то ошибка будет установлена только если
  /// в течении [debounce] не было вызвано других [setError]
  FutureOr<String?> setError(
    FutureOr<String?> Function() error, {
    Debounce? debounce,
  }) async {
    final errorStr = await _apiUtils.apiWrapSingle<String?>(
      () async {
        final errorStr = await error();

        if (_ref.exists(errorProvider)) {
          _ref.read(errorProvider.notifier).setError(errorStr);
        }

        return errorStr;
      },
      rateLimiter: debounce != null
          ? Debounce(
              tag: debounce.tag ?? hashCode.toString(),
              milliseconds: debounce.inMilliseconds,
            )
          : null,
    );

    return errorStr;
  }

  void clearError() => setError(() => null);

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
final class SingleValidator extends SingleValidatorBase {
  /// {@macro [SingleValidator]}
  SingleValidator(
    super._ref,
    this._validatorFn, {
    super.name,
    super.initialError,
    super.relatedValidators,
  });

  final String? Function() _validatorFn;

  @override
  String? softValidate() => _internalValidate(_validatorFn(), softMode: true);

  @override
  String? validate() => _internalValidate(_validatorFn(), softMode: false);
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

/// {@template [SingleAsyncValidator]}
/// Вариант валидора с асинхронной валидацией
/// Можно несколько раз обновлять ошибку через [SetError]
/// {@endtemplate}
final class SingleAsyncValidator extends SingleValidatorBase {
  /// {@macro [SingleAsyncValidator]}
  SingleAsyncValidator(
    super._ref,
    this._validatorFn, {
    super.name,
    super.initialError,
    super.relatedValidators,
  });

  final FutureOr<String?> Function(SetError) _validatorFn;

  /// Провайдер загрузки - true, если валидация в процессе
  late final loadingProvider = _loadingProvider(hashCode);

  _ValidationCountProvider get _countProvider =>
      _validationCountProvider(hashCode);

  FutureOr<String?> _internalAsyncValidate({bool softMode = false}) async {
    final notifier = _ref.read(_countProvider.notifier);

    // ignore: unawaited_futures
    Future(() {
      if (_ref.exists(_countProvider)) notifier.increment();
    });

    final newError = await _validatorFn(
      (error, {softDebounce}) =>
          setError(error, debounce: softMode ? softDebounce : null),
    );

    if (_ref.exists(_countProvider)) notifier.decrement();

    return _internalValidate(newError, softMode: softMode);
  }

  @override
  FutureOr<String?> softValidate() => _internalAsyncValidate(softMode: true);

  @override
  FutureOr<String?> validate() => _internalAsyncValidate();
}
