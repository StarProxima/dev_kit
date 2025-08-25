import 'dart:ui';

import 'package:package_info_plus/package_info_plus.dart';

import '../../shared/models/release/update_data.dart';
import '../../shared/update_entities/update_source.dart';
import '../update_config_fetcher_base.dart';

class GooglePlayFetcher extends UpdateConfigFetcherBySource {
  const GooglePlayFetcher();

  @override
  UpdateSource get source => UpdateSource.googlePlay;

  @override
  Future<Uri?> getSourceAppUrl({
    required Locale locale,
    required PackageInfo packageInfo,
  }) {
    // TODO: implement fetchUrl
    throw UnimplementedError();
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
