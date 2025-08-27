import 'dart:ui';

import 'package:package_info_plus/package_info_plus.dart';

import '../../entities/update_source.dart';
import '../../models/release/update_data.dart';
import '../update_config_source_fetcher.dart';

class GooglePlayFetcher extends UpdateConfigSourceFetcher {
  const GooglePlayFetcher();

  @override
  UpdateSource get source => UpdateSource.googlePlay;

  @override
  Future<Uri?> getSourceAppUrl({
    required Locale locale,
    required PackageInfo packageInfo,
  }) async {
    final countryCode = locale.countryCode;
    final languageCode = locale.languageCode;

    final parameters = <String, String>{'id': packageInfo.packageName};

    if (countryCode != null && countryCode.isNotEmpty) {
      parameters['gl'] = countryCode;
    }
    if (languageCode.isNotEmpty) {
      parameters['hl'] = languageCode;
    }

    return Uri.https(
      'play.google.com',
      'store/apps/details',
      parameters,
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
