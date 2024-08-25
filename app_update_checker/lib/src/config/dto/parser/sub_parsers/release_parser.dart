// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

part of '../checker_config_dto_parser.dart';

class _ReleaseParser {
  final bool isDebug;

  _StoreParser get _storeParser => _StoreParser(isDebug: isDebug);

  _DurationParser get _durationParser => _DurationParser(isDebug: isDebug);
  _TextParser get _textParser => _TextParser(isDebug: isDebug);
  _VersionParser get _versionParser => _VersionParser(isDebug: isDebug);

  const _ReleaseParser({required this.isDebug});

  ReleaseDTO? parse(Map<String, dynamic> map) {
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

    version = _versionParser.parse(version, isStrict: true);

    if (version == null) return null;

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

    title = _textParser.parse(title);
    title as Map<Locale, Object>?;
    title as Map<Locale, String>?;

    description = _textParser.parse(description);
    description as Map<Locale, Object>?;
    description as Map<Locale, String>?;

    releaseNote = _textParser.parse(releaseNote);
    releaseNote as Map<Locale, Object>?;
    releaseNote as Map<Locale, String>?;

    final reminderPeriod = _durationParser.parse(hours: reminderPeriodInHours);
    final releaseDelay = _durationParser.parse(hours: releaseDelayInHours);

    if (stores is! List<Map<String, dynamic>>?) {
      if (isDebug) throw const DtoParserException();
      stores = null;
    } else if (stores != null) {
      stores = stores
          .map((e) => _storeParser.parse(e, isStrict: false))
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
}
