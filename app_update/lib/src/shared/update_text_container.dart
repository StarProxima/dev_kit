// ignore_for_file: avoid-accessing-other-classes-private-members, avoid-unnecessary-getter, avoid-collection-mutating-methods
import 'dart:ui';

import '../parser/models/update_text_config.dart';
import 'update_alert_type.dart';
import 'version_status.dart';

class UpdateTextConfigContainer {
  final Map<UpdateAlertTypeBase, Map<VersionStatusBase, Map<Locale, UpdateTextConfig>>> value;

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
    final byType = value[type] ?? value[UpdateAlertTypeBase.base];
    final byStatus = byType?[status] ?? byType?[VersionStatusBase.base];
    final byLocale = byStatus?[locale] ?? byStatus?[const Locale('base')];

    return byLocale;
  }
}
