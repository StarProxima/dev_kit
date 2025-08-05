import 'package:flutter/foundation.dart';

import 'update_entity.dart';
import 'update_platform.dart';

@immutable
class UpdateSource extends UpdateEntity {
  static const googlePlay = UpdateSource._('googlePlay', [UpdatePlatform.android]);
  static const appStore = UpdateSource._('appStore', [UpdatePlatform.ios, UpdatePlatform.macos]);
  static const testFlight = UpdateSource._('testFlight', [UpdatePlatform.ios, UpdatePlatform.macos]);
  static const gitHub = UpdateSource._(
    'gitHub',
    [
      UpdatePlatform.android,
      UpdatePlatform.windows,
      UpdatePlatform.linux,
      UpdatePlatform.macos,
    ],
  );
  static const any = UpdateSource._('any', [UpdatePlatform.any]);

  final List<UpdatePlatform> platforms;

  const UpdateSource._(super._name, this.platforms);

  const factory UpdateSource.custom(String name, List<UpdatePlatform> platforms) = UpdateSource._;
}
