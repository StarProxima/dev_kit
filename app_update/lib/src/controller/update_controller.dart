import 'dart:async';
import 'dart:ui';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

import '../fetcher/update_config_fetcher.dart';
import '../finder/update_finder.dart';
import '../linker/update_inker.dart';
import '../rule_resolver/update_rule_resolver.dart';
import '../shared/models/release/update.dart';
import '../shared/models/release/update_data.dart';
import '../shared/models/update_app_settings/update_app_settings_config.dart';
import '../shared/models/update_app_settings/update_app_settings_data.dart';
import '../shared/models/update_content/update_content_config.dart';
import '../shared/models/update_content/update_content_data.dart';
import '../shared/models/update_result/update_result.dart';
import '../shared/models/update_rule/update_rule_config.dart';
import '../shared/models/update_rule/update_rules_container.dart';
import '../shared/models/update_search/update_search_config.dart';
import '../shared/models/update_search/update_search_data.dart';
import '../shared/models/update_settings/update_settings_config.dart';
import '../shared/models/update_settings/update_settings_data.dart';
import '../shared/models/update_status/update_status.dart';
import '../shared/update_entities/update_locale.dart';
import '../shared/update_entities/update_platform.dart';
import '../shared/update_entities/update_view_target.dart';
import 'update_contoller_base.dart';

class UpdateController extends UpdateControllerBase {
  @override
  UpdateResult? get updateResult => _updateResult;

  @override
  Stream<UpdateResult> get updateResultStream => throw UnimplementedError();

  final _initCompleter = Completer<void>();

  late PackageInfo _packageInfo;
  UpdateResult? _updateResult;
  List<UpdateData> _updates = [];

  final UpdateConfigFetcher _updateConfigFetcher;
  final UpdateRuleResolver _updateRuleResolver;
  final UpdateLinker _updateLinker;
  final UpdateFinder _updateFinder;

  UpdateController({
    required UpdateConfigFetcher fetcher,
    UpdateRuleResolver? ruleResolver,
    UpdateLinker? linker,
    UpdateFinder? finder,
  })  : _updateConfigFetcher = fetcher,
        _updateRuleResolver = ruleResolver ?? const UpdateRuleResolver(),
        _updateLinker = linker ?? const UpdateLinker(),
        _updateFinder = finder ?? const UpdateFinder();

  Future<void> init() async {
    if (_initCompleter.isCompleted) return;

    _packageInfo = await PackageInfo.fromPlatform();

    if (_initCompleter.isCompleted) return;

    _initCompleter.complete();
  }

  @override
  Future<void> fetch({
    Locale? locale,
    bool shouldFetchGlobalSources = true,
    bool shouldFetchConfig = true,
  }) async {
    if (shouldFetchGlobalSources) {
      await _fetchGlobalSourceReleases(locale: locale);
    }

    if (shouldFetchConfig) {
      await _fetchUpdateConfig();
    }
  }

  Future<void> _fetchGlobalSourceReleases({Locale? locale}) async {
    // TODO: implement fetchGlobalSourceReleases
  }

  Future<void> _fetchUpdateConfig() async {
    final config = await _updateConfigFetcher.fetch();

    _updates = _updateLinker.linkAll(
      releases: config.releases,
      rulesContainer: UpdateRulesContainer(
        contentRules: config.contentRules,
        settingsRules: config.settingsRules,
        appSettingsRules: config.appSettingsRules,
      ),
      globalSources: config.sources ?? [],
    );
  }

  @override
  UpdateResult findUpdate(UpdateSearchConfig searchConfig) {
    var searchData = UpdateSearchData(
      currentDate: searchConfig.currentDate ?? DateTime.now(),
      localVersion: searchConfig.localVersion ?? Version.parse(_packageInfo.version),
      platform: searchConfig.platform ?? UpdatePlatform.current(),
      sources: searchConfig.sources ?? [],
      locale: searchConfig.locale ?? UpdateLocale.any,
      appStatus: searchConfig.appStatus,
      customData: searchConfig.customData,
      displayTarget: searchConfig.displayTarget ?? UpdateViewTarget.any,
      rolloutPointer: searchConfig.rolloutPointer ?? 0.5,
      segmentationPointer: searchConfig.segmentationPointer ?? 0.5,
      localReleaseDate: null,
      updateReleaseDate: null,
    );

    final updateData = _updateFinder.findMostRelevantUpdate(
      currentDate: searchData.currentDate,
      localVersion: searchData.localVersion,
      platform: searchData.platform,
      sources: searchData.sources,
      updates: _updates,
    );

    if (updateData == null) {
      return const UpdateResult(
        update: null,
        updateStatus: UpdateNotFoundException(),
      );
    }

    final currentUpdateData = _updateFinder.findMostRelevantCurrentUpdate(
      currentDate: searchData.currentDate,
      localVersion: searchData.localVersion,
      platform: searchData.platform,
      sources: searchData.sources,
      updates: _updates,
    );

    searchData = searchData.copyWith(
      localReleaseDate: currentUpdateData?.date,
      updateReleaseDate: updateData.date,
    );

    final resolvedContentConfig = _updateRuleResolver.resolve<UpdateContentConfig>(
      searchData: searchData,
      rules: updateData.contentRules!.whereType<UpdateRuleConfig<UpdateContentConfig>>().toList(),
    );

    final resolvedContent = UpdateContentData.fromConfig(resolvedContentConfig);

    final resolvedSettingsConfig = _updateRuleResolver.resolve<UpdateSettingsConfig>(
      searchData: searchData,
      rules: updateData.settingsRules!.whereType<UpdateRuleConfig<UpdateSettingsConfig>>().toList(),
    );

    final resolvedSettings = UpdateSettingsData.fromConfig(resolvedSettingsConfig);

    final resolvedAppSettingsConfig = _updateRuleResolver.resolve<UpdateAppSettingsConfig>(
      searchData: searchData,
      rules: updateData.appSettingsRules!
          .whereType<UpdateRuleConfig<UpdateAppSettingsConfig>>()
          .toList(),
    );

    final resolvedAppSettings = UpdateAppSettingsData.fromConfig(resolvedAppSettingsConfig);

    final mostRelevantUpdate = Update(
      version: updateData.version,
      date: updateData.date,
      sourceName: updateData.sourceName,
      platform: updateData.platform,
      content: resolvedContent,
      settings: resolvedSettings,
      appSettings: resolvedAppSettings,
      customData: updateData.customData,
    );

    final result = UpdateResult(
      update: mostRelevantUpdate,
      updateStatus: const UpdateAvailableStatus(),
    );

    return result;
  }

  @override
  Future<void> launchUpdateUrl(Update update) {
    // TODO: implement launchUpdateUrl
    throw UnimplementedError();
  }

  @override
  Future<void> postponeUpdate({required Update update, required Duration postponeDuration}) {
    // TODO: implement postponeUpdate
    throw UnimplementedError();
  }

  @override
  Future<void> skipUpdate(Update update) {
    // TODO: implement skipUpdate
    throw UnimplementedError();
  }

  @override
  Future<void> dispose() {
    // TODO: implement dispose
    throw UnimplementedError();
  }
}
