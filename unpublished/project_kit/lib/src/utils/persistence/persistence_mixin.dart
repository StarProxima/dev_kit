// ignore_for_file: deprecated_member_use, prefer-correct-callback-field-name

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../internal/logger/dev_kit_logger.dart';
import '../interfaces.dart';
import 'persistence_storage.dart';

/// {@template [PersistenceMixin]}
/// Миксин для локального сохранение состояния в [PersistenceStorage].
/// При создании контроллера, состояние восстанавливается из хранилища.
/// При изменении состояния, оно автоматически сохраняется.
/// {@endtemplate}
///
/// Пример:
///
/// ```dart
/// class TestPersistenceNotifier extends Notifier<PersistenceState>
///     with PersistenceMixin<PersistenceState> {
///   TestPersistenceNotifier(this.arg);
///
///   final int arg;
///
///   @override
///   PersistenceState build() => persistentBuild(
///         () => PersistenceState(index: arg),
///         fromJson: PersistenceState.fromJson,
///         storageId: arg,
///       );
/// }
/// ```

mixin PersistenceMixin<State> implements INotifier<State> {
  bool _isInitialized = false;
  String? _storageId;
  late String _storageKey = runtimeType.toString();
  PersistenceStorage get _storage => PersistenceStorage.storage;

  @protected
  late FromJson<State> _fromJson;
  @protected
  ToJson<State> _toJson = _defaultToJson<State>;

  /// Метод для использования внутри метода build у [Notifier]-подобных классов.
  ///
  /// [build] - Метод для инициализации состояния контроллера, вызывается, когда данные в хранилище не найдены или повреждены.
  /// [fromJson] - Метод для десериализации данных из хранилища.
  /// [toJson] - Метод для сериализации данных в хранилище. По умолчанию используется метод [toJson] у [State].
  /// [storageId] - Идентификатор ключа для доступа к хранилищу. Нужен, если используются несколько контроллеров одного типа.
  /// [storageKey] - Префикс ключа для доступа к хранилищу. По умолчанию равен имени класса контроллера.
  @protected
  @nonVirtual
  // ignore: avoid-long-parameter-list
  State persistentBuild(
    State Function() build, {
    bool enabled = true,
    required FromJson<State> fromJson,
    ToJson<State>? toJson,
    Object? storageId,
    String? storageKey,
    // ignore: prefer-boolean-prefixes
    bool updateAfterFirstBuild = false,
  }) {
    _fromJson = fromJson;
    if (toJson != null) _toJson = toJson;
    if (storageId != null) _storageId = storageId.toString();
    if (storageKey != null) _storageKey = storageKey;

    final data = _storage.read(key: _storageKey, id: _storageId);

    listenSelf((_, __) => Future(pushData));

    if (enabled && data != null && !_isInitialized) {
      try {
        _isInitialized = true;
        // Нужно предварительно пеобразовать json, т.к. иначе дарт сам не преобразует
        // внутренние модели из Map в Map<String, dynamic> и выбросит
        // type '_Map<dynamic, dynamic>' is not a subtype of type 'Map<String, dynamic>' in type cast
        final json = jsonDecode(jsonEncode(data));
        final map = Map<String, dynamic>.from(json);

        if (updateAfterFirstBuild) {
          Future(() {
            final data = build();
            state = data;
          });
        }

        return _fromJson(map);
      } catch (e, s) {
        DevKitLogger.instance.error(
          title: 'Error while parsing data from storage',
          stack: s,
          error: e,
          message: data,
        );
        clearData();
        if (kDebugMode) rethrow;
      }
    }

    return build();
  }

  @protected
  void pullData() {
    final data = _storage.read(key: _storageKey, id: _storageId);
    if (data != null) state = _fromJson(data);
  }

  @protected
  Future<void> pushData() async {
    final data = state == null ? null : _toJson(state);
    await _storage.write(key: _storageKey, id: _storageId, value: data);
  }

  @protected
  Future<void> clearData() =>
      _storage.delete(key: _storageKey, id: _storageId);

  @protected
  Future<void> clearStorage() => _storage.delete(key: _storageKey);
}

