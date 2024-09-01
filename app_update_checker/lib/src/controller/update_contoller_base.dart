import 'dart:async';

import '../config/dto/models/release_settings_dto.dart';
import '../config/dto/models/store_dto.dart';
import '../config/entity/stores/fetchers/store_fetcher.dart';
import 'update_config_provider.dart';
import 'update_data.dart';

typedef OnUpdate = FutureOr<void> Function(UpdateData data);

abstract class UpdateContollerBase {
  // ignore: prefer-boolean-prefixes
  final bool autoFetch;
  final UpdateConfigProvider? updateConfigProvider;
  final StoreFetcherCoordinator? storeFetcherCoordinator;
  final ReleaseSettingsDTO? releaseSettings;
  final List<StoreDTO>? stores;
  final OnUpdate? onUpdate;

  Stream<UpdateData> get updateStream;

  UpdateContollerBase({
    this.updateConfigProvider,
    this.autoFetch = true,
    this.storeFetcherCoordinator,
    this.releaseSettings,
    this.stores,
    this.onUpdate,
  }) {
    if (autoFetch) fetch();
  }

  Future<void> fetch();
}
