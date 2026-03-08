// ignore_for_file: avoid-dynamic, avoid-global-state, avoid-assigning-to-static-field

import 'dart:async';
import 'dart:io';

import 'package:hive/hive.dart';
// ignore: implementation_imports
import 'package:hive/src/hive_impl.dart';
import 'package:path_provider/path_provider.dart';

/// Интерфейс для работы с хранилищем данных.
abstract class PersistenceStorage {
  static late PersistenceStorage storage;

  dynamic read({required String key, String? id});

  Future<void> write({
    required String key,
    String? id,
    required dynamic value,
  });

  Future<void> delete({required String key, String? id});

  Future<void> clear();

  Future<void> close();

  static Future<void> init(FutureOr<PersistenceStorage> storageOrFuture) async {
    storage = storageOrFuture is Future<PersistenceStorage>
        ? await storageOrFuture
        : storageOrFuture;
  }
}

/// Имплементация [PersistenceStorage] для работы с Hive.
class HivePersistenceStorage implements PersistenceStorage {
  static final webStorageDirectory = Directory('');

  static late HiveInterface hive;

  static HivePersistenceStorage? _instance;

  final Box<dynamic> _box;

  const HivePersistenceStorage(this._box);

  static Future<HivePersistenceStorage> build([
    Directory? storageDirectory,
  ]) async {
    if (_instance case final instance?) return instance;

    hive = HiveImpl();
    Box<dynamic> box;

    storageDirectory ??= await getApplicationDocumentsDirectory();

    if (storageDirectory == webStorageDirectory) {
      box = await hive.openBox('storage_box');
    } else {
      hive.init(storageDirectory.path);
      box = await hive.openBox('storage_box');
    }

    return _instance = HivePersistenceStorage(box);
  }

  @override
  dynamic read({required String key, String? id}) {
    if (!_box.isOpen) return null;

    final data = _box.get(key);

    if (id != null) {
      if (data is Map) return data[id];

      return null;
    }

    return data;
  }

  @override
  Future<void> write({
    required String key,
    String? id,
    required dynamic value,
  }) async {
    if (id != null) {
      final existing = _box.get(key);
      final data = existing is Map ? Map.of(existing) : <dynamic, dynamic>{};
      data[id] = value;
      await _box.put(key, data);

      return;
    }
    await _box.put(key, value);
  }

  @override
  Future<void> delete({required String key, String? id}) async {
    if (id != null) {
      final existing = _box.get(key);
      if (existing is Map) {
        final data = Map.of(existing)..remove(id);
        await _box.put(key, data);
      }

      return;
    }
    await _box.delete(key);
  }

  @override
  Future<void> clear() async {
    _instance = null;
    await _box.clear();
  }

  @override
  Future<void> close() async {
    _instance = null;
    await _box.close();
  }
}
