// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

part of '../checker_config_dto_parser.dart';

class _ReleaseParser {
  _StoreParser get _storeParser => const _StoreParser();
  _ReleaseSettingsParser get _releaseSettingsParser =>
      const _ReleaseSettingsParser();
  _TextParser get _textParser => const _TextParser();
  _VersionParser get _versionParser => const _VersionParser();

  const _ReleaseParser();

  ReleaseDTO? parse(
    Map<String, dynamic> map, {
    required bool isDebug,
  }) {
    // version
    var version = map.remove('version');

    version = _versionParser.parse(
      version,
      isStrict: true,
      isDebug: isDebug,
    );

    if (version == null) return null;
    version as Version;

    // refVersion
    var refVersion = map.remove('ref_version');

    refVersion = _versionParser.parse(
      version,
      isStrict: true,
      isDebug: isDebug,
    );
    refVersion as Version?;

    // buildNumber
    var buildNumber = map.remove('build_number');

    if (buildNumber is! int?) {
      if (isDebug) throw const DtoParserException();
      buildNumber = null;
    }

    // type
    var type = map.remove('type');

    type = ReleaseType.parse(type);
    type as ReleaseType?;

    // releaseSettings
    final releaseSettings = _releaseSettingsParser.parse(map, isDebug: isDebug);

    // releaseNote
    var releaseNote = map.remove('release_note');

    releaseNote = _textParser.parse(releaseNote, isDebug: isDebug);
    releaseNote as Map<Locale, Object>?;
    releaseNote as Map<Locale, String>?;

    // publishDateUtc
    var publishDateUtc = map.remove('publish_date_utc');

    if (publishDateUtc is! String?) {
      if (isDebug) throw const DtoParserException();
      publishDateUtc = null;
    }

    publishDateUtc = DateTime.tryParse(publishDateUtc ?? '');
    publishDateUtc as DateTime?;

    // stores
    var stores = map.remove('stores');

    if (stores is! List<Map<String, dynamic>>?) {
      if (isDebug) throw const DtoParserException();
      stores = null;
    } else if (stores != null) {
      stores = stores
          .map((e) => _storeParser.parse(e, isStrict: false, isDebug: isDebug))
          .toList()
          .whereType<StoreDTO>();
      stores as List<Object>;
      stores as List<StoreDTO>;
    }

    return ReleaseDTO(
      version: version,
      refVersion: refVersion,
      buildNumber: buildNumber,
      type: type,
      title: releaseSettings.title,
      description: releaseSettings.description,
      releaseNote: releaseNote,
      publishDateUtc: publishDateUtc,
      canIgnoreRelease: releaseSettings.canIgnoreRelease,
      reminderPeriod: releaseSettings.reminderPeriod,
      releaseDelay: releaseSettings.releaseDelay,
      stores: stores,
      customData: map,
    );
  }
}
