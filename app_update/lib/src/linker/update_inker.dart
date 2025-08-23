import '../shared/models/global_source/global_source_config.dart';
import '../shared/models/release/release_config.dart';
import '../shared/models/release/update_data.dart';
import '../shared/models/update_app_settings/update_app_settings_config.dart';
import '../shared/models/update_content/update_content_config.dart';
import '../shared/models/update_rule/update_rule_config.dart';
import '../shared/models/update_settings/update_settings_config.dart';
import '../shared/update_entities/update_source.dart';
import 'sub_linkers/update_data_linker.dart';
import 'sub_linkers/update_release_linker.dart';

class UpdateLinker {
  const UpdateLinker();

  static const _updateReleaseLinker = UpdateReleaseLinker();
  static const _updateDataLinker = UpdateDataLinker();

  /// Преобразует релизы в конкретные обновления с источником и платформой
  /// и мержит все правила.
  List<UpdateData> linkAll({
    required List<ReleaseConfig> releases,
    required List<UpdateRuleConfig<UpdateContentConfig?>>? contentRules,
    required List<UpdateRuleConfig<UpdateSettingsConfig?>>? settingsRules,
    required List<UpdateRuleConfig<UpdateAppSettingsConfig?>>? appSettingsRules,
    required List<GlobalSourceConfig> globalSources,
  }) {
    final sources = globalSources.map((e) => e.toUpdateSource()).toList();

    final updates = _updateReleaseLinker.linkAll(
      releases: releases,
      sources: sources,
    );

    final finalUpdates = _updateDataLinker.linkAll(
      updates: updates,
      contentRules: contentRules,
      settingsRules: settingsRules,
      appSettingsRules: appSettingsRules,
      globalSources: globalSources,
    );

    return finalUpdates;
  }

  /// Преобразует релиз в конкретное обновление с источником и платформой
  /// и мержит все правила.
  List<UpdateData> link({
    required ReleaseConfig release,
    required List<UpdateRuleConfig<UpdateContentConfig?>>? contentRules,
    required List<UpdateRuleConfig<UpdateSettingsConfig?>>? settingsRules,
    required List<UpdateRuleConfig<UpdateAppSettingsConfig?>>? appSettingsRules,
    required List<GlobalSourceConfig> globalSources,
  }) {
    final sources = globalSources.map((e) => e.toUpdateSource()).toList();

    final updates = _updateReleaseLinker.link(
      release: release,
      sources: sources,
    );

    final finalUpdates = _updateDataLinker.linkAll(
      updates: updates,
      contentRules: contentRules,
      settingsRules: settingsRules,
      appSettingsRules: appSettingsRules,
      globalSources: globalSources,
    );

    return finalUpdates;
  }
}
