// ignore_for_file: prefer-type-over-var, avoid-negated-conditions, avoid-collection-mutating-methods, parameter_assignments, avoid-unnecessary-reassignment

import 'dart:ui';

import '../../entity/release_type.dart';
import '../../entity/version.dart';
import '../exceptions/dto_parser_exception.dart';
import '../models/checker_config_dto.dart';
import '../models/release_dto.dart';
import '../models/release_settings_dto.dart';
import '../models/store_dto.dart';

part 'sub_parsers/duration_parser.dart';
part 'sub_parsers/release_parser.dart';
part 'sub_parsers/release_settings_parser.dart';
part 'sub_parsers/store_parser.dart';
part 'sub_parsers/text_parser.dart';
part 'sub_parsers/version_parser.dart';

class CheckerConfigDTOParser {
  _StoreParser get _storeParser => const _StoreParser();
  _ReleaseSettingsParser get _releaseSettingsParser =>
      const _ReleaseSettingsParser();
  _ReleaseParser get _releaseParser => const _ReleaseParser();

  const CheckerConfigDTOParser();

  CheckerConfigDTO parseConfig(
    Map<String, dynamic> map, {
    required bool isDebug,
  }) {
    // releaseSettings
    var releaseSettings = map.remove('release_settings');

    releaseSettings = _releaseSettingsParser.parse(
      releaseSettings,
      isDebug: isDebug,
    );

    releaseSettings as ReleaseSettingsDTO;

    // stores
    var stores = map.remove('stores');

    if (stores == null) throw const DtoParserException();

    if (stores is! List<Map<String, dynamic>>) {
      if (isDebug) throw const DtoParserException();
      stores = null;
    } else {
      stores = stores
          .map((e) => _storeParser.parse(e, isStrict: true, isDebug: isDebug))
          .toList()
          .whereType<StoreDTO>();
    }
    stores as List<Object>;
    stores as List<StoreDTO>;

    // releases
    var releases = map.remove('releases');

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
      releaseSettings: releaseSettings,
      stores: stores,
      releases: releases,
      customData: map,
    );
  }
}
