// ignore_for_file: prefer-type-over-var, avoid-negated-conditions, avoid-collection-mutating-methods, parameter_assignments, avoid-unnecessary-reassignment

import '../shared/app_version_status.dart';
import '../shared/raw_update_config.dart';
import '../shared/update_alert_type.dart';
import '../shared/update_platform.dart';
import '../shared/update_status_wrapper.dart';
import 'base_parsers/bool_parser.dart';
import 'base_parsers/date_time_parser.dart';
import 'base_parsers/duration_parser.dart';
import 'base_parsers/text_translations_parser.dart';
import 'base_parsers/version_parser.dart';
import 'models/release_config.dart';
import 'models/release_settings_config.dart';
import 'models/settings_translations.dart';
import 'models/source_config.dart';
import 'models/update_config_exception.dart';
import 'models/update_config_model.dart';
import 'sub_parsers/version_settings_parser.dart';

part 'sub_parsers/global_source_parser.dart';
part 'sub_parsers/release_parser.dart';
part 'sub_parsers/release_settings_parser.dart';
part 'sub_parsers/release_source_parser.dart';
part 'sub_parsers/settings_translations_parser.dart';
part 'sub_parsers/update_settings_parser.dart';

class UpdateConfigParser {
  UpdateSettingsParser get _updateSettingsParser => const UpdateSettingsParser();
  VersionSettingsParser get _versionSettingsParser => const VersionSettingsParser();
  GlobalSourceParser get _sourceParser => const GlobalSourceParser();
  ReleaseParser get _releaseParser => const ReleaseParser();

  const UpdateConfigParser();

  UpdateConfigModel parseConfig(
    RawUpdateConfig map, {
    required bool isDebug,
  }) {
    // releaseSettings
    final updateSettingsValue = map.remove('settings');
    final updateSettings = _updateSettingsParser.parse(
      updateSettingsValue,
      isDebug: isDebug,
    );

    // versionSettings
    final versionSettingsValue = map.remove('version_settings');
    final versionSettings = _versionSettingsParser.parse(
      versionSettingsValue,
      isDebug: isDebug,
    );

    // sources
    final sourcesValue = map.remove('sources');
    if (sourcesValue is! List<Object>?) throw const UpdateConfigException();

    final sources = sourcesValue
        ?.map(
          (e) => _sourceParser.parse(e, isDebug: true),
        )
        .whereType<GlobalSourceConfig>()
        .toList();

    // releases
    final releasesValue = map.remove('releases');
    if (releasesValue is! List<Map<String, dynamic>>) {
      throw const UpdateConfigException();
    }

    final releases = releasesValue
        .map((e) => _releaseParser.parse(e, isDebug: isDebug, isAbleToUseNullVersion: false))
        .whereType<ReleaseConfig>()
        .toList();

    return UpdateConfigModel(
      settings: updateSettings,
      versionSettings: versionSettings,
      sources: sources,
      releases: releases,
      customData: map,
    );
  }
}
