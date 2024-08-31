// ignore_for_file: prefer-type-over-var, avoid-negated-conditions, avoid-collection-mutating-methods, parameter_assignments, avoid-unnecessary-reassignment

import 'dart:ui';

import '../../entity/version.dart';
import '../models/checker_config_dto.dart';

import '../models/dto_parser_exception.dart';
import '../models/release_dto.dart';
import '../models/store_dto.dart';

part 'sub_parsers/duration_parser.dart';
part 'sub_parsers/release_parser.dart';
part 'sub_parsers/store_parser.dart';
part 'sub_parsers/text_parser.dart';
part 'sub_parsers/version_parser.dart';

class CheckerConfigDTOParser {
  _StoreParser get _storeParser => const _StoreParser();
  _DurationParser get _durationParser => const _DurationParser();
  _VersionParser get _versionParser => const _VersionParser();
  _ReleaseParser get _releaseParser => const _ReleaseParser();

  const CheckerConfigDTOParser();

  CheckerConfigDTO parseConfig(
    Map<String, dynamic> map, {
    required bool isDebug,
  }) {
    final reminderPeriodInHours = map.remove('reminderPeriodInHours');
    final releaseDelayInHours = map.remove('releaseDelayInHours');
    var deprecatedBeforeVersion = map.remove('deprecatedBeforeVersion');
    var requiredMinimumVersion = map.remove('requiredMinimumVersion');
    var stores = map.remove('stores');
    var releases = map.remove('releases');

    final reminderPeriod =
        _durationParser.parse(hours: reminderPeriodInHours, isDebug: isDebug);
    final releaseDelay =
        _durationParser.parse(hours: releaseDelayInHours, isDebug: isDebug);

    deprecatedBeforeVersion = _versionParser.parse(
      deprecatedBeforeVersion,
      isStrict: false,
      isDebug: isDebug,
    );
    deprecatedBeforeVersion as Version?;

    requiredMinimumVersion = _versionParser.parse(
      requiredMinimumVersion,
      isStrict: false,
      isDebug: isDebug,
    );
    requiredMinimumVersion as Version?;

    if (stores == null) throw const DtoParserException();

    if (stores is! List<Map<String, dynamic>>) {
      if (isDebug) throw const DtoParserException();
      stores = null;
    } else {
      stores = stores
          .map((e) => _storeParser.parse(e, isStrict: false, isDebug: isDebug))
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
      releases = releases
          .map((e) => _releaseParser.parse(e, isDebug: isDebug))
          .toList()
          .whereType<ReleaseDTO>();
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
}
