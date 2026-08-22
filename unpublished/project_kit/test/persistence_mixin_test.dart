// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:project_kit/src/utils/interfaces.dart';
import 'package:project_kit/src/utils/persistence/persistence_mixin.dart';
import 'package:project_kit/src/utils/persistence/persistence_storage.dart';

// ---------------------------------------------------------------------------
// In-memory storage mock
// ---------------------------------------------------------------------------

class _InMemoryStorage implements PersistenceStorage {
  final Map<String, dynamic> data = {};
  final List<({String key, String? id, dynamic value})> writes = [];

  @override
  dynamic read({required String key, String? id}) {
    final entry = data[key];
    if (id != null) {
      if (entry is Map) return entry[id];
      return null;
    }
    return entry;
  }

  @override
  Future<void> write({
    required String key,
    String? id,
    required dynamic value,
  }) async {
    writes.add((key: key, id: id, value: value));
    if (id != null) {
      final existing = data[key];
      final map = existing is Map ? Map.of(existing) : <dynamic, dynamic>{};
      map[id] = value;
      data[key] = map;
      return;
    }
    data[key] = value;
  }

  @override
  Future<void> delete({required String key, String? id}) async {
    if (id != null) {
      final existing = data[key];
      if (existing is Map) {
        data[key] = Map.of(existing)..remove(id);
      }
      return;
    }
    data.remove(key);
  }

  @override
  Future<void> clear() async => data.clear();

  @override
  Future<void> close() async {}
}

// ---------------------------------------------------------------------------
// Test state
// ---------------------------------------------------------------------------

class _TestState {
  const _TestState(this.value);
  final int value;

  Map<String, dynamic> toJson() => {'value': value};

  static _TestState fromJson(Map<String, dynamic> json) =>
      _TestState(json['value'] as int);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is _TestState && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'TestState($value)';
}

// ---------------------------------------------------------------------------
// Sync notifier (PersistenceMixin)
// ---------------------------------------------------------------------------

final _syncProvider = NotifierProvider<_SyncNotifier, _TestState>(
  _SyncNotifier.new,
);

class _SyncNotifier extends Notifier<_TestState>
    with PersistenceMixin<_TestState> {
  @override
  _TestState build() => persistentBuild(
        () => const _TestState(0),
        fromJson: _TestState.fromJson,
      );

  void setValue(int v) => state = _TestState(v);
}

// Два провайдера с одним storageKey, но разным storageId
class _SyncWithIdNotifier extends Notifier<_TestState>
    with PersistenceMixin<_TestState> {
  _SyncWithIdNotifier(this.id);
  final int id;

  @override
  _TestState build() => persistentBuild(
        () => _TestState(id),
        fromJson: _TestState.fromJson,
        storageKey: 'shared',
        storageId: id,
      );

  void setValue(int v) => state = _TestState(v);
}

final _syncId1Provider = NotifierProvider<_SyncWithIdNotifier, _TestState>(
  () => _SyncWithIdNotifier(1),
);
final _syncId2Provider = NotifierProvider<_SyncWithIdNotifier, _TestState>(
  () => _SyncWithIdNotifier(2),
);

// ---------------------------------------------------------------------------
// Async notifier (AsyncPersistenceMixin)
// ---------------------------------------------------------------------------

final _asyncProvider =
    AsyncNotifierProvider<_AsyncNotifier, _TestState>(_AsyncNotifier.new);

class _AsyncNotifier extends AsyncNotifier<_TestState>
    with AsyncPersistenceMixin<_TestState> {
  @override
  FutureOr<_TestState> build() => persistentBuild(
        () async => const _TestState(0),
        fromJson: _TestState.fromJson,
      );

  void setValue(int v) => state = AsyncData(_TestState(v));
}

// Async с updateAfterFirstBuild
final _asyncUpdateProvider =
    AsyncNotifierProvider<_AsyncUpdateNotifier, _TestState>(
  _AsyncUpdateNotifier.new,
);

