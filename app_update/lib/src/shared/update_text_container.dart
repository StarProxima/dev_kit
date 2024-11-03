// ignore_for_file: avoid-accessing-other-classes-private-members, avoid-unnecessary-getter, avoid-collection-mutating-methods
import 'dart:ui';

import '../parser/models/update_text_config.dart';
import 'update_alert_type.dart';
import 'version_status.dart';

class UpdateTextConfigContainer {
  final Map<Locale, Map<UpdateAlertTypeBase, Map<VersionStatusBase, UpdateTextConfig>>> value;

  const UpdateTextConfigContainer(this.value);

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
