// ignore_for_file: avoid-accessing-other-classes-private-members, avoid-unnecessary-getter, avoid-collection-mutating-methods
import 'dart:ui';

import '../interpolator/models/update_texts.dart';
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

typedef UpdateTextData = UpdateTextConfig;

class UpdateTextContainer {
  final Map<Locale, Map<UpdateAlertTypeBase, Map<VersionStatusBase, UpdateText>>> map;

  const UpdateTextContainer(this.map);

  UpdateText getBy({
    required Locale locale,
    required UpdateAlertType type,
    required VersionStatus status,
  }) =>
      getByBase(
        locale: locale,
        type: type.toBase(),
        status: status.toBase(),
      );

  UpdateText getByBase({
    required Locale locale,
    required UpdateAlertTypeBase type,
    required VersionStatusBase status,
  }) {
    // final byBaseLocale = map[const Locale('base')];
    // if (byBaseLocale == null) throw Exception();

    // final byLocale = map[locale] ?? byBaseLocale;

    // final byType = byLocale[type] ??
    //     byBaseLocale[type] ??
    //     byLocale[UpdateAlertTypeBase.base] ??
    //     byBaseLocale[UpdateAlertTypeBase.base];

    // if (byType == null) throw Exception();

    // final byStatus = byType[status] ??
    //     byBaseLocale[UpdateAlertTypeBase.base]?[status] ??
    //     byType[VersionStatusBase.base] ??
    //     byBaseLocale[UpdateAlertTypeBase.base]?[VersionStatusBase.base];

    // if (byStatus == null) throw Exception();

    const baseLocale = Locale('base');
    const baseType = UpdateAlertTypeBase.base;
    const baseStatus = VersionStatusBase.base;

    // TODO: Это пиздец, нихуя непонятно

    final byLocale = map[locale] ?? map[baseLocale]!;

    final byType = byLocale[type] ?? map[baseLocale]![type] ?? byLocale[baseType] ?? map[baseLocale]![baseType]!;

    final byStatus = byType[status] ?? byType[baseStatus]!;

    return byStatus;
  }
}