/// {@macro [PersistenceMixin]}
///
/// Пример:
/// ```dart
/// class TestPersistenceNotifier extends AsyncNotifier<PersistenceState>
///     with AsyncPersistenceMixin<PersistenceState> {
///   TestPersistenceNotifier(this.arg);
///
///   final int arg;
///
///   @override
///   FutureOr<PersistenceState> build() => persistentBuild(
///         () async {
///           await Future.delayed(const Duration(seconds: 1));
///           return PersistenceState(index: arg);
///         },
///         fromJson: PersistenceState.fromJson,
///         storageId: arg,
///       );
/// }
/// ```
mixin AsyncPersistenceMixin<State> implements IAsyncNotifier<State> {
  bool _isInitialized = false;
  String? _storageId;
  late String _storageKey = runtimeType.toString();
  PersistenceStorage get _storage => PersistenceStorage.storage;

  @protected
  late FromJson<State> _fromJson;
  @protected
  ToJson<State> _toJson = _defaultToJson<State>;

  /// Метод для использования внутри метода build у [AsyncNotifier]-подобных классов.
  ///
  /// [build] - Метод для инициализации состояния контроллера, вызывается, когда данные в хранилище не найдены или повреждены.
  /// [fromJson] - Метод для десериализации данных из хранилища.
  /// [toJson] - Метод для сериализации данных в хранилище. По умолчанию используется метод [toJson] у [State].
  /// [storageId] - Идентификатор ключа для доступа к хранилищу. Нужен, если используются несколько контроллеров одного типа.
  /// [storagePrefix] - Префикс ключа для доступа к хранилищу. По умолчанию равен имени класса контроллера.
  @protected
  @nonVirtual
  // ignore: avoid-long-parameter-list
  FutureOr<State> persistentBuild(
    FutureOr<State> Function() build, {
    bool enabled = true,
    required FromJson<State> fromJson,
    ToJson<State>? toJson,
    Object? storageId,
    String? storagePrefix,
    // ignore: prefer-boolean-prefixes
    bool updateAfterFirstBuild = false,
  }) {
    _fromJson = fromJson;
    if (toJson != null) _toJson = toJson;
    if (storageId != null) _storageId = storageId.toString();
    if (storagePrefix != null) _storageKey = storagePrefix;

    final data = _storage.read(key: _storageKey, id: _storageId);

    listenSelf((_, __) => Future(pushDataToStorage));
    final isRefresh = state.isRefreshing || state.isReloading;

    if (enabled && data != null && !_isInitialized && !isRefresh) {
      try {
        _isInitialized = true;
        // Нужно предварительно пеобразовать json, т.к. иначе дарт сам не преобразует
        // внутренние модели из Map в Map<String, dynamic> и выбросит
        // type '_Map<dynamic, dynamic>' is not a subtype of type 'Map<String, dynamic>' in type cast
        final json = jsonDecode(jsonEncode(data));
        final map = Map<String, dynamic>.from(json);

        if (updateAfterFirstBuild) {
          Future(() async {
            final futureOr = build();

            if (futureOr is Future) {
              final data = await futureOr;
              state = AsyncData(data);
            } else {
              state = AsyncData(futureOr);
            }
          });
        }

        return _fromJson(map);
      } catch (e, s) {
        DevKitLogger.instance.error(
          title: 'Error while parsing data from storage',
          stack: s,
          error: e,
          message: data,
        );
        clearStorage();
        if (kDebugMode) rethrow;
      }
    }

    return build();
  }

  @protected
  void pullDataFromStorage() {
    final data = _storage.read(key: _storageKey, id: _storageId);
    if (data != null) state = AsyncData(_fromJson(data));
  }

  @protected
  Future<void> pushDataToStorage() async {
    final st = state;
    if (st is! AsyncData<State>) return;
    final data = st.value == null ? null : _toJson(st.value);
    await _storage.write(key: _storageKey, id: _storageId, value: data);
  }

  @protected
  Future<void> clearData() =>
      _storage.delete(key: _storageKey, id: _storageId);

  @protected
  Future<void> clearStorage() => _storage.delete(key: _storageKey);
}

typedef FromJson<State> = State Function(Map<String, dynamic> json);
typedef ToJson<State> = Map<String, dynamic>? Function(State state);

Map<String, dynamic> _defaultToJson<State>(State state) {
  try {
    // ignore: avoid_dynamic_calls, avoid-type-casts, avoid-dynamic
    return (state as dynamic).toJson();
  } catch (e, s) {
    DevKitLogger.instance.error(
      title:
          'Error while serializing data to storage. State should implement toJson()',
      stack: s,
      error: e,
      message: state,
    );
    rethrow;
  }
}
