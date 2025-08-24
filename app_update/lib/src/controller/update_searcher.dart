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

  ({UpdateData? updateData, UpdateSearchData searchData}) search({
    required List<UpdateData> updates,
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

    final findData = UpdateFindData(
      currentDate: searchConfig.currentDate ?? defaultSearchData.currentDate,
      localVersion: searchConfig.localVersion ?? defaultSearchData.localVersion,
      platform: searchConfig.platform ?? defaultSearchData.platform,
      sources: searchConfig.sources ?? defaultSearchData.sources,
    );

    final updateData = _updateFinder.findMostRelevantUpdate(
      findData: findData,
      updates: updates,
    );

    final currentUpdateData = _updateFinder.findMostRelevantCurrentUpdate(
      findData: findData,
      updates: updates,
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
      localReleaseDate: searchConfig.localReleaseDate ?? currentUpdateData?.date,
      updateReleaseDate: searchConfig.updateReleaseDate ?? updateData?.date,
      customData: searchConfig.customData,
    );

    return (updateData: updateData, searchData: searchData);
  }
}
