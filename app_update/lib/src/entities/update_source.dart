import 'package:flutter/foundation.dart';

import '../models/global_platform/global_platform_config.dart';
import '../models/global_source/global_source_config.dart';
import '../models/release_platrform/release_platrform_config.dart';
import '../models/release_source/release_source_config.dart';
import 'update_entity.dart';
import 'update_platform.dart';
import 'update_source_name.dart';

@immutable
base class UpdateSource extends UpdateEntity {
  static const googlePlay = UpdateSource._(
    UpdateSourceName.googlePlay,
    platforms: [UpdatePlatform.android],
  );

  static const appStore = UpdateSource._(
    UpdateSourceName.appStore,
    platforms: [UpdatePlatform.ios, UpdatePlatform.macos],
  );

  static const testFlight = UpdateSource._(
    UpdateSourceName.testFlight,
    platforms: [UpdatePlatform.ios, UpdatePlatform.macos],
  );

  static const ruStore = UpdateSource._(
    UpdateSourceName.ruStore,
    platforms: [UpdatePlatform.android],
  );

  static const gitHub = UpdateSource._(
    UpdateSourceName.gitHub,
    platforms: [
      UpdatePlatform.android,
      UpdatePlatform.windows,
      UpdatePlatform.linux,
      UpdatePlatform.macos,
    ],
  );

  static const any =
      UpdateSource._(UpdateSourceName.any, platforms: [UpdatePlatform.any]);

  final List<UpdatePlatform>? platforms;
  final UpdateSourceName sourceName;

  static const values = [
    googlePlay,
    appStore,
    testFlight,
    gitHub,
    ruStore,
  ];

  static const valuesWithAny = [
    ...values,
    any,
  ];

  const UpdateSource._(this.sourceName, {this.platforms});

  const factory UpdateSource.custom(
    UpdateSourceName sourceName, {
    List<UpdatePlatform>? platforms,
  }) = UpdateSource._;

  @override
  List<Object?> get params => [sourceName, ...?platforms];
}

extension ReleaseSourceConfigToUpdateSourceX on ReleaseSourceConfig {
  UpdateSource toUpdateSource() => UpdateSource.custom(
        sourceName,
        platforms: platforms?.map((e) => e.platformName).toList(),
      );
}

extension GlobalSourceConfigToUpdateSourceX on GlobalSourceConfig {
  UpdateSource toUpdateSource() => UpdateSource.custom(
        sourceName,
        platforms: platforms?.map((e) => e.platformName).toList(),
      );
}

extension UpdateSourceX on UpdateSource {
  GlobalSourceConfig toGlobalSourceConfig() => GlobalSourceConfig(
        sourceName: sourceName,
        platforms: platforms
            ?.map(
              (platform) => GlobalPlatformConfig(platformName: platform),
            )
            .toList(),
      );

  ReleaseSourceConfig toReleaseSourceConfig() => ReleaseSourceConfig(
        sourceName: sourceName,
        platforms: platforms
            ?.map(
              (platform) => ReleasePlatformConfig(platformName: platform),
            )
            .toList(),
      );
}
