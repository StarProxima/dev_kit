import 'dart:async';

import 'package:package_info_plus/package_info_plus.dart';

import '../fetcher/update_config_fetcher_base.dart';
import '../fetcher/update_config_fetcher_coordinator.dart';
import '../fetcher/update_config_source_fetcher.dart';
import '../linker/update_inker.dart';
import '../resolver/update_content_interpolator.dart';
import '../resolver/update_resolver.dart';
import '../resolver/update_rule_resolver.dart';
import '../searcher/update_search_data_defaulter.dart';
import '../searcher/update_searcher.dart';
import '../searcher/update_source_support_checker.dart';
import '../shared/models/release/update.dart';
import '../shared/models/release/update_data.dart';
import '../shared/models/update_result/update_result.dart';
import '../shared/models/update_search/update_search_config.dart';
import '../shared/models/update_status/update_status.dart';
import 'update_contoller_base.dart';

class UpdateController extends UpdateControllerBase {
  // State

  final List<UpdateConfigFetcherBase> _fetchers;
  late PackageInfo _packageInfo;
  final _onFetchStreamController = StreamController<void>.broadcast();
  final _initCompleter = Completer<void>();
  List<UpdateData> _updates = [];

  // Dependencies, can be overridden

  final UpdateLinker _updateLinker = const UpdateLinker();

  final _sourceSupportChecker = UpdateSourceSupportChecker();
  late final _searchDataDefaulter = UpdateSearchDataDefaulter(
    updateSourceChecker: _sourceSupportChecker,
  );

  final _updateResolver = const UpdateResolver(
    ruleResolver: UpdateRuleResolver(),
    contentInterpolator: UpdateContentInterpolator(),
  );

  late final _fetcherCoordinator = UpdateConfigFetcherCoordinator(
    updateSearchDataDefaulter: _searchDataDefaulter,
  );

  late final _updateSearcher = UpdateSearcher(
    searchDataDefaulter: _searchDataDefaulter,
  );

  /// Контроллер для поиска обновлений
  ///
  /// You can add custom fetchers
  /// ```dart
  /// UpdateController(
  ///   fetchers: [
  ///     ...UpdateConfigSourceFetcher.defaultFetchers,
  ///     UpdateConfigFetchercher.byUrl(...),
  ///   ],
  /// )
  /// ```
  ///
  UpdateController({
    List<UpdateConfigFetcherBase> fetchers =
        UpdateConfigSourceFetcher.defaultFetchers,
  }) : _fetchers = fetchers;

  @override
  Future<void> init() async {
    if (_initCompleter.isCompleted) return;

    _packageInfo = await PackageInfo.fromPlatform();
    await _sourceSupportChecker.init();

    if (_initCompleter.isCompleted) return;

    _initCompleter.complete();
  }

  @override
  Stream<void> get onFetch => _onFetchStreamController.stream;

  @override
  Future<void> fetch(
    UpdateSearchConfig searchConfig, {
    bool shouldFetchSourceFetchers = true,
    bool shouldFetchFerchers = true,
  }) async {
    await init();

    final configs = await _fetcherCoordinator.fetch(
      fetchers: _fetchers,
      packageInfo: _packageInfo,
      searchConfig: searchConfig,
      shouldFetchSourceFetchers: shouldFetchSourceFetchers,
      shouldFetchFerchers: shouldFetchFerchers,
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

    final searchResult = _updateSearcher.searchFull(
      updates: _updates,
      packageInfo: _packageInfo,
      searchConfig: searchConfig,
    );

    final searchData = searchResult.searchData;
    final mostRelevantUpdate = searchResult.updateData;

    if (mostRelevantUpdate == null) {
      final result = UpdateResult(
        update: null,
        searchData: searchData,
        updateStatus: const UpdateNotFoundException(),
      );

      return result;
    }

    final result = _updateResolver.resolve(
      updateData: mostRelevantUpdate,
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
  void dispose() {
    _onFetchStreamController.close();
  }
}
