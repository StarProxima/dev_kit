import 'dart:async';

import 'package:flutter/widgets.dart';
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
import 'update_contoller.dart';

class UpdateControllerImpl implements UpdateController {
  // State

  @protected
  final List<UpdateConfigFetcherBase> fetchers;
  @protected
  late PackageInfo packageInfo;
  @protected
  final onFetchStreamController = StreamController<void>.broadcast();
  @protected
  final initCompleter = Completer<void>();
  @protected
  List<UpdateData> updates = [];

  // Dependencies, can be overridden

  @protected
  final linker = const UpdateLinker();
  @protected
  final ruleResolver = const UpdateRuleResolver();
  @protected
  final contentInterpolator = const UpdateContentInterpolator();
  @protected
  final sourceSupportChecker = UpdateSourceSupportChecker();
  @protected
  late final searchDataDefaulter = UpdateSearchDataDefaulter(
    updateSourceChecker: sourceSupportChecker,
  );
  @protected
  late final updateResolver = UpdateResolver(
    ruleResolver: ruleResolver,
    contentInterpolator: contentInterpolator,
  );
  @protected
  late final fetcherCoordinator = UpdateConfigFetcherCoordinator(
    updateSearchDataDefaulter: searchDataDefaulter,
  );
  @protected
  late final updateSearcher = UpdateSearcher(
    searchDataDefaulter: searchDataDefaulter,
  );

  UpdateControllerImpl({
    this.fetchers = UpdateConfigSourceFetcher.defaultFetchers,
  });

  @override
  Future<void> init() async {
    if (initCompleter.isCompleted) return;

    packageInfo = await PackageInfo.fromPlatform();
    await sourceSupportChecker.init();

    if (initCompleter.isCompleted) return;

    initCompleter.complete();
  }

  @override
  Stream<void> get onFetch => onFetchStreamController.stream;

  @override
  Future<void> fetch(
    UpdateSearchConfig searchConfig, {
    bool shouldFetchSourceFetchers = true,
    bool shouldFetchFerchers = true,
  }) async {
    await init();

    final configs = await fetcherCoordinator.fetch(
      fetchers: fetchers,
      packageInfo: packageInfo,
      searchConfig: searchConfig,
      shouldFetchSourceFetchers: shouldFetchSourceFetchers,
      shouldFetchFerchers: shouldFetchFerchers,
    );

    final updates = linker.linkAllConfigs(configs);

    this.updates = updates;
    onFetchStreamController.add(null);
  }

  @override
  UpdateResult findUpdate(UpdateSearchConfig searchConfig) {
    if (!initCompleter.isCompleted) {
      throw Exception('UpdateController is not initialized');
    }

    final searchResult = updateSearcher.searchFull(
      updates: updates,
      packageInfo: packageInfo,
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

    final result = updateResolver.resolve(
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
    onFetchStreamController.close();
  }
}
