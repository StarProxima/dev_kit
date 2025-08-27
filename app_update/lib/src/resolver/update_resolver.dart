import '../models/release/update.dart';
import '../models/release/update_data.dart';
import '../models/update_app_settings/update_app_settings_config.dart';
import '../models/update_app_settings/update_app_settings_data.dart';
import '../models/update_content/update_content_config.dart';
import '../models/update_content/update_content_data.dart';
import '../models/update_result/update_result.dart';
import '../models/update_search/update_search_data.dart';
import '../models/update_settings/update_settings_config.dart';
import '../models/update_settings/update_settings_data.dart';
import '../models/update_status/update_status.dart';
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
    final appSettingsRules = updateData.appSettingsRules ?? [];

    if (appSettingsRules.isEmpty) {
      throw Exception('App settings rules are empty');
    }

    final resolvedAppSettingsConfig =
        _ruleResolver.resolve<UpdateAppSettingsConfig>(
      searchData: searchData,
      rules: appSettingsRules,
    );

    final resolvedAppSettings = UpdateAppSettingsData.fromConfig(
      resolvedAppSettingsConfig,
    );

    if (searchData.appStatus == null) {
      searchData = searchData.copyWith(
        appStatus: resolvedAppSettings.appStatus,
      );
    }

    final contentRules = updateData.contentRules ?? [];

    if (contentRules.isEmpty) {
      throw Exception('Content rules are empty');
    }

    final rawResolvedContentConfig = _ruleResolver.resolve<UpdateContentConfig>(
      searchData: searchData,
      rules: contentRules,
    );

    final rawResolvedContent = UpdateContentData.fromConfig(
      rawResolvedContentConfig,
    );

    final resolvedContent = _contentInterpolator.interpolate(
      updateContent: rawResolvedContent,
      searchData: searchData,
      updateData: updateData,
    );

    final settingsRules = updateData.settingsRules ?? [];

    if (settingsRules.isEmpty) {
      throw Exception('Settings rules are empty');
    }

    final resolvedSettingsConfig = _ruleResolver.resolve<UpdateSettingsConfig>(
      searchData: searchData,
      rules: settingsRules,
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
