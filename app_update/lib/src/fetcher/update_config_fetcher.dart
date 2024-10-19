// ignore_for_file: prefer_initializing_formals

import 'dart:async';
import 'dart:io';
import 'package:yaml/yaml.dart';

import '../shared/raw_update_config.dart';

class UpdateConfigFetcher {
  final Future<RawUpdateConfig> Function() _onFetch;

  const UpdateConfigFetcher.custom({
    required Future<RawUpdateConfig> Function() onFetch,
  }) : _onFetch = onFetch;

  factory UpdateConfigFetcher.byUrl({required Uri uri}) {
    return UpdateConfigFetcher.custom(onFetch: () => _defaultFetchByUrl(uri));
  }

  Future<RawUpdateConfig> fetch() {
    return _onFetch();
  }
}

Future<RawUpdateConfig> _defaultFetchByUrl(Uri uri) async {
  final file = File.fromUri(uri);
  final fileText = await file.readAsString();
  final config = await loadYaml(fileText);
  if (config is Map<String, dynamic>) {
    return config;
  }
  throw ArgumentError('Wrong yaml format file on $uri');
}
