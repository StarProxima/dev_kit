import 'dart:async';
import 'dart:ui';

import 'package:package_info_plus/package_info_plus.dart';

import '../fetcher/update_config_fetcher.dart';
import '../finder/update_finder.dart';
import '../linker/update_inker.dart';
import '../rule_resolver/update_rule_resolver.dart';
import '../shared/models/release/update.dart';
import '../shared/models/release/update_data.dart';
import '../shared/models/update_result/update_result.dart';
import '../shared/models/update_rule/update_rules_container.dart';
import '../shared/models/update_search/update_search_config.dart';
import '../shared/models/update_status/update_status.dart';
import 'update_contoller_base.dart';
import 'update_data_resolver.dart';
import 'update_searcher.dart';

class UpdateController extends UpdateControllerBase {
  final _initCompleter = Completer<void>();

  late PackageInfo _packageInfo;

  List<UpdateData> _updates = [];

  final UpdateConfigFetcher? _updateConfigFetcher;
  final UpdateDataResolver _updateDataResolver;
  final UpdateLinker _updateLinker;
  final UpdateSearcher _updateSearcher;

  UpdateController({
    UpdateConfigFetcher? fetcher,
    UpdateDataResolver? updateDataResolver,
    UpdateLinker? linker,
    UpdateSearcher? searcher,
  })  : _updateConfigFetcher = fetcher,
        _updateDataResolver = updateDataResolver ??
            const UpdateDataResolver(
              ruleResolver: UpdateRuleResolver(),
            ),
        _updateSearcher = searcher ??
            const UpdateSearcher(
              updateFinder: UpdateFinder(),
            ),
        _updateLinker = linker ?? const UpdateLinker();

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
    await init();

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
    final fetcher = _updateConfigFetcher;

    if (fetcher == null) return;

    final config = await fetcher.fetch();

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
    if (!_initCompleter.isCompleted) {
      throw Exception('UpdateController is not initialized');
    }

    final (:updateData, :searchData) = _updateSearcher.search(
      updates: _updates,
      packageInfo: _packageInfo,
      searchConfig: searchConfig,
    );

    if (updateData == null) {
      final result = UpdateResult(
        update: null,
        searchData: searchData,
        updateStatus: const UpdateNotFoundException(),
      );

      return result;
    }

    final result = _updateDataResolver.resolve(
      updateData: updateData,
      searchData: searchData,
    );

    return result;
  }

  @override
  Future<void> launchUpdateUrl(Update update) {
    // TODO: implement launchUpdateUrl
    throw UnimplementedError();
  }

  @override
  Future<void> postponeUpdate(Update update) {
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
