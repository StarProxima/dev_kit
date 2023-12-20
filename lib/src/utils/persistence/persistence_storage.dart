import 'dart:async';
import 'dart:io';

import 'package:hive/hive.dart';
// ignore: implementation_imports
import 'package:hive/src/hive_impl.dart';
import 'package:path_provider/path_provider.dart';

/// Интерфейс для работы с хранилищем данных.
abstract class PersistenceStorage {
  dynamic read({required String key, String? id});

  Future<void> write({
    required String key,
    String? id,
    required dynamic value,
  });

  Future<void> delete({required String key, String? id});

  Future<void> clear();

  Future<void> close();

  static late final PersistenceStorage storage;

  static Future<void> init(FutureOr<PersistenceStorage> storage) async {
    PersistenceStorage.storage = await storage;
  }
}

/// Имплементация [PersistenceStorage] для работы с Hive.
class HivePersistenceStorage implements PersistenceStorage {
  HivePersistenceStorage(this._box);

  static final webStorageDirectory = Directory('');

  static late HiveInterface hive;

  static HivePersistenceStorage? _instance;

  final Box<dynamic> _box;

  static Future<HivePersistenceStorage> build([
    Directory? storageDirectory,
  ]) async {
    if (_instance != null) return _instance!;
    hive = HiveImpl();
    Box box;

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

    if (id != null) {
      final data = read(key: key) as Map?;
      return data?[id];
    }
    return _box.get(key);
  }

  @override
  Future<void> write({
    required String key,
    String? id,
    required dynamic value,
  }) async {
    if (id != null) {
      var data = read(key: key) as Map?;
      data ??= {};
      data[id] = value;
      await _box.put(key, data);
      return;
    }
    await _box.put(key, value);
  }

  @override
  Future<void> delete({required String key, String? id}) async {
    if (id != null) {
      final data = (read(key: key) as Map?)?..remove(id);
      await _box.put(key, data);
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
