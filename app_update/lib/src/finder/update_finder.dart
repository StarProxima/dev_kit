import 'package:collection/collection.dart';
import 'package:pub_semver/pub_semver.dart';

import '../shared/models/release/update_data.dart';
import '../shared/update_entities/update_platform.dart';
import '../shared/update_entities/update_source.dart';

class UpdateFinder {
  const UpdateFinder();

  /// Ищет последние подходящие обновления для конкретной платформы и источника,
  /// учитывая фильтры по версии и дате.
  ///
  /// При одинаковой версии сортирует по приоритету источника согласно порядку в [sources].
  List<UpdateData> findAvailableUpdates({
    required DateTime currentDate,
    required Version localVersion,
    required UpdatePlatform platform,
    required List<UpdateSource> sources,
    required List<UpdateData> updates,
  }) {
    // Сортировка: по версии по убыванию, при равной версии — по приоритету источника из [sources]
    final sortedUpdates = updates.sorted((a, b) {
      final byVersionDesc = b.version.compareTo(a.version);
      if (byVersionDesc != 0) return byVersionDesc;

      final aIdx = sources.indexWhere((e) => e.sourceName == a.sourceName);
      final bIdx = sources.indexWhere((e) => e.sourceName == b.sourceName);
      final aSafe = aIdx < 0 ? sources.length : aIdx;
      final bSafe = bIdx < 0 ? sources.length : bIdx;
      return aSafe.compareTo(bSafe);
    });

    final result = <UpdateData>[];

    for (final update in sortedUpdates) {
      if (result.any((e) => e.sourceName == update.sourceName && e.platform == update.platform)) {
        continue;
      }

      if (update.version <= localVersion) break;
      if (update.date?.isAfter(currentDate) ?? false) continue;
      if (update.platform != platform) continue;
      if (!sources.any((source) =>
          source.sourceName == update.sourceName &&
          (source.platforms?.contains(update.platform) ?? false))) {
        continue;
      }

      result.add(update);
    }

    return result;
  }

  UpdateData? findMostRelevantUpdate({
    required DateTime currentDate,
    required Version localVersion,
    required UpdatePlatform platform,
    required List<UpdateSource> sources,
    required List<UpdateData> updates,
  }) {
    final availableUpdates = findAvailableUpdates(
      currentDate: currentDate,
      localVersion: localVersion,
      platform: platform,
      sources: sources,
      updates: updates,
    );

    return availableUpdates.firstOrNull;
  }

  List<UpdateData> findCurrentUpdates({
    required DateTime currentDate,
    required Version localVersion,
    required UpdatePlatform platform,
    required List<UpdateSource> sources,
    required List<UpdateData> updates,
  }) {
    // Сортировка: по версии по убыванию, при равной версии — по приоритету источника из [sources]
    final sortedUpdates = updates.sorted((a, b) {
      final byVersionDesc = b.version.compareTo(a.version);
      if (byVersionDesc != 0) return byVersionDesc;

      final aIdx = sources.indexWhere((e) => e.sourceName == a.sourceName);
      final bIdx = sources.indexWhere((e) => e.sourceName == b.sourceName);
      final aSafe = aIdx < 0 ? sources.length : aIdx;
      final bSafe = bIdx < 0 ? sources.length : bIdx;
      return aSafe.compareTo(bSafe);
    });

    final result = <UpdateData>[];

    for (final update in sortedUpdates) {
      if (result.any((e) => e.sourceName == update.sourceName && e.platform == update.platform)) {
        continue;
      }

      if (update.version < localVersion) break;
      if (update.version > localVersion) continue;
      if (update.date?.isAfter(currentDate) ?? false) continue;
      if (update.platform != platform) continue;
      if (!sources.any((source) =>
          source.sourceName == update.sourceName &&
          (source.platforms?.contains(update.platform) ?? false))) {
        continue;
      }

      result.add(update);
    }

    return result;
  }

  UpdateData? findMostRelevantCurrentUpdate({
    required DateTime currentDate,
    required Version localVersion,
    required UpdatePlatform platform,
    required List<UpdateSource> sources,
    required List<UpdateData> updates,
  }) {
    final currentUpdates = findCurrentUpdates(
      currentDate: currentDate,
      localVersion: localVersion,
      platform: platform,
      sources: sources,
      updates: updates,
    );

    return currentUpdates.firstOrNull;
  }
}
