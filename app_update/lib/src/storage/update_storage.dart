import 'storage_data.dart';

/// Интерфейс для хранения данных обновлений
abstract interface class UpdateStorage {
  /// Загружает данные из хранилища
  StorageData load();

  /// Сохраняет данные в хранилище
  Future<void> save(StorageData data);

  /// Полностью очищает хранилище
  Future<void> clear();
}
