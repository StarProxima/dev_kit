// Copyright (c) 2018-2023 Larry Aasen

// ignore_for_file: avoid_dynamic_calls, avoid-collection-mutating-methods, avoid-unnecessary-collections, prefer-boolean-prefixes

import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

import '../../parser/models/update_text_config_container.dart';
import '../../parser/sub_parsers/global_source_config/global_source_config.dart';
import '../../parser/sub_parsers/release_config/release_config.dart';
import '../../parser/sub_parsers/update_content_config/update_content_config.dart';
import '../source.dart';
import '../sources.dart';
import 'source_fetcher.dart';

class AppStoreFetcher extends SourceReleaseFetcher {
  static const lookupPrefixURL = 'itunes.apple.com';

  http.Client get client => http.Client();

  const AppStoreFetcher();

  @override
  Future<ReleaseConfig?> fetch({
    required Source? source,
    required Locale locale,
    required PackageInfo packageInfo,
  }) async {
    final bundleId = packageInfo.packageName;
    final url = _lookupURL(bundleId, locale);

    final response = await client.get(url);
    final decodedResults = _decodeResults(response);
    if (decodedResults == null) return null;

    final releaseNotes = _releaseNotes(decodedResults);
    final sourceVersion = _version(decodedResults);
    if (sourceVersion == null ||
        sourceVersion <= Version.parse(packageInfo.version)) {
      return null;
    }

    final updateTextConfig = UpdateContentConfig(
      releaseNotes: releaseNotes,
    );

    return ReleaseConfig(
      version: sourceVersion,
      text: UpdateTextConfigContainer.fromBase(updateTextConfig),
      sourceIs: [
        ReleaseSourceConfig(
          name: source?.name ?? Sources.appStore.name,
          url: source?.url ??
              Uri.tryParse(_appStoreUrl(decodedResults, locale) ?? ''),
        ),
      ],
    );
  }

  /// Look up URL by QSP.
  Uri _lookupURL(String bundleId, Locale locale, {bool useCacheBuster = true}) {
    final qsp = {
      'bundleId': bundleId,
      'country': locale.countryCode?.toUpperCase(),
      'lang': locale.languageCode
    };
    if (useCacheBuster) {
      qsp.addAll({'_cb': DateTime.now().microsecondsSinceEpoch.toString()});
    }

    return Uri.https(lookupPrefixURL, 'lookup', qsp);
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

  /// Return field trackViewUrl from iTunes results and change locale.
  String? _appStoreUrl(Map response, Locale locale) {
    try {
      String? appStoreUrl = response['results'][0]['trackViewUrl'];
      if (appStoreUrl == null) return null;

      final languageCode = locale.languageCode;
      appStoreUrl = appStoreUrl.replaceFirst(
          RegExp(r'apps\.apple\.com\/.*\/app'),
          'apps.apple.com/$languageCode/app');

      return appStoreUrl;
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
