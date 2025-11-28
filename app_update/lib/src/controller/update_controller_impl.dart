import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../fetcher/update_config_fetcher.dart';
import '../fetcher/update_config_fetcher_coordinator.dart';
import '../fetcher/update_config_source_fetcher.dart';
import '../linker/update_linker.dart';
import '../models/release/update.dart';
import '../models/release/update_data.dart';
import '../models/update_result/update_result.dart';
import '../models/update_search/update_search_config.dart';
import '../models/update_status/update_status.dart';
import '../resolver/matchers/source_matcher.dart';
import '../resolver/update_content_interpolator.dart';
import '../resolver/update_resolver.dart';
import '../resolver/update_rule_resolver.dart';
import '../searcher/update_search_data_defaulter.dart';
import '../searcher/update_searcher.dart';
import '../searcher/update_supported_sources_checker.dart';
import '../storage/shared_preferences_update_storage.dart';
import '../storage/update_storage.dart';
import '../storage/update_storage_manager.dart';
import 'update_contoller.dart';

class UpdateControllerImpl implements UpdateController {
  // State

  @protected
  final List<UpdateConfigFetcher> fetchers;
  @protected
  final UpdateStorage? storage;
  @protected
  late final PackageInfo packageInfo;
  @protected
  // ignore: prefer-correct-callback-field-name
  final onFetchStreamController = StreamController<void>.broadcast();
  @protected
  Completer<void>? initCompleter;

  bool get isInitialized => initCompleter?.isCompleted ?? false;
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
  final sourceSupportChecker = UpdateSupportedSourcesChecker();

  @protected
  final sourceMatcher = const SourceMatcher();

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
    sourceMatcher: sourceMatcher,
  );

  @protected
  late final updateSearcher = UpdateSearcher(
    searchDataDefaulter: searchDataDefaulter,
  );

  @protected
  late final UpdateStorageManager storageManager;

  UpdateControllerImpl({
    this.fetchers = UpdateConfigSourceFetcher.defaultFetchers,
    this.storage,
  });

  @override
  Future<void> init() async {
    Completer<void>? completer = initCompleter;

    // Защита от concurrent initialization
    if (completer != null) {
      if (completer.isCompleted) return;
      await completer.future;

      return;
    }

    completer = Completer<void>();
    initCompleter = completer;

    try {
      packageInfo = await PackageInfo.fromPlatform();

      final storage = this.storage ??
          SharedPreferencesUpdateStorage(await SharedPreferences.getInstance());

      storageManager = UpdateStorageManager(storage);

      await sourceSupportChecker.init();
      await storageManager.cleanup();

      completer.complete();
    } catch (e, s) {
      completer.completeError(e, s);
      initCompleter = null;
      rethrow;
    }
  }

  @override
  Stream<void> get onFetch => onFetchStreamController.stream;

  @override
  Future<void> fetch(
    UpdateSearchConfig searchConfig, {
    bool shouldFetchSourceFetchers = true,
    bool shouldFetchFetchers = true,
  }) async {
    await init();

    final configs = await fetcherCoordinator.fetch(
      fetchers: fetchers,
      searchConfig: searchConfig,
      packageInfo: packageInfo,
      shouldFetchSourceFetchers: shouldFetchSourceFetchers,
      shouldFetchFetchers: shouldFetchFetchers,
    );

    final updates = linker.linkAllConfigs(configs);

    this.updates = updates;
    onFetchStreamController.add(null);
  }

  @override
  UpdateResult findUpdate(UpdateSearchConfig searchConfig) {
    if (!isInitialized) {
      throw Exception('UpdateController is not initialized');
    }

    final searchResult = updateSearcher.searchFull(
      updates: updates,
      searchConfig: searchConfig,
      packageInfo: packageInfo,
    );

    final searchData = searchResult.searchData;
    final mostRelevantUpdate = searchResult.updateData;

    if (mostRelevantUpdate == null) {
      final result = UpdateResult(
        updateStatus: const UpdateNotFoundException(),
        searchData: searchData,
        update: null,
      );

      return result;
    }

    final result = updateResolver.resolve(
      updateData: mostRelevantUpdate,
      searchData: searchData,
    );

    final update = result.update;

    // Проверяем storage если update найден
    if (update != null) {
      // Проверка allUpdatesPostponed
      if (storageManager.isAllUpdatesPostponed()) {
        return UpdateResult(
          updateStatus: const UpdatePostponedException(),
          searchData: searchData,
          update: update,
        );
      }

      // Проверка пропущенного обновления
      final skippedUpdate = storageManager.getSkippedUpdate(update.version);
      if (skippedUpdate != null) {
        return UpdateResult(
          updateStatus: UpdateSkippedException(postponedUpdate: skippedUpdate),
          searchData: searchData,
          update: update,
        );
      }

      // Проверка отложенного обновления
      final postponedUpdate = storageManager.getPostponedUpdate(update.version);
      if (postponedUpdate != null) {
        return UpdateResult(
          updateStatus:
              UpdatePostponedException(postponedUpdate: postponedUpdate),
          searchData: searchData,
          update: update,
        );
      }
    }

    return result;
  }

  @override
  Future<void> launchUpdateUrl(Update update) async {
    final uri = Uri.parse(update.content.updateUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Future<void> postponeUpdate(Update update) async {
    await storageManager.onUpdatePostpone(update);
  }

  @override
  Future<void> skipUpdate(Update update) async {
    await storageManager.onUpdateSkip(update);
  }

  @override
  void dispose() {
    onFetchStreamController.close();
  }
}