class _AsyncUpdateNotifier extends AsyncNotifier<_TestState>
    with AsyncPersistenceMixin<_TestState> {
  int buildCallCount = 0;

  @override
  FutureOr<_TestState> build() => persistentBuild(
        () {
          buildCallCount++;
          return const _TestState(99);
        },
        fromJson: _TestState.fromJson,
        updateAfterFirstBuild: true,
      );
}

// ---------------------------------------------------------------------------
// Async notifier с зависимостью, объявленной до первого await
// ---------------------------------------------------------------------------

final _depProvider = NotifierProvider<_DepNotifier, int>(_DepNotifier.new);

class _DepNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state = state + 1;
}

/// Держит первый проход build подвисшим, пока тест меняет зависимость.
Completer<void>? _firstPassGate;

final _asyncWatchingProvider =
    AsyncNotifierProvider<_AsyncWatchingNotifier, _TestState>(
  _AsyncWatchingNotifier.new,
);

class _AsyncWatchingNotifier extends AsyncNotifier<_TestState>
    with AsyncPersistenceMixin<_TestState> {
  int buildCount = 0;

  @override
  Future<_TestState> build() async {
    buildCount++;
    final isFirstPass = buildCount == 1;

    ref.watch(_depProvider);

    // Фолбэк выдумывает данные, а не идёт за ними заново - как у потребителей,
    // которые хранят накопленное.
    final restored = await persistentBuild(
      () => state.value ?? const _TestState(0),
      fromJson: _TestState.fromJson,
    );

    if (isFirstPass) await _firstPassGate?.future;

    return restored;
  }
}

final _asyncWatchingUpdateProvider =
    AsyncNotifierProvider<_AsyncWatchingUpdateNotifier, _TestState>(
  _AsyncWatchingUpdateNotifier.new,
);

