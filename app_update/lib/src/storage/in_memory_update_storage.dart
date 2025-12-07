import 'storage_data.dart';
import 'update_storage.dart';

/// In-memory реализация UpdateStorage для тестов
class InMemoryUpdateStorage implements UpdateStorage {
  StorageData _data = StorageData.empty();

  @override
  StorageData load() => _data;

  @override
  Future<void> save(StorageData data) async {
    _data = data;
  }

  @override
  Future<void> clear() async {
    _data = StorageData.empty();
  }
}
