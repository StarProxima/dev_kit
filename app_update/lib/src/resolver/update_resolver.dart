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
import 'update_content_interpolator.dart';
import 'update_rule_resolver.dart';

class UpdateResolver {
  final UpdateRuleResolver _ruleResolver;
  final UpdateContentInterpolator _contentInterpolator;

  const UpdateResolver({
    required UpdateRuleResolver ruleResolver,
    required UpdateContentInterpolator contentInterpolator,
  })  : _ruleResolver = ruleResolver,
        _contentInterpolator = contentInterpolator;

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

    final rawResolvedContentConfig = _ruleResolver.resolve<UpdateContentConfig>(
      searchData: searchData,
      rules: updateData.contentRules!,
    );

    final rawResolvedContent = UpdateContentData.fromConfig(
      rawResolvedContentConfig,
    );

    final resolvedContent = _contentInterpolator.interpolate(
      updateContent: rawResolvedContent,
      searchData: searchData,
      updateData: updateData,
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
      rawContent: rawResolvedContent,
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
