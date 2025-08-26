import 'package:collection/collection.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../shared/models/release/update_data.dart';
import '../shared/models/update_search/update_search_config.dart';
import '../shared/models/update_search/update_search_data.dart';
import '../shared/models/update_search/update_search_result.dart';
import 'update_search_data_defaulter.dart';

class UpdateSearcher {
  const UpdateSearcher({
    required UpdateSearchDataDefaulter searchDataDefaulter,
  }) : _updateSearchDataDefaulter = searchDataDefaulter;

  final UpdateSearchDataDefaulter _updateSearchDataDefaulter;

  /// Ищет последние подходящие обновления для конкретной платформы и источника,
  /// учитывая фильтры по версии и дате.
  ///
  /// При одинаковой версии сортирует по приоритету источника согласно порядку в [UpdateSearchData.sources].
  List<UpdateData> findAvailableUpdates({
    required UpdateSearchData searchData,
    required List<UpdateData> updates,
  }) {
    final sortedUpdates = sortUpdates(updates, searchData);

    final result = <UpdateData>[];

    for (final update in sortedUpdates) {
      if (result.any((e) =>
          e.sourceName == update.sourceName && e.platform == update.platform)) {
        continue;
      }

      if (update.version <= searchData.localVersion) break;
      if (update.date.isAfter(searchData.currentDate)) continue;
      if (update.platform != searchData.platform) continue;
      if (!searchData.sources.any((source) =>
          source.sourceName == update.sourceName &&
          (source.platforms?.contains(update.platform) ?? false))) {
        continue;
      }

      result.add(update);
    }

    return result;
  }

  UpdateData? findMostRelevantUpdate({
    required UpdateSearchData searchData,
    required List<UpdateData> updates,
  }) {
    final availableUpdates = findAvailableUpdates(
      searchData: searchData,
      updates: updates,
    );

    return availableUpdates.firstOrNull;
  }

  List<UpdateData> findCurrentUpdates({
    required UpdateSearchData searchData,
    required List<UpdateData> updates,
  }) {
    final sortedUpdates = sortUpdates(updates, searchData);

    final result = <UpdateData>[];

    for (final update in sortedUpdates) {
      if (result.any((e) =>
          e.sourceName == update.sourceName && e.platform == update.platform)) {
        continue;
      }

      if (update.version < searchData.localVersion) break;
      if (update.version > searchData.localVersion) continue;
      if (update.date.isAfter(searchData.currentDate)) continue;
      if (update.platform != searchData.platform) continue;
      if (!searchData.sources.any((source) =>
          source.sourceName == update.sourceName &&
          (source.platforms?.contains(update.platform) ?? false))) {
        continue;
      }

      result.add(update);
    }

    return result;
  }

  UpdateData? findMostRelevantCurrentUpdate({
    required UpdateSearchData searchData,
    required List<UpdateData> updates,
  }) {
    final currentUpdates = findCurrentUpdates(
      searchData: searchData,
      updates: updates,
    );

    return currentUpdates.firstOrNull;
  }

  UpdateSearchResult searchFull({
    required List<UpdateData> updates,
    required UpdateSearchConfig searchConfig,
    required PackageInfo packageInfo,
  }) {
    var searchData = _updateSearchDataDefaulter.getSearchDataWithDefaults(
      searchConfig: searchConfig,
      packageInfo: packageInfo,
    );

    final updateData = findMostRelevantUpdate(
      searchData: searchData,
      updates: updates,
    );

    final localUpdateData = findMostRelevantCurrentUpdate(
      searchData: searchData,
      updates: updates,
    );

    searchData = searchData.copyWith(
      localReleaseDate: localUpdateData?.date,
      updateReleaseDate: updateData?.date,
    );

    return UpdateSearchResult(
      updateData: updateData,
      localUpdateData: localUpdateData,
      searchData: searchData,
    );
  }

  /// Сортировка: по версии по убыванию, при равной версии — по приоритету источника из [UpdateSearchData.sources]
  List<UpdateData> sortUpdates(
      List<UpdateData> updates, UpdateSearchData searchData) {
    return updates.sorted((a, b) {
      final byVersionDesc = b.version.compareTo(a.version);
      if (byVersionDesc != 0) return byVersionDesc;

      final aIdx =
          searchData.sources.indexWhere((e) => e.sourceName == a.sourceName);
      final bIdx =
          searchData.sources.indexWhere((e) => e.sourceName == b.sourceName);
      final aSafe = aIdx < 0 ? searchData.sources.length : aIdx;
      final bSafe = bIdx < 0 ? searchData.sources.length : bIdx;
      return aSafe.compareTo(bSafe);
    });
  }
}
