import '../shared/models/release/update.dart';
import '../shared/models/release/update_data.dart';
import '../shared/models/update_app_settings/update_app_settings_config.dart';
import '../shared/models/update_app_settings/update_app_settings_data.dart';
import '../shared/models/update_content/update_content_config.dart';
import '../shared/models/update_content/update_content_data.dart';
import '../shared/models/update_result/update_result.dart';
import '../shared/models/update_search/update_search_data.dart';
import '../shared/models/update_settings/update_settings_config.dart';
import '../shared/models/update_settings/update_settings_data.dart';
import '../shared/models/update_status/update_status.dart';
import 'update_rule_resolver.dart';

class UpdateResolver {
  final UpdateRuleResolver _ruleResolver;

  const UpdateResolver({
    required UpdateRuleResolver ruleResolver,
  }) : _ruleResolver = ruleResolver;

  UpdateResult resolve({
    required UpdateData updateData,
    required UpdateSearchData searchData,
  }) {
    final resolvedAppSettingsConfig =
        _ruleResolver.resolve<UpdateAppSettingsConfig>(
      searchData: searchData,
      rules: updateData.appSettingsRules!,
    );

    final resolvedAppSettings = UpdateAppSettingsData.fromConfig(
      resolvedAppSettingsConfig,
    );

    if (searchData.appStatus == null) {
      searchData = searchData.copyWith(
        appStatus: resolvedAppSettings.appStatus,
      );
    }

    final resolvedContentConfig = _ruleResolver.resolve<UpdateContentConfig>(
      searchData: searchData,
      rules: updateData.contentRules!,
    );

    final resolvedContent = UpdateContentData.fromConfig(
      resolvedContentConfig,
    );

    final resolvedSettingsConfig = _ruleResolver.resolve<UpdateSettingsConfig>(
      searchData: searchData,
      rules: updateData.settingsRules!,
    );

    final resolvedSettings = UpdateSettingsData.fromConfig(
      resolvedSettingsConfig,
    );

    final mostRelevantUpdate = Update(
      version: updateData.version,
      date: updateData.date,
      sourceName: updateData.sourceName,
      platform: updateData.platform,
      rawContent: resolvedContent,
      content: resolvedContent,
      settings: resolvedSettings,
      appSettings: resolvedAppSettings,
      customData: updateData.customData,
    );

    return UpdateResult(
      updateStatus: const UpdateFoundStatus(),
      searchData: searchData,
      update: mostRelevantUpdate,
    );
  }
}
