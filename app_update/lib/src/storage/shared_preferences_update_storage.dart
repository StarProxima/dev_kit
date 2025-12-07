import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'storage_data.dart';
import 'update_storage.dart';

/// Реализация UpdateStorage с использованием SharedPreferences
class SharedPreferencesUpdateStorage implements UpdateStorage {
  static const _storageKey = 'app_update_storage_data';
  final SharedPreferences _prefs;

  const SharedPreferencesUpdateStorage(this._prefs);

  @override
  StorageData load() {
    final jsonString = _prefs.getString(_storageKey);

    if (jsonString == null) {
      return StorageData.empty();
    }

    try {
      final jsonDecoded = jsonDecode(jsonString);
      if (jsonDecoded is! Map<String, dynamic>) {
        return StorageData.empty();
      }

      return StorageData.fromJson(jsonDecoded);
    } catch (_) {
      return StorageData.empty();
    }
  }

  @override
  Future<void> save(StorageData data) async {
    final json = data.toJson();
    final jsonString = jsonEncode(json);

    await _prefs.setString(_storageKey, jsonString);
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_storageKey);
  }
}
