// ignore_for_file: avoid-long-parameter-list

import 'package:app_update/app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

/// Общие утилиты для тестов UpdateSearcher.
abstract final class UpdateSearcherTestUtils {
  static final searchDataDefaulter = UpdateSearchDataDefaulter(
    updateSourceChecker: UpdateSourceSupportCheckerNoOp(),
  );

  static final searcher = UpdateSearcher(
    searchDataDefaulter: searchDataDefaulter,
  );

  static final currentDate = DateTime(2024, 10, 20, 12);

  /// Создает UpdateSearchData для тестов с базовыми параметрами.
  static UpdateSearchData createSearchData({
    required DateTime currentDate,
    required Version localVersion,
    required UpdatePlatform platform,
    required List<UpdateSource> sources,
  }) {
    final searchConfig = UpdateSearchConfig(
      platform: platform,
      sources: sources,
      localVersion: localVersion,
      currentDate: currentDate,
    );

    return searchDataDefaulter.getSearchDataWithDefaults(
      searchConfig: searchConfig,
      packageInfo: PackageInfo(
        appName: 'test',
        packageName: 'test',
        version: '1.0.0',
        buildNumber: '1',
      ),
    );
  }

  /// Хелпер для создания UpdateData.
  static UpdateData createUpdateData(
    String version, {
    required DateTime date,
    required UpdatePlatform platform,
    required UpdateSourceName source,
  }) {
    return UpdateData(
      version: Version.parse(version),
      date: date,
      sourceName: source,
      platform: platform,
      contentRules: null,
      settingsRules: null,
      appSettingsRules: null,
      customData: null,
    );
  }

  /// Создает PackageInfo для тестов.
  static PackageInfo createPackageInfo({
    String appName = 'test',
    String packageName = 'test',
    String version = '1.0.0',
    String buildNumber = '1',
    DateTime? installTime,
    DateTime? updateTime,
  }) {
    return PackageInfo(
      appName: appName,
      packageName: packageName,
      version: version,
      buildNumber: buildNumber,
    );
  }

  /// Создает UpdateSearchConfig для тестов.
  static UpdateSearchConfig createSearchConfig({
    DateTime? currentDate,
    Version? localVersion,
    UpdatePlatform? platform,
    List<UpdateSource>? sources,
  }) {
    return UpdateSearchConfig(
      platform: platform,
      sources: sources,
      localVersion: localVersion,
      currentDate: currentDate,
    );
  }
}
