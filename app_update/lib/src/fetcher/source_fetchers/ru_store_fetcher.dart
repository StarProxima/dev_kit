import 'dart:ui';

import 'package:package_info_plus/package_info_plus.dart';

import '../../shared/models/release/update_data.dart';
import '../../shared/update_entities/update_source.dart';
import '../update_config_fetcher_base.dart';

class RuStoreFetcher extends UpdateConfigFetcherBySource {
  const RuStoreFetcher();

  @override
  UpdateSource get source => UpdateSource.ruStore;

  @override
  Future<Uri?> getSourceAppUrl({
    required Locale locale,
    required PackageInfo packageInfo,
  }) async {
    return Uri.https(
      'apps.rustore.ru',
      'app/${packageInfo.packageName}',
    );
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
