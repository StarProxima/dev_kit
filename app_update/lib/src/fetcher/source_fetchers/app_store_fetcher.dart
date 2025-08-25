import 'dart:ui';

import 'package:package_info_plus/package_info_plus.dart';

import '../../shared/models/release/update_data.dart';
import '../../shared/update_entities/update_source.dart';
import '../data/app_store_api.dart';
import '../update_config_source_fetcher.dart';

class AppStoreFetcher extends UpdateConfigSourceFetcher {
  final AppStoreApi _api;

  const AppStoreFetcher({AppStoreApi api = const AppStoreApi()}) : _api = api;

  @override
  UpdateSource get source => UpdateSource.appStore;

  @override
  Future<Uri?> getSourceAppUrl({
    required Locale locale,
    required PackageInfo packageInfo,
  }) async {
    final appData = await _api.lookupApp(packageInfo.packageName, locale);
    if (appData == null) return null;

    final appStoreUrlString = _api.buildAppStoreUrl(appData, locale);
    if (appStoreUrlString == null) return null;

    return Uri.tryParse(appStoreUrlString);
  }

  @override
  Future<List<UpdateData>> fetchUpdates({
    required Locale locale,
    required PackageInfo packageInfo,
  }) {
    // TODO: implement fetchUpdates
    throw UnimplementedError();
  }
}
