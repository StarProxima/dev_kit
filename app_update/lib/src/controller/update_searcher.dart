import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

import '../finder/update_finder.dart';
import '../shared/models/release/update_data.dart';
import '../shared/models/update_search/update_find_data.dart';
import '../shared/models/update_search/update_search_config.dart';
import '../shared/models/update_search/update_search_data.dart';
import '../shared/update_entities/update_locale.dart';
import '../shared/update_entities/update_platform.dart';
import '../shared/update_entities/update_view_target.dart';

class UpdateSearcher {
  final UpdateFinder _updateFinder;

  const UpdateSearcher({
    required UpdateFinder updateFinder,
  }) : _updateFinder = updateFinder;

  UpdateSearchData searchDataFromConfig({
    required UpdateSearchConfig searchConfig,
    required PackageInfo packageInfo,
  }) {
    final defaultSearchData = UpdateSearchData(
      currentDate: DateTime.now(),
      localVersion: Version.parse(packageInfo.version),
      platform: UpdatePlatform.current(),
      sources: [],
      appStatus: null,
      locale: UpdateLocale.any,
      displayTarget: UpdateViewTarget.any,
      rolloutPointer: 0.5,
      segmentationPointer: 0.5,
      localReleaseDate: null,
      updateReleaseDate: null,
      customData: null,
    );

    final searchData = UpdateSearchData(
      currentDate: searchConfig.currentDate ?? defaultSearchData.currentDate,
      localVersion: searchConfig.localVersion ?? defaultSearchData.localVersion,
      platform: searchConfig.platform ?? defaultSearchData.platform,
      sources: searchConfig.sources ?? defaultSearchData.sources,
      appStatus: searchConfig.appStatus ?? defaultSearchData.appStatus,
      locale: searchConfig.locale ?? defaultSearchData.locale,
      displayTarget: searchConfig.displayTarget ?? defaultSearchData.displayTarget,
      rolloutPointer: searchConfig.rolloutPointer ?? defaultSearchData.rolloutPointer,
      segmentationPointer:
          searchConfig.segmentationPointer ?? defaultSearchData.segmentationPointer,
      localReleaseDate: searchConfig.localReleaseDate ?? defaultSearchData.localReleaseDate,
      updateReleaseDate: searchConfig.updateReleaseDate ?? defaultSearchData.updateReleaseDate,
      customData: searchConfig.customData ?? defaultSearchData.customData,
    );

    return searchData;
  }

  ({UpdateData? updateData, UpdateSearchData searchData}) search({
    required List<UpdateData> updates,
    required UpdateSearchConfig searchConfig,
    required PackageInfo packageInfo,
  }) {
    var searchData = searchDataFromConfig(
      searchConfig: searchConfig,
      packageInfo: packageInfo,
    );

    final findData = UpdateFindData(
      currentDate: searchData.currentDate,
      localVersion: searchData.localVersion,
      platform: searchData.platform,
      sources: searchData.sources,
    );

    final updateData = _updateFinder.findMostRelevantUpdate(
      findData: findData,
      updates: updates,
    );

    final localUpdateData = _updateFinder.findMostRelevantCurrentUpdate(
      findData: findData,
      updates: updates,
    );

    searchData = searchData.copyWith(
      localReleaseDate: localUpdateData?.date,
      updateReleaseDate: updateData?.date,
    );

    return (updateData: updateData, searchData: searchData);
  }
}