class _AsyncWatchingUpdateNotifier extends AsyncNotifier<_TestState>
    with AsyncPersistenceMixin<_TestState> {
  int buildCount = 0;
  int fallbackCallCount = 0;

  @override
  Future<_TestState> build() async {
    buildCount++;
    final isFirstPass = buildCount == 1;

    ref.watch(_depProvider);

    final restored = await persistentBuild(
      () {
        fallbackCallCount++;
        return const _TestState(99);
      },
      fromJson: _TestState.fromJson,
      updateAfterFirstBuild: true,
    );

    if (isFirstPass) await _firstPassGate?.future;

    return restored;
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

late _InMemoryStorage _storage;

void _initStorage([Map<String, dynamic>? initial]) {
  _storage = _InMemoryStorage();
  if (initial != null) _storage.data.addAll(initial);
  PersistenceStorage.storage = _storage;
}

/// Прокачивает микротаски + Future-очередь чтобы listenSelf -> Future(write) отработал.
Future<void> _pumpWrites() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('PersistenceMixin', () {
    test('build() вызывается, когда в storage нет данных', () {
      _initStorage();
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final state = container.read(_syncProvider);
      expect(state, const _TestState(0));
    });

    test('восстанавливает состояние из storage', () {
      _initStorage({
        '_SyncNotifier': {'value': 42},
      });
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final state = container.read(_syncProvider);
      expect(state, const _TestState(42));
    });

    test('автоматически сохраняет в storage при изменении state', () async {
      _initStorage();
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final notifier = container.read(_syncProvider.notifier);
      notifier.setValue(7);

      await _pumpWrites();

      final stored = _storage.read(key: '_SyncNotifier');
      expect(stored, {'value': 7});
    });

    test('storageId разделяет данные для разных инстансов', () async {
      _initStorage({
        'shared': {
          '1': {'value': 10},
          '2': {'value': 20},
        },
      });
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final s1 = container.read(_syncId1Provider);
      final s2 = container.read(_syncId2Provider);

      expect(s1, const _TestState(10));
      expect(s2, const _TestState(20));

      container.read(_syncId1Provider.notifier).setValue(11);
      await _pumpWrites();

      expect(_storage.read(key: 'shared', id: '1'), {'value': 11});
      expect(_storage.read(key: 'shared', id: '2'), {'value': 20});
    });

    test('clearData удаляет данные из storage', () async {
      _initStorage({
        '_SyncNotifier': {'value': 1},
      });
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      container.read(_syncProvider);
      final notifier = container.read(_syncProvider.notifier);
      await _pumpWrites();
      await notifier.clearData();

      expect(_storage.read(key: '_SyncNotifier'), isNull);
    });

    test('корректно сериализует данные синхронно в listenSelf колбэке',
        () async {
      _initStorage();
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final notifier = container.read(_syncProvider.notifier);

      notifier.setValue(55);

      // Данные сериализуются синхронно в listenSelf, write уходит в Future
      await _pumpWrites();

      expect(_storage.writes.length, greaterThanOrEqualTo(2));

      final lastWrite = _storage.writes.last;
      expect(lastWrite.value, {'value': 55});
    });
  });

  group('AsyncPersistenceMixin', () {
    test('build() вызывается, когда в storage нет данных', () async {
      _initStorage();
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      container.read(_asyncProvider);
      await container.read(_asyncProvider.future);

      expect(
        container.read(_asyncProvider),
        isA<AsyncData<_TestState>>().having((d) => d.value, 'value', const _TestState(0)),
      );
    });

    test('восстанавливает состояние из storage как AsyncData', () {
      _initStorage({
        '_AsyncNotifier': {'value': 42},
      });
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final state = container.read(_asyncProvider);

      expect(
        state,
        isA<AsyncData<_TestState>>().having((d) => d.value, 'value', const _TestState(42)),
      );
    });

    test('автоматически сохраняет только AsyncData', () async {
      _initStorage();
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      container.read(_asyncProvider);
      await container.read(_asyncProvider.future);

      _storage.writes.clear();

      final notifier = container.read(_asyncProvider.notifier);
      notifier.setValue(15);

      await _pumpWrites();

      expect(_storage.writes, isNotEmpty);
      expect(_storage.writes.last.value, {'value': 15});
    });

    test('не сохраняет AsyncLoading/AsyncError', () async {
      _initStorage();
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      container.read(_asyncProvider);
      await container.read(_asyncProvider.future);
      await _pumpWrites();

      _storage.writes.clear();

      final notifier = container.read(_asyncProvider.notifier);

      notifier.state = const AsyncLoading();
      await _pumpWrites();

      notifier.state = AsyncError(Exception('test'), StackTrace.current);
      await _pumpWrites();

      final dataWrites = _storage.writes.where((w) => w.value is Map).toList();
      expect(dataWrites, isEmpty);
    });

    test('updateAfterFirstBuild: восстанавливает из кэша, потом вызывает build',
        () async {
      _initStorage({
        '_AsyncUpdateNotifier': {'value': 5},
      });
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      final state = container.read(_asyncUpdateProvider);
      expect(
        state,
        isA<AsyncData<_TestState>>().having((d) => d.value, 'value', const _TestState(5)),
      );

      await _pumpWrites();
      await _pumpWrites();

      final notifier = container.read(_asyncUpdateProvider.notifier);
      expect(notifier.buildCallCount, 1);

      expect(
        container.read(_asyncUpdateProvider),
        isA<AsyncData<_TestState>>().having((d) => d.value, 'value', const _TestState(99)),
      );
    });

    test('pushDataToStorage при mounted записывает текущий state', () async {
      _initStorage();
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      container.read(_asyncProvider);
      await container.read(_asyncProvider.future);

      _storage.writes.clear();

      final notifier = container.read(_asyncProvider.notifier);
      notifier.setValue(33);
      await notifier.pushDataToStorage();

      expect(_storage.writes.last.value, {'value': 33});
    });

    test('clearData удаляет данные из storage', () async {
      _initStorage({
        '_AsyncNotifier': {'value': 1},
      });
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      container.read(_asyncProvider);
      await container.read(_asyncProvider.future);
      await _pumpWrites();

      final notifier = container.read(_asyncProvider.notifier);
      await notifier.clearData();

      expect(_storage.read(key: '_AsyncNotifier'), isNull);
    });
  });

  group('Перезапуск build до его завершения', () {
    test('восстановленная запись достаётся следующему проходу', () async {
      _initStorage({
        '_AsyncWatchingNotifier': {'value': 42},
      });
      _firstPassGate = Completer<void>();
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      // Первый проход читает запись и подвисает.
      container.read(_asyncWatchingProvider);
      // Зависимость меняется, пока он не дошёл до конца: его результат
      // выбрасывают, и до состояния доходит только второй проход.
      container.read(_depProvider.notifier).bump();
      _firstPassGate!.complete();

      final state = await container.read(_asyncWatchingProvider.future);

      expect(container.read(_asyncWatchingProvider.notifier).buildCount, 2);
      expect(state, const _TestState(42));
    });

    test('фолбэк не затирает запись в хранилище', () async {
      _initStorage({
        '_AsyncWatchingNotifier': {'value': 42},
      });
      _firstPassGate = Completer<void>();
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      container.read(_asyncWatchingProvider);
      container.read(_depProvider.notifier).bump();
      _firstPassGate!.complete();
      await container.read(_asyncWatchingProvider.future);
      await _pumpWrites();

      expect(_storage.read(key: '_AsyncWatchingNotifier'), {'value': 42});
    });

    test('updateAfterFirstBuild остаётся одноразовым', () async {
      _initStorage({
        '_AsyncWatchingUpdateNotifier': {'value': 5},
      });
      _firstPassGate = Completer<void>();
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      container.read(_asyncWatchingUpdateProvider);
      container.read(_depProvider.notifier).bump();
      _firstPassGate!.complete();
      await container.read(_asyncWatchingUpdateProvider.future);
      await _pumpWrites();
      await _pumpWrites();

      final notifier =
          container.read(_asyncWatchingUpdateProvider.notifier);
      expect(notifier.buildCount, 2);
      expect(
        notifier.fallbackCallCount,
        1,
        reason: 'обновление после первого build не должно удваиваться',
      );
      expect(
        container.read(_asyncWatchingUpdateProvider),
        isA<AsyncData<_TestState>>()
            .having((d) => d.value, 'value', const _TestState(99)),
      );
    });
  });

  group('Ручное обновление провайдера', () {
    test('не подставляет запись с диска вместо свежих данных', () async {
      _initStorage({
        '_AsyncNotifier': {'value': 42},
      });
      final container = ProviderContainer.test();
      addTearDown(container.dispose);

      expect(await container.read(_asyncProvider.future), const _TestState(42));

      container.invalidate(_asyncProvider);

      expect(
        await container.read(_asyncProvider.future),
        const _TestState(0),
        reason: 'принудительное обновление обязано звать build, а не кеш',
      );
    });
  });

  group('Data safety (listenSelf captures state synchronously)', () {
    test(
      'sync: данные сериализуются синхронно, write проходит даже после dispose',
      () async {
        _initStorage();
        final container = ProviderContainer.test();

        final notifier = container.read(_syncProvider.notifier);
        notifier.setValue(77);

        container.dispose();
        await _pumpWrites();

        final stored = _storage.read(key: '_SyncNotifier');
        expect(stored, {'value': 77});
      },
    );

    test(
      'async: данные сериализуются синхронно, write проходит даже после dispose',
      () async {
        _initStorage();
        final container = ProviderContainer.test();

        container.read(_asyncProvider);
        await container.read(_asyncProvider.future);

        final notifier = container.read(_asyncProvider.notifier);
        notifier.setValue(88);

        container.dispose();
        await _pumpWrites();

        final stored = _storage.read(key: '_AsyncNotifier');
        expect(stored, {'value': 88});
      },
    );
  });
}
