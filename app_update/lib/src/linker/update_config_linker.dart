import 'package:collection/collection.dart';

import '../shared/mergeable.dart';
import '../shared/models/global_platform/global_platform_config.dart';
import '../shared/models/global_source/global_source_config.dart';
import '../shared/models/release/update_data.dart';
import '../shared/models/update/update_config.dart';
import '../shared/models/update_rule/update_rule_config.dart';
import '../shared/update_entities/update_source.dart';

class UpdateConfigLinker {
  const UpdateConfigLinker();

  UpdateData link({
    required UpdateConfig config,
    required List<GlobalSourceConfig> globalSources,
    required UpdateData update,
  }) {
    final globalSource = globalSources.firstWhereOrNull(
      (source) => source.sourceName == update.sourceName,
    );

    final globalSourcePlatform = globalSource?.platforms?.firstWhereOrNull(
      (platform) => platform.platformName == update.platform,
    );

    List<UpdateRuleConfig<T>>? linkRules<T>(
      List<UpdateRuleConfig<T>>? rules,
    ) =>
        rules
            ?.map(
              (rule) => _linkRule(
                rule: rule,
                source: globalSource,
                platform: globalSourcePlatform,
              ),
            )
            .toList();

    final contentRules = Mergeable.mergeRules(
      config.contentRules,
      linkRules(globalSource?.contentRules),
      linkRules(globalSourcePlatform?.contentRules),
      update.contentRules,
    );

    final settingsRules = Mergeable.mergeRules(
      config.settingsRules,
      linkRules(globalSource?.settingsRules),
      linkRules(globalSourcePlatform?.settingsRules),
      update.settingsRules,
    );

    final appSettingsRules = Mergeable.mergeRules(
      config.appSettingsRules,
      linkRules(globalSource?.appSettingsRules),
      linkRules(globalSourcePlatform?.appSettingsRules),
      update.appSettingsRules,
    );

    final finalUpdate = update.copyWith(
      contentRules: contentRules,
      settingsRules: settingsRules,
      appSettingsRules: appSettingsRules,
    );

    return finalUpdate;
  }

  /// Добавляет в правило источник, платформу и версию релиза.
  UpdateRuleConfig<T> _linkRule<T>({
    required UpdateRuleConfig<T> rule,
    required GlobalSourceConfig? source,
    required GlobalPlatformConfig? platform,
  }) {
    final finalPlatforms = source?.platforms
        ?.map((globalPlatformConfig) => globalPlatformConfig.platformName)
        .where((platformName) => platform == null || platformName == platform.platformName)
        .toList();

    final finalSource = source != null
        ? UpdateSource.custom(
            source.sourceName,
            platforms: finalPlatforms,
          )
        : null;

    final finalRule = rule.copyWith(
      sources: finalSource != null ? [finalSource] : null,
    );

    return finalRule;
  }
}
