// ignore_for_file: avoid-dynamic, avoid-recursive-calls

import 'dart:async';
import 'dart:ui';

import 'package:package_info_plus/package_info_plus.dart';

import '../entities/update_source.dart';
import '../models/release/update_data.dart';
import '../models/update_config/update_config.dart';
import '../models/update_content/update_content_config.dart';
import '../models/update_rule/update_rule_config.dart';
import 'source_fetchers/app_store_fetcher.dart';
import 'source_fetchers/google_play_fetcher.dart';
import 'source_fetchers/ru_store_fetcher.dart';
import 'update_config_fetcher.dart';

abstract class UpdateConfigSourceFetcher implements UpdateConfigFetcher {
  static const defaultFetchers = [
    GooglePlayFetcher(),
    AppStoreFetcher(),
    RuStoreFetcher(),
  ];

  const UpdateConfigSourceFetcher();

  UpdateSource get source;

  /// Возвращает дефолтный url для открытия стора из приложения
  ///
  /// Например, для google play:
  /// https://play.google.com/store/apps/details?id=com.example.app
  Future<Uri?> getSourceAppUrl({
    required Locale locale,
    required PackageInfo packageInfo,
  });

  /// Получает список возможных обовлений из стора (чаще всего последнее).
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

    final updates = await fetchUpdates(locale: locale, packageInfo: packageInfo)
        .onError<Object>(
      (e, s) {
        Future.error(e, s);

        return [];
      },
    );

    final urlContentRules = url == null
        ? null
        : [
            UpdateRuleConfig(
              sourceIs: [source],
              data: UpdateContentConfig(
                updateUrl: url.toString(),
              ),
            ),
          ];

    final releases = updates.map((e) => e.toReleaseConfig()).toList();

    return UpdateConfig(
      contentRules: urlContentRules,
      releases: releases,
    );
  }
}
