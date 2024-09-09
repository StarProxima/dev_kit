// ignore_for_file: prefer-type-over-var, avoid-negated-conditions, avoid-collection-mutating-methods, parameter_assignments, avoid-unnecessary-reassignment

import 'dart:ui';

import '../shared/release_status.dart';
import '../shared/update_platform.dart';
import '../shared/version.dart';
import 'models/release_config.dart';
import 'models/release_settings_config.dart';
import 'models/store_config.dart';
import 'models/update_config_exception.dart';
import 'models/update_config_model.dart';

part 'sub_parsers/duration_parser.dart';
part 'sub_parsers/release_parser.dart';
part 'sub_parsers/release_settings_parser.dart';
part 'sub_parsers/store_parser.dart';
part 'sub_parsers/text_parser.dart';
part 'sub_parsers/version_parser.dart';

class UpdateConfigParser {
  StoreParser get _storeParser => const StoreParser();
  ReleaseSettingsParser get _releaseSettingsParser => const ReleaseSettingsParser();
  ReleaseParser get _releaseParser => const ReleaseParser();

  const UpdateConfigParser();

  UpdateConfigModel parseConfig(
    Map<String, dynamic> map, {
    required bool isDebug,
  }) {
    // releaseSettings
    var releaseSettings = map.remove('release_settings');

    releaseSettings = _releaseSettingsParser.parse(
      releaseSettings,
      isDebug: isDebug,
    );

    releaseSettings as ReleaseSettingsConfig;

    // stores
    var stores = map.remove('stores');

    if (stores == null) throw const UpdateConfigException();

    if (stores is! List<Map<String, dynamic>>) {
      if (isDebug) throw const UpdateConfigException();
      stores = null;
    } else {
      stores =
          stores.map((e) => _storeParser.parse(e, isStrict: true, isDebug: isDebug)).toList().whereType<StoreConfig>();
    }
    stores as List<Object>;
    stores as List<StoreConfig>;

    // releases
    var releases = map.remove('releases');

    if (releases == null) throw const UpdateConfigException();

    if (releases is! List<Map<String, dynamic>>) {
      if (isDebug) throw const UpdateConfigException();
      releases = null;
    } else {
      releases = releases.map((e) => _releaseParser.parse(e, isDebug: isDebug)).toList().whereType<ReleaseConfig>();
    }

    releases as List<Object>;
    releases as List<ReleaseConfig>;

    return UpdateConfigModel(
      releaseSettings: releaseSettings,
      stores: stores,
      releases: releases,
      customData: map,
    );
  }
}
