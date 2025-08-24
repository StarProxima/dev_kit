import 'dart:async';

import 'package:package_info_plus/package_info_plus.dart';

import '../fetcher/source_fetchers/app_store_update_config_fetcher.dart';
import '../fetcher/source_fetchers/google_play_update_config_fetcher.dart';
import '../fetcher/update_config_fetcher_base.dart';
import '../finder/update_finder.dart';
import '../linker/update_inker.dart';
import '../rule_resolver/update_rule_resolver.dart';
import '../shared/models/release/update.dart';
import '../shared/models/release/update_data.dart';
import '../shared/models/update_result/update_result.dart';
import '../shared/models/update_search/update_search_config.dart';
import '../shared/models/update_status/update_status.dart';
import 'update_config_fetcher_coordinator.dart';
import 'update_contoller_base.dart';
import 'update_data_resolver.dart';
import 'update_searcher.dart';

class UpdateController extends UpdateControllerBase {
  @override
  Stream<void> get onFetch => _onFetchStreamController.stream;

  final _onFetchStreamController = StreamController<void>.broadcast();

  final _initCompleter = Completer<void>();

  late PackageInfo _packageInfo;

  List<UpdateData> _updates = [];

  late final List<UpdateConfigFetcherBase> _fetchers;
  late final UpdateConfigFetcherCoordinator _fetcherCoordinator;
  late final UpdateDataResolver _updateDataResolver;
  late final UpdateLinker _updateLinker;
  late final UpdateSearcher _updateSearcher;

  UpdateController({
    List<UpdateConfigFetcherBase> fetchers = const [
      GooglePlayUpdateConfigFetcher(),
      AppStoreUpdateConfigFetcher(),
    ],
    UpdateConfigFetcherCoordinator? fetcherCoordinator,
    UpdateDataResolver? updateDataResolver,
    UpdateLinker? linker,
    UpdateSearcher? searcher,
  }) {
    _fetchers = fetchers;

    _updateSearcher = searcher ??
        const UpdateSearcher(
          updateFinder: UpdateFinder(),
        );

    _fetcherCoordinator = fetcherCoordinator ??
        UpdateConfigFetcherCoordinator(
          updateSearcher: _updateSearcher,
        );

    _fetcherCoordinator = fetcherCoordinator ??
        UpdateConfigFetcherCoordinator(
          updateSearcher: searcher ??
              const UpdateSearcher(
                updateFinder: UpdateFinder(),
              ),
        );

    _updateDataResolver = updateDataResolver ??
        const UpdateDataResolver(
          ruleResolver: UpdateRuleResolver(),
        );

    _updateLinker = linker ?? const UpdateLinker();
  }

  Future<void> init() async {
    if (_initCompleter.isCompleted) return;

    _packageInfo = await PackageInfo.fromPlatform();

    if (_initCompleter.isCompleted) return;

    _initCompleter.complete();
  }

  @override
  Future<void> fetch(
    UpdateSearchConfig searchConfig, {
    bool shouldFetchGlobalSources = true,
    bool shouldFetchConfig = true,
  }) async {
    await init();

    final configs = await _fetcherCoordinator.fetch(
      fetchers: _fetchers,
      searchConfig: searchConfig,
      packageInfo: _packageInfo,
    );

    final updates = _updateLinker.linkAllConfigs(configs);

    _updates = updates;
    _onFetchStreamController.add(null);
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
