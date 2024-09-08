import 'dart:ui';

import 'package:package_info_plus/package_info_plus.dart';

import '../../parser/models/release_config.dart';
import '../store.dart';
import 'store_fetcher.dart';

class AppStoreFetcher extends StoreFetcher {
  const AppStoreFetcher();

  @override
  Future<ReleaseConfig> fetch({
    required Store store,
    required Locale locale,
    required PackageInfo packageInfo,
  }) {
    // TODO: implement fetch
    throw UnimplementedError();
  }
}
