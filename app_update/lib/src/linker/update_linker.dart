import '../entities/update_source.dart';
import '../models/global_source/global_source_config.dart';
import '../models/release/release_config.dart';
import '../models/release/update_data.dart';
import '../models/update_app_settings/update_app_settings_config.dart';
import '../models/update_config/update_config.dart';
import '../models/update_content/update_content_config.dart';
import '../models/update_rule/update_rule_config.dart';
import '../models/update_rule/update_rules_container.dart';
import '../models/update_settings/update_settings_config.dart';
import 'sub_linkers/update_data_linker.dart';
import 'sub_linkers/update_release_linker.dart';

class UpdateLinker {
  static const _updateReleaseLinker = UpdateReleaseLinker();

  static const _updateDataLinker = UpdateDataLinker();
  const UpdateLinker();

  List<UpdateData> linkAllConfigs(
    List<UpdateConfig> configs,
  ) {
    final globalSources = <GlobalSourceConfig>[];
    final releases = <ReleaseConfig>[];
    final contentRules = <UpdateRuleConfig<UpdateContentConfig>>[];
    final settingsRules = <UpdateRuleConfig<UpdateSettingsConfig>>[];
    final appSettingsRules = <UpdateRuleConfig<UpdateAppSettingsConfig>>[];

    for (final config in configs) {
      globalSources.addAll(config.sources ?? []);
      releases.addAll(config.releases);
      contentRules.addAll(config.contentRules ?? []);
      settingsRules.addAll(config.settingsRules ?? []);
      appSettingsRules.addAll(config.appSettingsRules ?? []);
    }

    final finalUpdates = linkAll(
      releases: releases,
      rulesContainer: UpdateRulesContainer(
        contentRules: contentRules,
        settingsRules: settingsRules,
        appSettingsRules: appSettingsRules,
      ),
      globalSources: globalSources,
    );

    return finalUpdates;
  }

  /// Преобразует релизы в конкретные обновления с источником и платформой
  /// и мержит все правила.
  List<UpdateData> linkAll({
    required List<ReleaseConfig> releases,
    required UpdateRulesContainer rulesContainer,
    required List<GlobalSourceConfig> globalSources,
  }) {
    final sources = globalSources.map((e) => e.toUpdateSource()).toList();

    final updates = _updateReleaseLinker.linkAll(
      releases: releases,
      sources: sources,
    );

    final finalUpdates = _updateDataLinker.linkAll(
      updates: updates,
      rulesContainer: rulesContainer,
      globalSources: globalSources,
    );

    return finalUpdates;
  }

  /// Преобразует релиз в конкретное обновление с источником и платформой
  /// и мержит все правила.
  List<UpdateData> link({
    required ReleaseConfig release,
    required UpdateRulesContainer rulesContainer,
    required List<GlobalSourceConfig> globalSources,
  }) {
    final sources = globalSources.map((e) => e.toUpdateSource()).toList();

    final updates = _updateReleaseLinker.link(
      release: release,
      sources: sources,
    );

    final finalUpdates = _updateDataLinker.linkAll(
      updates: updates,
      rulesContainer: rulesContainer,
      globalSources: globalSources,
    );

    return finalUpdates;
  }
}
