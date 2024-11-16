// ignore_for_file: avoid-missing-enum-constant-in-map

import 'package:flutter/foundation.dart';

import '../../shared/update_alert_type.dart';
import '../../shared/version_status.dart';
import 'release_settings_config.dart';

class UpdateSettingsConfigContainer {
  final Map<UpdateAlertTypeBase, Map<VersionStatusBase, UpdateSettingsConfig>> value;

  const UpdateSettingsConfigContainer(this.value);

  @visibleForTesting
  UpdateSettingsConfig? getBy({
    required UpdateAlertType type,
    required VersionStatus status,
  }) =>
      getByBase(
        type: type.toBase(),
        status: status.toBase(),
      );

  @visibleForTesting
  UpdateSettingsConfig? getByBase({
    required UpdateAlertTypeBase type,
    required VersionStatusBase status,
  }) {
    final byType = value[type] ?? value[UpdateAlertTypeBase.base];
    final byStatus = byType?[status] ?? byType?[VersionStatusBase.base];

    return byStatus;
  }
}
