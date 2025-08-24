import 'package:collection/collection.dart';

import '../shared/models/release/update_data.dart';
import '../shared/models/update_search/update_find_data.dart';

class UpdateFinder {
  const UpdateFinder();

  /// Ищет последние подходящие обновления для конкретной платформы и источника,
  /// учитывая фильтры по версии и дате.
  ///
  /// При одинаковой версии сортирует по приоритету источника согласно порядку в [UpdateFindData.sources].
  List<UpdateData> findAvailableUpdates({
    required UpdateFindData findData,
    required List<UpdateData> updates,
  }) {
    final sortedUpdates = _sortUpdates(updates, findData);

    final result = <UpdateData>[];

    for (final update in sortedUpdates) {
      if (result.any((e) => e.sourceName == update.sourceName && e.platform == update.platform)) {
        continue;
      }

      if (update.version <= findData.localVersion) break;
      if (update.date.isAfter(findData.currentDate)) continue;
      if (update.platform != findData.platform) continue;
      if (!findData.sources.any((source) =>
          source.sourceName == update.sourceName &&
          (source.platforms?.contains(update.platform) ?? false))) {
        continue;
      }

      result.add(update);
    }

    return result;
  }

  UpdateData? findMostRelevantUpdate({
    required UpdateFindData findData,
    required List<UpdateData> updates,
  }) {
    final availableUpdates = findAvailableUpdates(
      findData: findData,
      updates: updates,
    );

    return availableUpdates.firstOrNull;
  }

  List<UpdateData> findCurrentUpdates({
    required UpdateFindData findData,
    required List<UpdateData> updates,
  }) {
    final sortedUpdates = _sortUpdates(updates, findData);

    final result = <UpdateData>[];

    for (final update in sortedUpdates) {
      if (result.any((e) => e.sourceName == update.sourceName && e.platform == update.platform)) {
        continue;
      }

      if (update.version < findData.localVersion) break;
      if (update.version > findData.localVersion) continue;
      if (update.date.isAfter(findData.currentDate)) continue;
      if (update.platform != findData.platform) continue;
      if (!findData.sources.any((source) =>
          source.sourceName == update.sourceName &&
          (source.platforms?.contains(update.platform) ?? false))) {
        continue;
      }

      result.add(update);
    }

    return result;
  }

  UpdateData? findMostRelevantCurrentUpdate({
    required UpdateFindData findData,
    required List<UpdateData> updates,
  }) {
    final currentUpdates = findCurrentUpdates(
      findData: findData,
      updates: updates,
    );

    return currentUpdates.firstOrNull;
  }

  /// Сортировка: по версии по убыванию, при равной версии — по приоритету источника из [UpdateFindData.sources]
  List<UpdateData> _sortUpdates(List<UpdateData> updates, UpdateFindData findData) {
    return updates.sorted((a, b) {
      final byVersionDesc = b.version.compareTo(a.version);
      if (byVersionDesc != 0) return byVersionDesc;

      final aIdx = findData.sources.indexWhere((e) => e.sourceName == a.sourceName);
      final bIdx = findData.sources.indexWhere((e) => e.sourceName == b.sourceName);
      final aSafe = aIdx < 0 ? findData.sources.length : aIdx;
      final bSafe = bIdx < 0 ? findData.sources.length : bIdx;
      return aSafe.compareTo(bSafe);
    });
  }
}
