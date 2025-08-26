// Copyright (c) 2018-2022, Larry Aasen.

// ignore_for_file: avoid-non-null-assertion, avoid-unsafe-collection-methods

import 'dart:ui';

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

import '../../parser/sub_parsers/global_source_config/global_source_config.dart';
import '../../parser/sub_parsers/release_config/release_config.dart';
// import '../../parser/models/update_text_config.dart';
// import '../../parser/models/update_text_config_container.dart';
import '../source.dart';
import '../sources.dart';
import 'source_fetcher.dart';
//TODO http.Client и clientHeaders надо бы сделать изменяемыми из вне. Или переписать всё на нативные дартовые клиенты

class GooglePlayFetcher extends SourceReleaseFetcher {
  static const playStorePrefixUrl = 'play.google.com';
  static const playStoreUrlPath = 'store/apps/details';

  /// Provide an HTTP Client that can be replaced for mock testing.
  http.Client get client => http.Client();

  const GooglePlayFetcher();

  @override
  Future<ReleaseConfig?> fetch({
    required Source? source,
    required Locale locale,
    required PackageInfo packageInfo,
  }) async {
    final name = packageInfo.appName;
    final url = _lookupURLById(name: name, locale: locale);

    final response = await client.get(url);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return null;
    }

    final decodedResults = parse(response.body);
    // TODO разобраться почему не срабатывает _releaseNotes
    // final releaseNotes = _releaseNotes(decodedResults);
    final sourceVersion = _version(decodedResults);
    if (sourceVersion == null ||
        sourceVersion <= Version.parse(packageInfo.version)) {
      return null;
    }

    // final updateTextConfig = UpdateTextConfig(
    //   releaseNotes: releaseNotes,
    // );

    return ReleaseConfig(
      version: sourceVersion,
      // text: UpdateTextConfigContainer.fromBase(updateTextConfig),
      sources: [
        ReleaseSourceConfig(
          name: source?.name ?? Sources.googlePlay.name,
          url: source?.url ?? url,
        ),
      ],
    );
  }

  Uri _lookupURLById({
    required String name,
    required Locale locale,
  }) {
    final countryCode = locale.countryCode;
    final languageCode = locale.languageCode;

    final parameters = {'id': name};
    if (countryCode != null && countryCode.isNotEmpty) {
      parameters['gl'] = countryCode;
    }
    if (languageCode.isNotEmpty) {
      parameters['hl'] = languageCode;
    }

    return Uri.https(playStorePrefixUrl, playStoreUrlPath, parameters);
  }

  String? _releaseNotes(Document pageBody) {
    try {
      final sectionElements = pageBody.getElementsByClassName('W4P4ne');
      final releaseNotesElement = sectionElements.firstWhere(
          (elm) => elm.querySelector('.wSaTQd')!.text == "What's New",
          orElse: () => sectionElements.first);
      final rawReleaseNotes = releaseNotesElement
          .querySelector('.PHBdkd')
          ?.querySelector('.DWPxHb');

      return _multilineReleaseNotes(rawReleaseNotes!);
    } catch (_) {}

    try {
      final sectionElementsRedesigned =
          pageBody.querySelectorAll('[itemprop="description"]');
      final rawReleaseNotesRedesigned = sectionElementsRedesigned.lastOrNull;

      return _multilineReleaseNotes(rawReleaseNotesRedesigned!);
    } catch (_) {}

    return null;
  }

  String _multilineReleaseNotes(Element rawReleaseNotes) {
    final releaseNotesSpan = RegExp('>(.*?)</span>');
    final innerHtml = rawReleaseNotes.innerHtml;
    String? releaseNotes = innerHtml;

    if (releaseNotesSpan.hasMatch(innerHtml)) {
      releaseNotes = releaseNotesSpan.firstMatch(innerHtml)!.group(1);
    }

    return releaseNotes!.replaceAll('<br>', '\n');
  }

  Version? _version(Document pageBody) {
    try {
      final additionalInfoElements = pageBody.getElementsByClassName('hAyfc');
      final versionElement = additionalInfoElements.firstWhere(
        (elm) => elm.querySelector('.BgcNfc')!.text == 'Current Version',
      );
      final storeVersion = versionElement.querySelector('.htlgb')!.text;

      return Version.parse(storeVersion);
    } catch (_) {}

    try {
      const patternName = ',"name":"';
      const patternVersion = ',[[["';

      final scripts = pageBody.getElementsByTagName('script');
      final infoElements =
          scripts.where((element) => element.text.contains(patternName));
      final additionalInfoElements = scripts
          .where((element) => element.text.contains('AF_initDataCallback'));
      final additionalInfoElementsFiltered = additionalInfoElements
          .where((element) => element.text.contains(patternVersion));

      final nameElement = infoElements.first.text;
      final storeNameStartIndex =
          nameElement.indexOf(patternName) + patternName.length;
      final storeNameEndIndex = storeNameStartIndex +
          nameElement.substring(storeNameStartIndex).indexOf('"');
      final storeName =
          nameElement.substring(storeNameStartIndex, storeNameEndIndex);
      final storeNameCleaned = storeName.replaceAll(r'\u0027', "'");

      final versionElement = additionalInfoElementsFiltered
          .where((element) => element.text.contains('"$storeNameCleaned"'))
          .first
          .text;
      final storeVersionStartIndex =
          versionElement.lastIndexOf(patternVersion) + patternVersion.length;
      final storeVersionEndIndex = storeVersionStartIndex +
          versionElement.substring(storeVersionStartIndex).indexOf('"');
      final storeVersion = versionElement.substring(
          storeVersionStartIndex, storeVersionEndIndex);

      return Version.parse(storeVersion);
    } catch (_) {}

    return null;
  }
}
