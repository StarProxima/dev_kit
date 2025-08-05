// ignore_for_file: prefer-type-over-var, avoid-negated-conditions, avoid-collection-mutating-methods, parameter_assignments, avoid-unnecessary-reassignment

import 'dart:ui';

import '../shared/raw_update_config.dart';
import '../shared/update_alert_type.dart';
import '../shared/update_platform.dart';
import '../shared/version_status.dart';
import 'base_parsers/bool_parser.dart';
import 'base_parsers/date_time_parser.dart';
import 'base_parsers/duration_parser.dart';
import 'base_parsers/string_parser.dart';
import 'base_parsers/version_parser.dart';
import 'models/platform_config.dart';
import 'models/release_config.dart';
import 'models/update_settings_config.dart';
import 'models/global_source_config.dart';
import 'base_parsers/update_config_exception.dart';
import 'models/update_model_config.dart';
import 'models/update_settings_config_container.dart';
import 'models/update_content_config.dart';
import 'models/update_text_config_container.dart';
import 'sub_parsers/version_settings_parser.dart';

part 'sub_parsers/release_parser.dart';
part 'sub_parsers/sources/global_platform_parser.dart';
part 'sub_parsers/sources/global_source_parser.dart';
part 'sub_parsers/sources/release_platform_parser.dart';
part 'sub_parsers/sources/release_source_parser.dart';
part 'sub_parsers/update_settings_container_parser.dart';
part 'sub_parsers/update_settings_parser.dart';
part 'sub_parsers/update_text_parser.dart';
part 'sub_parsers/update_text_container_parser.dart';
part 'sub_parsers/raw_container_parser.dart';

class UpdateConfigParser {
  UpdateSettingsContainerParser get _updateSettingsContainerParser => const UpdateSettingsContainerParser();
  UpdateTextContainerParser get _updateTextContainerParser => const UpdateTextContainerParser();
  VersionSettingsParser get _versionSettingsParser => const VersionSettingsParser();
  GlobalSourceParser get _sourceParser => const GlobalSourceParser();
  ReleaseParser get _releaseParser => const ReleaseParser();

  const UpdateConfigParser();

  UpdateModelConfig parse(
    RawUpdateConfig map, {
    required bool isDebug,
  }) {
    // text
    final textValue = map.remove('text');
    final text = _updateTextContainerParser.parse(textValue, isDebug: isDebug);

    // updateSettings
    final updateSettingsValue = map.remove('settings');
    final updateSettings = _updateSettingsContainerParser.parse(
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
    if (sourcesValue is! List?) throw const UpdateConfigException();

    final sources = sourcesValue
        ?.map(
          (e) => _sourceParser.parse(
            e,
            isDebug: true,
            isOverride: false,
          ),
        )
        .whereType<GlobalSourceConfig>()
        .toList();

    // releases
    final releasesValue = map.remove('releases');
    if (releasesValue is! List) throw const UpdateConfigException();

    final releases = releasesValue
        .map((e) => _releaseParser.parse(e, isDebug: isDebug, isOverride: false))
        .whereType<ReleaseConfig>()
        .toList();

    return UpdateModelConfig.byRequired(
      contentRules: text,
      settingsRules: updateSettings,
      appStatusConditions: versionSettings,
      sources: sources,
      releases: releases,
      customData: map,
    );
  }
}
