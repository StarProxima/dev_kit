// ignore_for_file: avoid-missing-enum-constant-in-map

import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../../shared/update_alert_type.dart';
import '../../shared/version_status.dart';
import 'update_text_config.dart';

class UpdateTextConfigContainer {
  final Map<Locale, Map<UpdateAlertTypeBase, Map<VersionStatusBase, UpdateTextConfig>>> value;

  const UpdateTextConfigContainer(this.value);

  UpdateTextConfigContainer.fromUpdateTextConfig(UpdateTextConfig config)
      : value = {
          const Locale('base'): {
            UpdateAlertTypeBase.base: {VersionStatusBase.base: config},
          },
        };

  @visibleForTesting
  UpdateTextConfig? getBy({
    required UpdateAlertType type,
    required VersionStatus status,
    required Locale locale,
  }) =>
      getByBase(
        type: type.toBase(),
        status: status.toBase(),
        locale: locale,
      );

  @visibleForTesting
  UpdateTextConfig? getByBase({
    required UpdateAlertTypeBase type,
    required VersionStatusBase status,
    required Locale locale,
  }) {
    final byLocale = value[locale] ?? value[const Locale('base')];
    final byType = byLocale?[type] ?? byLocale?[UpdateAlertTypeBase.base];
    final byStatus = byType?[status] ?? byType?[VersionStatusBase.base];

    return byStatus;
  }
}
