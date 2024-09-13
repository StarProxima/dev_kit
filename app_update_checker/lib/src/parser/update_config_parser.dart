// ignore_for_file: prefer-type-over-var, avoid-negated-conditions, avoid-collection-mutating-methods, parameter_assignments, avoid-unnecessary-reassignment

import 'dart:ui';

import 'package:pub_semver/pub_semver.dart';

import '../shared/release_status.dart';
import '../shared/text_translations.dart';
import '../shared/update_platform.dart';
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

    if (releaseSettings is! Map<String, dynamic>?) {
      throw const UpdateConfigException();
    }

    if (releaseSettings != null) {
      releaseSettings = _releaseSettingsParser.parse(
        releaseSettings,
        isDebug: isDebug,
      );
    }

    releaseSettings as ReleaseSettingsConfig?;

    // stores
    var stores = map.remove('stores');

    if (stores is! List<Map<String, dynamic>>?) {
      throw const UpdateConfigException();
    } else if (stores != null) {
      stores = stores
          .map((e) => _storeParser.parse(e, isGlobalStore: true, isDebug: isDebug))
          .whereType<StoreConfig>()
          .toList();
    }
    stores as List<StoreConfig>?;

    // releases
    var releases = map.remove('releases');

    if (releases is! List<Map<String, dynamic>>) throw const UpdateConfigException();

    releases = releases.map((e) => _releaseParser.parse(e, isDebug: isDebug)).whereType<ReleaseConfig>().toList();
    releases as List<ReleaseConfig>;

    return UpdateConfigModel(
      releaseSettings: releaseSettings,
      stores: stores,
      releases: releases,
      customData: map,
    );
  }
}
