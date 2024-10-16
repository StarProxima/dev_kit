// Copyright (c) 2018-2022, Larry Aasen.

import 'dart:io';
import 'dart:ui';

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

import '../../localizer/models/release.dart';
import '../../localizer/models/update_texts.dart';
import '../../shared/update_status_wrapper.dart';
import '../source.dart';
import 'source_fetcher.dart';
//TODO http.Client и clientHeaders надо бы сделать изменяемыми из вне

class GooglePlayFetcher extends SourceReleaseFetcher {
  static const playStorePrefixURL = 'play.google.com/store/apps/details';

  const GooglePlayFetcher();

  Uri lookupURLById({
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

    return Uri.https(playStorePrefixURL, '', parameters);
  }

  @override
  Future<Release> fetch({
    required Source source,
    required Locale locale,
    required PackageInfo packageInfo,
  }) async {
    final name = packageInfo.appName;
    final url = lookupURLById(name: name, locale: locale);
    final client = http.Client();

    final response = await client.get(url);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(response.statusCode.toString(), uri: url);
    }

    final decodedResults = parse(response.body);
    final releaseNotesText = _releaseNotes(decodedResults);
    final versionText = _version(decodedResults);

    final defaultTexts = UpdateTranslations.defaultTexts.byLocale(locale);
    final settings = UpdateSettings.base(
      translations: UpdateTranslations(
        {
          locale: UpdateTexts(
            title: defaultTexts.title,
            description: defaultTexts.description,
            releaseNote: releaseNotesText ?? defaultTexts.releaseNote,
            releaseNoteTitle: defaultTexts.releaseNoteTitle,
            skipButtonText: defaultTexts.skipButtonText,
            laterButtonText: defaultTexts.laterButtonText,
            updateButtonText: defaultTexts.updateButtonText,
          ),
        },
      ),
    );

    return Release(
      version: versionText ?? Version(0, 0, 0),
      targetSource: Source.googlePlay(url: url),
      dateUtc: null,
      settings: settings,
      customData: {},
    );
  }

  String? _releaseNotes(Document pageBody) {
    try {
      final sectionElements = pageBody.getElementsByClassName('W4P4ne');
      final releaseNotesElement = sectionElements
          .firstWhere((elm) => elm.querySelector('.wSaTQd')!.text == "What's New", orElse: () => sectionElements[0]);
      final rawReleaseNotes = releaseNotesElement.querySelector('.PHBdkd')?.querySelector('.DWPxHb');

      return _multilineReleaseNotes(rawReleaseNotes!);
    } catch (_) {}

    try {
      final sectionElementsRedesigned = pageBody.querySelectorAll('[itemprop="description"]');
      final rawReleaseNotesRedesigned = sectionElementsRedesigned.lastOrNull;
      return _multilineReleaseNotes(rawReleaseNotesRedesigned!);
    } catch (_) {}
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
      final infoElements = scripts.where((element) => element.text.contains(patternName));
      final additionalInfoElements = scripts.where((element) => element.text.contains('AF_initDataCallback'));
      final additionalInfoElementsFiltered =
          additionalInfoElements.where((element) => element.text.contains(patternVersion));

      final nameElement = infoElements.first.text;
      final storeNameStartIndex = nameElement.indexOf(patternName) + patternName.length;
      final storeNameEndIndex = storeNameStartIndex + nameElement.substring(storeNameStartIndex).indexOf('"');
      final storeName = nameElement.substring(storeNameStartIndex, storeNameEndIndex);
      final storeNameCleaned = storeName.replaceAll(r'\u0027', "'");

      final versionElement =
          additionalInfoElementsFiltered.where((element) => element.text.contains('"$storeNameCleaned"')).first.text;
      final storeVersionStartIndex = versionElement.lastIndexOf(patternVersion) + patternVersion.length;
      final storeVersionEndIndex =
          storeVersionStartIndex + versionElement.substring(storeVersionStartIndex).indexOf('"');
      final storeVersion = versionElement.substring(storeVersionStartIndex, storeVersionEndIndex);

      return Version.parse(storeVersion);
    } catch (_) {}
  }
}
