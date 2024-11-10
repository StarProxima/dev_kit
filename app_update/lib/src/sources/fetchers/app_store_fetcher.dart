// Copyright (c) 2018-2023 Larry Aasen

// ignore_for_file: avoid_dynamic_calls

import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

import '../../linker/models/release_data.dart';
import '../../parser/models/update_text_config.dart';
import '../../shared/update_settings_container.dart';
import '../../shared/update_text_container.dart';
import '../source.dart';
import 'source_fetcher.dart';

class AppStoreFetcher extends SourceReleaseFetcher {
  static const lookupPrefixURL = 'https://itunes.apple.com/lookup';

  /// Provide an HTTP Client that can be replaced for mock testing.
  http.Client get client => http.Client();

  const AppStoreFetcher();

  @override
  Future<ReleaseData?> fetch({
    required Source source,
    required Locale locale,
    required PackageInfo packageInfo,
  }) async {
    final bundleId = DateTime.now().toString(); // TODO откуда
    final url =
        _lookupURL({'bundleId': bundleId, 'country': locale.countryCode?.toUpperCase(), 'lang': locale.languageCode});
    // final url = _lookupURL({'id': id, 'country': country.toUpperCase()}, useCacheBuster: useCacheBuster);
    // TODO parseById?

    final response = await client.get(url);
    final decodedResults = _decodeResults(response);
    if (decodedResults == null) return null;

    final releaseNotes = _releaseNotes(decodedResults);
    final sourceVersion = _version(decodedResults);
    if (sourceVersion == null || sourceVersion <= Version.parse(packageInfo.version)) return null;

    final updateTextConfig = UpdateTextConfig(
      releaseNotes: releaseNotes,
    );

    return ReleaseData(
      version: sourceVersion,
      source: Source.appStore(url: url),
      date: null,
      text: UpdateTextConfigContainer.fromUpdateTextConfig(updateTextConfig),
      settings: const UpdateSettingsDataContainer({}),
      customData: {},
    );
  }

  Future<Map?> parseByBundleId(
    String bundleId, {
    String? country = 'US',
    String? language = 'en',
    bool useCacheBuster = true,
  }) async {
    // TODO write this
  }

  /// Look up URL by QSP.
  Uri _lookupURL(Map<String, String?> qsp, {bool useCacheBuster = true}) {
    if (useCacheBuster) {
      qsp.addAll({'_cb': DateTime.now().microsecondsSinceEpoch.toString()});
    }

    return Uri.https(lookupPrefixURL, '', qsp);
  }

  Map? _decodeResults(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return null;
    }

    final jsonResponse = response.body;
    if (jsonResponse.isEmpty) return null;

    final decodedResults = json.decode(jsonResponse);
    if (decodedResults is Map) {
      final resultCount = decodedResults['resultCount'];
      if (resultCount == 0) return null;

      return decodedResults;
    }
  }

  /// Return field releaseNotes from iTunes results.
  String? _releaseNotes(Map response) {
    try {
      return response['results'][0]['releaseNotes'];
    } catch (_) {}

    return null;
  }

  /// Return field version from iTunes results.
  Version? _version(Map response) {
    try {
      return Version.parse(response['results'][0]['version']);
    } catch (_) {}

    return null;
  }
}
