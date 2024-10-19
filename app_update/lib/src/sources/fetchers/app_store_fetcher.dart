// Copyright (c) 2018-2023 Larry Aasen

// ignore_for_file: avoid_dynamic_calls

import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

import '../../localizer/models/release.dart';
import '../../localizer/models/update_texts.dart';
import '../../shared/update_status_wrapper.dart';
import '../source.dart';
import 'source_fetcher.dart';

class AppStoreFetcher extends SourceReleaseFetcher {
  /// iTunes Lookup API URL
  static const lookupPrefixURL = 'https://itunes.apple.com/lookup';

  /// Provide an HTTP Client that can be replaced for mock testing.
  http.Client get client => http.Client();

  const AppStoreFetcher();

  @override
  Future<Release?> fetch({
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

    final defaultTexts = UpdateTranslations.defaultTexts.byLocale(locale);
    final settings = UpdateSettings.base(
      translations: UpdateTranslations(
        {
          locale: UpdateTexts(
            title: defaultTexts.title,
            description: defaultTexts.description,
            releaseNote: releaseNotes ?? defaultTexts.releaseNote,
            releaseNoteTitle: defaultTexts.releaseNoteTitle,
            skipButtonText: defaultTexts.skipButtonText,
            laterButtonText: defaultTexts.laterButtonText,
            updateButtonText: defaultTexts.updateButtonText,
          ),
        },
      ),
    );

    return Release(
      version: sourceVersion,
      targetSource: Source.appStore(url: url),
      dateUtc: null,
      settings: settings,
      customData: {},
    );
  }

  Future<Map?> parseByBundleId(
    String bundleId, {
    String? country = 'US',
    String? language = 'en',
    bool useCacheBuster = true,
  }) async {}

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
