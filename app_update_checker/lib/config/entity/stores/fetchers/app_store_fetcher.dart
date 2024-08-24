import 'dart:ui';

import 'package:package_info_plus/package_info_plus.dart';

import '../../release.dart';
import '../store.dart';
import 'store_release_fetcher.dart';

class AppStoreFetcher extends StoreFetcher {
  const AppStoreFetcher();

  @override
  Future<Release> fetch({
    required Store store,
    required Locale locale,
    required PackageInfo packageInfo,
  }) {
    // TODO: implement fetch
    throw UnimplementedError();
  }
}
