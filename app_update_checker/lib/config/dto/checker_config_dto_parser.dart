// ignore_for_file: prefer-type-over-var, avoid-negated-conditions, avoid-collection-mutating-methods, parameter_assignments, avoid-unnecessary-reassignment

import 'dart:ui';

import '../entity/version.dart';
import 'checker_config_dto.dart';
import 'dto_parser_exception.dart';
import 'release_dto.dart';
import 'store_dto.dart';

class CheckerConfigDTOParser {
  final bool isDebug;

  const CheckerConfigDTOParser({required this.isDebug});

  CheckerConfigDTO parseConfig(Map<String, dynamic> map) {
    final reminderPeriodInHours = map.remove('reminderPeriodInHours');
    final releaseDelayInHours = map.remove('releaseDelayInHours');
    var deprecatedBeforeVersion = map.remove('deprecatedBeforeVersion');
    var requiredMinimumVersion = map.remove('requiredMinimumVersion');
    var stores = map.remove('stores');
    var releases = map.remove('releases');

    final reminderPeriod = parseHours(reminderPeriodInHours);
    final releaseDelay = parseHours(releaseDelayInHours);

    deprecatedBeforeVersion = parseVersion(
      deprecatedBeforeVersion,
      isStrict: false,
    );
    deprecatedBeforeVersion as Version?;

    requiredMinimumVersion = parseVersion(
      requiredMinimumVersion,
      isStrict: false,
    );
    requiredMinimumVersion as Version?;

    if (stores == null) throw const DtoParserException();

    if (stores is! List<Map<String, dynamic>>) {
      if (isDebug) throw const DtoParserException();
      stores = null;
    } else {
      stores = stores
          .map((e) => parseStore(e, isStrict: false))
          .toList()
          .whereType<StoreDTO>();
    }
    stores as List<Object>;
    stores as List<StoreDTO>;

    if (releases == null) throw const DtoParserException();

    if (releases is! List<Map<String, dynamic>>) {
      if (isDebug) throw const DtoParserException();
      releases = null;
    } else {
      releases = releases.map(parseRelease).toList().whereType<ReleaseDTO>();
    }

    releases as List<Object>;
    releases as List<ReleaseDTO>;

    return CheckerConfigDTO(
      reminderPeriod: reminderPeriod,
      releaseDelay: releaseDelay,
      deprecatedBeforeVersion: deprecatedBeforeVersion,
      requiredMinimumVersion: requiredMinimumVersion,
      stores: stores,
      releases: releases,
      customData: map,
    );
  }

  StoreDTO? parseStore(
    Map<String, dynamic> map, {
    required bool isStrict,
  }) {
    var name = map.remove('name');
    var url = map.remove('url');
    var platforms = map.remove('platforms');

    if (name is! String?) {
      if (isDebug) throw const DtoParserException();
      name = null;
    }

    if (name == null) {
      if (isDebug) throw const DtoParserException();

      return null;
    }

    if (url is! String?) {
      if (isDebug) throw const DtoParserException();
      url = null;
    }

    if (isStrict && url == null) return null;

    url = url != null ? Uri.tryParse(url) : null;

    if (platforms is! List<String>?) {
      if (isDebug) throw const DtoParserException();
      platforms = null;
    }

    return StoreDTO(
      name: name,
      url: url,
      platforms: platforms,
      customData: map,
    );
  }

  // ignore: avoid-unnecessary-nullable-return-type
  ReleaseDTO? parseRelease(Map<String, dynamic> map) {
    var version = map.remove('version');
    var isActive = map.remove('isActive');
    var isRequired = map.remove('isRequired');
    var isBroken = map.remove('isBroken');
    var title = map.remove('title');
    var description = map.remove('description');
    var releaseNote = map.remove('releaseNote');
    final reminderPeriodInHours = map.remove('reminderPeriodInHours');
    final releaseDelayInHours = map.remove('releaseDelayInHours');
    var stores = map.remove('stores');

    version = parseVersion(version, isStrict: true);
    version as Version;

    if (isActive is! bool?) {
      if (isDebug) throw const DtoParserException();
      isActive = null;
    }

    if (isRequired is! bool?) {
      if (isDebug) throw const DtoParserException();
      isRequired = null;
    }

    if (isBroken is! bool?) {
      if (isDebug) throw const DtoParserException();
      isBroken = null;
    }

    title = parseText(title);
    title as Map<Locale, Object>?;
    title as Map<Locale, String>?;

    description = parseText(description);
    description as Map<Locale, Object>?;
    description as Map<Locale, String>?;

    releaseNote = parseText(releaseNote);
    releaseNote as Map<Locale, Object>?;
    releaseNote as Map<Locale, String>?;

    final reminderPeriod = parseHours(reminderPeriodInHours);
    final releaseDelay = parseHours(releaseDelayInHours);

    if (stores is! List<Map<String, dynamic>>?) {
      if (isDebug) throw const DtoParserException();
      stores = null;
    } else if (stores != null) {
      stores = stores
          .map((e) => parseStore(e, isStrict: false))
          .toList()
          .whereType<StoreDTO>();
      stores as List<Object>;
      stores as List<StoreDTO>;
    }

    return ReleaseDTO(
      version: version,
      isActive: isActive,
      isRequired: isRequired,
      isBroken: isBroken,
      title: title,
      description: description,
      releaseNote: releaseNote,
      reminderPeriod: reminderPeriod,
      releaseDelay: releaseDelay,
      stores: stores,
      customData: map,
    );
  }

  // ignore: avoid-dynamic
  Map<Locale, String> parseText(dynamic textWithLocales) {
    var text = textWithLocales;
    if (text is! Map<String, dynamic>?) {
      if (text is String) {
        return {const Locale('en'): text};
      }

      if (isDebug) throw const DtoParserException();
      text = null;
    } else if (text != null) {
      text = Map<Locale, String>.fromEntries(
        text.entries.map((e) => MapEntry(Locale(e.key), e.value)),
      );
      text as Map<Locale, Object>?;
      text as Map<Locale, String>?;
    }

    return text;
  }

  // ignore: avoid-dynamic
  Duration? parseHours(dynamic hours) {
    if (hours is! int?) {
      if (isDebug) throw const DtoParserException();
      hours = null;
    } else if (hours != null && hours < 0) {
      throw const DtoParserException();
    }

    final duraton = hours != null ? Duration(hours: hours) : null;

    return duraton;
  }

  Version? parseVersion(
    // ignore: avoid-dynamic
    dynamic version, {
    required bool isStrict,
  }) {
    if (version is! String?) {
      if (isDebug) throw const DtoParserException();
      version = null;
    }
    if (version == null) {
      if (isStrict) throw const DtoParserException();

      return null;
    }

    try {
      return Version.parse(version);
    } catch (e) {
      if (isDebug) rethrow;

      return null;
    }
  }
}
