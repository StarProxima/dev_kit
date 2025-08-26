import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

import '../shared/entities/update_locale.dart';
import '../shared/entities/update_platform.dart';
import '../shared/entities/update_view_target.dart';
import '../shared/models/update_search/update_search_config.dart';
import '../shared/models/update_search/update_search_data.dart';
import 'update_source_support_checker.dart';

class UpdateSearchDataDefaulter {
  final UpdateSourceSupportChecker _updateSourceChecker;

  const UpdateSearchDataDefaulter({
    required UpdateSourceSupportChecker updateSourceChecker,
  }) : _updateSourceChecker = updateSourceChecker;

  UpdateSearchData getSearchDataWithDefaults({
    required UpdateSearchConfig searchConfig,
    required PackageInfo packageInfo,
  }) {
    final defaultSources = _updateSourceChecker.getDefaultSupportedSources(
      platform: searchConfig.platform ?? UpdatePlatform.current(),
    );

    final defaultSearchData = UpdateSearchData(
      currentDate: DateTime.now(),
      localVersion: Version.parse(packageInfo.version),
      platform: UpdatePlatform.current(),
      sources: defaultSources,
      appStatus: null,
      locale: UpdateLocale.any,
      displayTarget: UpdateViewTarget.any,
      localReleaseDate: packageInfo.updateTime ?? packageInfo.installTime,
      rolloutPointer: 1, // TODO: default value
      segmentationPointer: 1, // TODO: default value
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
}
