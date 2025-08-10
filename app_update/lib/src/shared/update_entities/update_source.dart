import 'package:flutter/foundation.dart';

import 'update_entity.dart';
import 'update_platform.dart';

@immutable
class UpdateSource extends UpdateEntity {
  static const googlePlay = UpdateSource._('googlePlay', platforms: [UpdatePlatform.android]);
  static const appStore =
      UpdateSource._('appStore', platforms: [UpdatePlatform.ios, UpdatePlatform.macos]);
  static const testFlight =
      UpdateSource._('testFlight', platforms: [UpdatePlatform.ios, UpdatePlatform.macos]);
  static const gitHub = UpdateSource._(
    'gitHub',
    platforms: [
      UpdatePlatform.android,
      UpdatePlatform.windows,
      UpdatePlatform.linux,
      UpdatePlatform.macos,
    ],
  );
  static const any = UpdateSource._('any', platforms: [UpdatePlatform.any]);

  final List<UpdatePlatform>? platforms;

  const UpdateSource._(super._name, {this.platforms});

  const factory UpdateSource.custom(String name, {List<UpdatePlatform>? platforms}) =
      UpdateSource._;

  static const values = [
    googlePlay,
    appStore,
    testFlight,
    gitHub,
    any,
  ];
}
