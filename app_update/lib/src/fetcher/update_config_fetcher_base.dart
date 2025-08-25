// ignore_for_file: avoid-dynamic, avoid-recursive-calls

import 'dart:async';
import 'dart:ui';
import 'package:package_info_plus/package_info_plus.dart';

import '../shared/models/update/update_config.dart';

abstract class UpdateConfigFetcherBase {
  const UpdateConfigFetcherBase();

  Future<UpdateConfig> fetch({
    required Locale locale,
    required PackageInfo packageInfo,
  });
}
