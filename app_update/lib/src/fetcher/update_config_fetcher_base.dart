// ignore_for_file: avoid-dynamic, avoid-recursive-calls

import 'dart:async';
import 'dart:ui';
import 'package:package_info_plus/package_info_plus.dart';

import '../shared/models/update/update_config.dart';
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

  @override
  Future<UpdateConfig> fetch({
    required Locale locale,
    required PackageInfo packageInfo,
  });
}
