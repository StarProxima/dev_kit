import 'dart:ui';

import 'package:package_info_plus/package_info_plus.dart';

import '../../shared/entities/update_source.dart';
import '../../shared/models/release/update_data.dart';
import '../update_config_source_fetcher.dart';

class RuStoreFetcher extends UpdateConfigSourceFetcher {
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
