import 'dart:ui';

import 'package:package_info_plus/package_info_plus.dart';

import '../../shared/models/update/update_config.dart';
import '../../shared/update_entities/update_source.dart';
import '../update_config_fetcher_base.dart';

class GooglePlayUpdateConfigFetcher extends UpdateConfigFetcherBySource {
  const GooglePlayUpdateConfigFetcher();

  @override
  UpdateSource get source => UpdateSource.googlePlay;

  @override
  Future<UpdateConfig> fetch({
    required Locale locale,
    required PackageInfo packageInfo,
  }) {
    // TODO: implement fetch
    throw UnimplementedError();
  }
}
