import 'package:store_checker/store_checker.dart';

import '../entities/update_platform.dart';
import '../entities/update_source.dart';

// Не тестим, т.к. внешнее апи.
// coverage:ignore-file
class UpdateSupportedSourcesChecker {
  Source _sourceFromStoreChecker = Source.UNKNOWN;

  UpdateSupportedSourcesChecker();

  Future<void> init() async {
    _sourceFromStoreChecker = await StoreChecker.getSource.onError(
      (_, __) => Source.UNKNOWN,
    );
  }

  List<UpdateSource> getDefaultSupportedSources({
    required UpdatePlatform platform,
  }) {
    final updateSourceByStoreChecker = switch (_sourceFromStoreChecker) {
      Source.IS_INSTALLED_FROM_PLAY_STORE ||
      Source.IS_INSTALLED_FROM_PLAY_PACKAGE_INSTALLER =>
        UpdateSource.googlePlay,
      Source.IS_INSTALLED_FROM_RU_STORE => UpdateSource.ruStore,
      Source.IS_INSTALLED_FROM_APP_STORE => UpdateSource.appStore,
      Source.IS_INSTALLED_FROM_TEST_FLIGHT => UpdateSource.testFlight,
      // ignore: avoid-wildcard-cases-with-enums
      _ => null,
    };

    final sources = {
      updateSourceByStoreChecker,
      if (platform == UpdatePlatform.android) UpdateSource.googlePlay,
      if (platform == UpdatePlatform.ios) UpdateSource.appStore,
    }.nonNulls.toList();

    return sources;
  }
}

class UpdateSourceSupportCheckerNoOp implements UpdateSupportedSourcesChecker {
  @override
  Future<void> init() async {}

  @override
  List<UpdateSource> getDefaultSupportedSources({
    required UpdatePlatform platform,
  }) {
    return [];
  }

  @override
  Source _sourceFromStoreChecker = Source.UNKNOWN;
}
