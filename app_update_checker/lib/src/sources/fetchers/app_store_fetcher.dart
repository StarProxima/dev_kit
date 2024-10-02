import 'dart:ui';

import 'package:package_info_plus/package_info_plus.dart';

import '../../localizer/models/release.dart';
import '../source.dart';
import 'source_fetcher.dart';

class AppStoreFetcher extends SourceReleaseFetcher {
  const AppStoreFetcher();

  @override
  Future<Release> fetch({
    required Source source,
    required Locale locale,
    required PackageInfo packageInfo,
  }) {
    // TODO: implement fetch
    throw UnimplementedError();
  }
}
