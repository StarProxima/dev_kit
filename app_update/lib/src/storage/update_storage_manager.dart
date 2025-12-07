import 'package:pub_semver/pub_semver.dart';

import '../models/release/update.dart';
import 'storage_data.dart';
import 'update_storage.dart';

/// Менеджер для работы с пропущенными и отложенными обновлениями
class UpdateStorageManager {
  final UpdateStorage _storage;

  const UpdateStorageManager(this._storage);

  /// Добавляет обновление в список пропущенных
  ///
  /// Добавляет конкретное обновление в skippedUpdates на skipReleaseDelay.
  /// Также откладывает показ всех обновлений на skipAllReleasesDelay.
  Future<void> onUpdateSkip(Update update) async {
    final data = _storage.load();
    final now = DateTime.now();
    final skipDelay = update.settings.skipReleaseDelay;
    final skipAllDelay = update.settings.skipAllReleasesDelay;
    final skippedUntil = now.add(skipDelay);
    final allUpdatesPostponedUntil = now.add(skipAllDelay);

    // Удаляем существующую запись для этой версии если есть
    final filteredSkippedUpdates = data.skippedUpdates
        .where((item) => item.version != update.version)
        .toList();

    final newData = StorageData(
      allUpdatesPostponedUntil: allUpdatesPostponedUntil,
      postponedUpdates: data.postponedUpdates,
      skippedUpdates: [
        ...filteredSkippedUpdates,
        PostponedUpdate(
          version: update.version,
          postponedUntil: skippedUntil,
        ),
      ],
    );

    await _storage.save(newData);
  }

  /// Откладывает показ обновления
  ///
  /// Откладывает конкретное обновление на postponeReleaseDelay.
  /// Также откладывает показ всех обновлений на postponeAllReleasesDelay.
  Future<void> onUpdatePostpone(Update update) async {
    final data = _storage.load();
    final now = DateTime.now();
    final postponeDelay = update.settings.postponeReleaseDelay;
    final postponeAllDelay = update.settings.postponeAllReleasesDelay;
    final postponedUntil = now.add(postponeDelay);
    final allUpdatesPostponedUntil = now.add(postponeAllDelay);

    // Удаляем существующую запись для этой версии если есть
    final filteredUpdates = data.postponedUpdates
        .where((item) => item.version != update.version)
        .toList();

    final newData = StorageData(
      allUpdatesPostponedUntil: allUpdatesPostponedUntil,
      postponedUpdates: [
        ...filteredUpdates,
        PostponedUpdate(
          version: update.version,
          postponedUntil: postponedUntil,
        ),
      ],
      skippedUpdates: data.skippedUpdates,
    );

    await _storage.save(newData);
  }

  /// Проверяет отложено ли конкретное обновление
  ///
  /// Возвращает [PostponedUpdate] если обновление отложено и срок еще не истек
  PostponedUpdate? getPostponedUpdate(Version version) {
    final data = _storage.load();
    final now = DateTime.now();

    for (final postponed in data.postponedUpdates) {
      if (postponed.version == version &&
          postponed.postponedUntil.isAfter(now)) {
        return postponed;
      }
    }

    return null;
  }

  /// Проверяет пропущено ли конкретное обновление
  ///
  /// Возвращает [PostponedUpdate] если обновление пропущено и срок еще не истек
  PostponedUpdate? getSkippedUpdate(Version version) {
    final data = _storage.load();
    final now = DateTime.now();

    for (final skipped in data.skippedUpdates) {
      if (skipped.version == version && skipped.postponedUntil.isAfter(now)) {
        return skipped;
      }
    }

    return null;
  }

  /// Проверяет отложены ли все обновления
  ///
  /// Возвращает true если allUpdatesPostponedUntil установлен и срок еще не истек
  bool isAllUpdatesPostponed() {
    final data = _storage.load();
    final allUpdatesPostponedUntil = data.allUpdatesPostponedUntil;

    if (allUpdatesPostponedUntil == null) return false;

    final now = DateTime.now();

    return allUpdatesPostponedUntil.isAfter(now);
  }

  /// Очищает устаревшие записи
  ///
  /// Удаляет postponedUpdates и skippedUpdates где postponedUntil < now
  /// Сбрасывает allUpdatesPostponedUntil если срок истек
  Future<void> cleanup() async {
    final data = _storage.load();
    final now = DateTime.now();

    // Фильтруем postponedUpdates - оставляем только те, что еще не истекли
    final activePostponedUpdates = data.postponedUpdates
        .where((item) => item.postponedUntil.isAfter(now))
        .toList();

    // Фильтруем skippedUpdates - оставляем только те, что еще не истекли
    final activeSkippedUpdates = data.skippedUpdates
        .where((item) => item.postponedUntil.isAfter(now))
        .toList();

    // Проверяем allUpdatesPostponedUntil
    final allUpdatesPostponedUntil = data.allUpdatesPostponedUntil;
    final shouldResetAllUpdates = allUpdatesPostponedUntil != null &&
        allUpdatesPostponedUntil.isBefore(now);

    // Сохраняем только если что-то изменилось
    if (activePostponedUpdates.length != data.postponedUpdates.length ||
        activeSkippedUpdates.length != data.skippedUpdates.length ||
        shouldResetAllUpdates) {
      final newData = StorageData(
        allUpdatesPostponedUntil:
            shouldResetAllUpdates ? null : allUpdatesPostponedUntil,
        postponedUpdates: activePostponedUpdates,
        skippedUpdates: activeSkippedUpdates,
      );

      await _storage.save(newData);
    }
  }

  /// Полностью очищает хранилище
  Future<void> clear() async {
    await _storage.clear();
  }
}
