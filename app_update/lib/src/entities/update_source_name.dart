import 'package:flutter/foundation.dart';

import 'update_entity.dart';

@immutable
base class UpdateSourceName extends UpdateEntityName {
  static const googlePlay = UpdateSourceName._('googlePlay');
  static const appStore = UpdateSourceName._('appStore');
  static const testFlight = UpdateSourceName._('testFlight');
  static const gitHub = UpdateSourceName._('gitHub');
  static const ruStore = UpdateSourceName._('ruStore');
  static const any = UpdateSourceName._('any');

  const UpdateSourceName._(super._name);

  const factory UpdateSourceName.custom(String name) = UpdateSourceName._;

  static const values = [
    googlePlay,
    appStore,
    testFlight,
    gitHub,
    ruStore,
  ];

  static const allValues = [
    ...values,
    any,
  ];
}
