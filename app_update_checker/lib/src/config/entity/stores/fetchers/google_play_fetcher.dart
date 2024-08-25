import 'dart:ui';

import 'package:package_info_plus/package_info_plus.dart';

import '../../release.dart';
import '../store.dart';
import 'store_fetcher.dart';

class GooglePlayFetcher extends StoreFetcher {
  const GooglePlayFetcher();

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
