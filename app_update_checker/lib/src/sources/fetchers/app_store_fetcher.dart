import 'dart:ui';

import 'package:package_info_plus/package_info_plus.dart';

import '../../parser/models/release_config.dart';
import '../source.dart';
import 'source_fetcher.dart';

class AppStoreFetcher extends SourceReleaseFetcher {
  const AppStoreFetcher();

  @override
  Future<ReleaseConfig> fetch({
    required Source source,
    required Locale locale,
    required PackageInfo packageInfo,
  }) {
    // TODO: implement fetch
    throw UnimplementedError();
  }
}
