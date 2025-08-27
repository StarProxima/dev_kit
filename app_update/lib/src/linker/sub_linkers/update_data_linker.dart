import 'package:collection/collection.dart';

import '../../entities/update_source.dart';
import '../../models/global_platform/global_platform_config.dart';
import '../../models/global_source/global_source_config.dart';
import '../../utils/mergeable.dart';
import '../../models/release/update_data.dart';
import '../../models/update_rule/update_rule_config.dart';
import '../../models/update_rule/update_rules_container.dart';

class UpdateDataLinker {
  const UpdateDataLinker();

  /// Добавляет в обновления переданные правила и правила из глобальных источников.
  List<UpdateData> linkAll({
    required List<UpdateData> updates,
    required UpdateRulesContainer rulesContainer,
    required List<GlobalSourceConfig> globalSources,
  }) {
    final finalUpdates = updates
        .map(
          (update) => link(
            update: update,
            rulesContainer: rulesContainer,
            globalSources: globalSources,
          ),
        )
        .toList();

    return finalUpdates;
  }

  /// Добавляет в обновление переданные правила и правила из глобальных источников.
  ///
  /// Мержит все правила в приоритете:
  /// [...rules, ...globalSourceRules, ...globalPlatformRules, ...updateRules]
  /// в общий список правил в [UpdateData].
  UpdateData link({
    required UpdateData update,
    required UpdateRulesContainer rulesContainer,
    required List<GlobalSourceConfig> globalSources,
  }) {
    final globalSource = globalSources.firstWhereOrNull(
      (source) => source.sourceName == update.sourceName,
    );

    final globalSourcePlatform = globalSource?.platforms?.firstWhereOrNull(
      (platform) => platform.platformName == update.platform,
    );

    List<UpdateRuleConfig<T>>? linkRules<T extends Mergeable>(
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

    final finalContentRules = Mergeable.mergeRules(
      rulesContainer.contentRules,
      linkRules(globalSource?.contentRules),
      linkRules(globalSourcePlatform?.contentRules),
      update.contentRules,
    );

    final finalSettingsRules = Mergeable.mergeRules(
      rulesContainer.settingsRules,
      linkRules(globalSource?.settingsRules),
      linkRules(globalSourcePlatform?.settingsRules),
      update.settingsRules,
    );

    final finalAppSettingsRules = Mergeable.mergeRules(
      rulesContainer.appSettingsRules,
      linkRules(globalSource?.appSettingsRules),
      linkRules(globalSourcePlatform?.appSettingsRules),
      update.appSettingsRules,
    );

    final finalUpdate = update.copyWith(
      contentRules: finalContentRules,
      settingsRules: finalSettingsRules,
      appSettingsRules: finalAppSettingsRules,
    );

    return finalUpdate;
  }

  /// Добавляет в правило источник и платформу.
  UpdateRuleConfig<T> _linkRule<T extends Mergeable>({
    required UpdateRuleConfig<T> rule,
    required GlobalSourceConfig? source,
    required GlobalPlatformConfig? platform,
  }) {
    final finalPlatforms = source?.platforms
        ?.map((globalPlatformConfig) => globalPlatformConfig.platformName)
        .where((platformName) =>
            platform == null || platformName == platform.platformName)
        .toList();

    final finalSource = source != null
        ? UpdateSource.custom(
            source.sourceName,
            platforms: finalPlatforms,
          )
        : null;

    final finalRule = rule.copyWith(
      sourceIs: finalSource != null ? [finalSource] : null,
    );

    return finalRule;
  }
}
