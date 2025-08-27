import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

import '../entities/app_status.dart';
import '../entities/update_locale.dart';
import '../entities/update_platform.dart';
import '../entities/update_source.dart';
import '../entities/update_view_target.dart';
import '../models/update_search/update_search_config.dart';
import '../models/update_search/update_search_data.dart';
import 'update_supported_sources_checker.dart';

class UpdateSearchDataDefaulter {
  final UpdateSupportedSourcesChecker _updateSourceChecker;

  const UpdateSearchDataDefaulter({
    required UpdateSupportedSourcesChecker updateSourceChecker,
  }) : _updateSourceChecker = updateSourceChecker;

  UpdateSearchData getSearchDataWithDefaults({
    required UpdateSearchConfig searchConfig,
    required PackageInfo packageInfo,
  }) {
    if (_hasAnyInSearch(searchConfig)) {
      throw ArgumentError('Any value in search config is not allowed');
    }

    final defaultSources = _updateSourceChecker.getDefaultSupportedSources(
      platform: searchConfig.platform ?? UpdatePlatform.current(),
    );

    final defaultSearchData = UpdateSearchData(
      platform: UpdatePlatform.current(),
      sources: defaultSources,
      localVersion:
          Version.parse('${packageInfo.version}+${packageInfo.buildNumber}'),
      displayTarget: UpdateViewTarget.any,
      appStatus: null,
      locale: UpdateLocale.any,
      currentDate: DateTime.now(),
      localReleaseDate: packageInfo.updateTime ?? packageInfo.installTime,
      updateReleaseDate: null,
      // TODO: default value
      segmentationPointer: 1,
      // TODO: default value
      rolloutPointer: 1,
      appName: packageInfo.appName,
      appPackageName: packageInfo.packageName,
      customData: null,
    );

    final searchData = UpdateSearchData(
      platform: searchConfig.platform ?? defaultSearchData.platform,
      sources: searchConfig.sources ?? defaultSearchData.sources,
      localVersion: searchConfig.localVersion ?? defaultSearchData.localVersion,
      displayTarget:
          searchConfig.displayTarget ?? defaultSearchData.displayTarget,
      appStatus: searchConfig.appStatus ?? defaultSearchData.appStatus,
      locale: searchConfig.locale ?? defaultSearchData.locale,
      currentDate: searchConfig.currentDate ?? defaultSearchData.currentDate,
      localReleaseDate:
          searchConfig.localReleaseDate ?? defaultSearchData.localReleaseDate,
      updateReleaseDate:
          searchConfig.updateReleaseDate ?? defaultSearchData.updateReleaseDate,
      segmentationPointer: searchConfig.segmentationPointer ??
          defaultSearchData.segmentationPointer,
      rolloutPointer:
          searchConfig.rolloutPointer ?? defaultSearchData.rolloutPointer,
      appName: searchConfig.appName ?? defaultSearchData.appName,
      appPackageName:
          searchConfig.appPackageName ?? defaultSearchData.appPackageName,
      customData: searchConfig.customData ?? defaultSearchData.customData,
    );

    return searchData;
  }

  static bool _hasAnyInSearch(UpdateSearchConfig searchConfig) {
    return searchConfig.appStatus == AppStatus.any ||
        searchConfig.locale == UpdateLocale.any ||
        searchConfig.displayTarget == UpdateViewTarget.any ||
        searchConfig.platform == UpdatePlatform.any ||
        (searchConfig.sources ?? []).contains(UpdateSource.any);
  }
}
