// ignore_for_file: avoid-dynamic, avoid-recursive-calls

import 'dart:async';
import 'dart:ui';
import 'package:package_info_plus/package_info_plus.dart';

import '../shared/models/release/update_data.dart';
import '../shared/models/update/update_config.dart';
import '../shared/models/update_content/update_content_config.dart';
import '../shared/models/update_rule/update_rule_config.dart';
import '../shared/update_entities/update_source.dart';

sealed class UpdateConfigFetcherBase {
  const UpdateConfigFetcherBase();

  Future<UpdateConfig> fetch({
    required Locale locale,
    required PackageInfo packageInfo,
  });
}

abstract class UpdateConfigFetcherGlobal extends UpdateConfigFetcherBase {
  const UpdateConfigFetcherGlobal();

  @override
  Future<UpdateConfig> fetch({
    required Locale locale,
    required PackageInfo packageInfo,
  });
}

abstract class UpdateConfigFetcherBySource extends UpdateConfigFetcherBase {
  const UpdateConfigFetcherBySource();

  UpdateSource get source;

  /// Возвращает дефолтный url для открытия стора из приложения
  ///
  /// Например, для google play:
  /// https://play.google.com/store/apps/details?id=com.example.app
  Future<Uri?> getSourceAppUrl({
    required Locale locale,
    required PackageInfo packageInfo,
  });

  /// Получает список возможных обовлений из стора (чаще всего последнее)
  Future<List<UpdateData>> fetchUpdates({
    required Locale locale,
    required PackageInfo packageInfo,
  });

  @override
  Future<UpdateConfig> fetch({
    required Locale locale,
    required PackageInfo packageInfo,
  }) async {
    final url = await getSourceAppUrl(locale: locale, packageInfo: packageInfo);

    final updates = await fetchUpdates(locale: locale, packageInfo: packageInfo).onError<Object>(
      (e, s) {
        Future.error(e, s);

        return [];
      },
    );

    final urlContentRules = url != null
        ? [
            UpdateRuleConfig(
              sources: [source],
              data: UpdateContentConfig(
                updateUrl: url,
              ),
            ),
          ]
        : null;

    final releases = updates.map((e) => e.toReleaseConfig()).toList();

    return UpdateConfig(
      contentRules: urlContentRules,
      releases: releases,
    );
  }
}
