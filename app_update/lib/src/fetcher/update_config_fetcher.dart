// ignore_for_file: avoid-dynamic, avoid-recursive-calls

import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:yaml/yaml.dart';

import '../parser/common.dart';
import '../parser/update_config_parser.dart';
import '../shared/models/update/update_config.dart';
import 'update_config_fetcher_base.dart';

class UpdateConfigFetcher implements UpdateConfigFetcherBase {
  final UpdateConfigParser _updateConfigParser;

  final Future<Map<String, dynamic>> Function()? _fetchRawConfig;
  final Future<UpdateConfig> Function()? _fetchConfig;

  const UpdateConfigFetcher.custom(
    Future<UpdateConfig> Function() fetchConfig, {
    UpdateConfigParser? updateConfigParser,
  })  : _fetchConfig = fetchConfig,
        _fetchRawConfig = null,
        _updateConfigParser = updateConfigParser ?? const UpdateConfigParser();

  const UpdateConfigFetcher.customRaw(
    Future<Map<String, dynamic>> Function() fetchRawConfig, {
    UpdateConfigParser? updateConfigParser,
  })  : _fetchRawConfig = fetchRawConfig,
        _fetchConfig = null,
        _updateConfigParser = updateConfigParser ?? const UpdateConfigParser();

  factory UpdateConfigFetcher.byUrl({required Uri uri}) => UpdateConfigFetcher.customRaw(
        () => _defaultFetchByUrl(uri),
      );

  factory UpdateConfigFetcher.byFile({required File file}) => UpdateConfigFetcher.customRaw(
        () => _defaultFetchByFile(file),
      );

  @override
  Future<UpdateConfig> fetch({
    required Locale locale,
    required PackageInfo packageInfo,
  }) async {
    final fetchRawConfig = _fetchRawConfig;
    if (fetchRawConfig != null) {
      final result = await fetchRawConfig();
      final config = _updateConfigParser.parse(result);

      if (config == null) {
        throw const UpdateConfigException();
      }

      return config;
    }

    final fetchConfig = _fetchConfig;
    if (fetchConfig != null) {
      final config = await fetchConfig();
      return config;
    }

    throw const UpdateConfigException();
  }
}

Future<Map<String, dynamic>> _defaultFetchByUrl(Uri uri) async {
  final file = File.fromUri(uri);
  final fileText = await file.readAsString();
  final config = await loadYaml(fileText);
  if (config is YamlMap) {
    return config.toMap();
  }
  throw ArgumentError('Wrong yaml format file on $uri');
}

Future<Map<String, dynamic>> _defaultFetchByFile(File file) async {
  final fileText = await file.readAsString();
  final config = await loadYaml(fileText);
  if (config is YamlMap) {
    return config.toMap();
  }
  throw ArgumentError('Wrong yaml format file on ${file.path}');
}

extension YamlMapConverter on YamlMap {
  dynamic _convertNode(dynamic v) {
    if (v is YamlMap) {
      return v.toMap();
    } else if (v is YamlList) {
      final list = <dynamic>[];
      for (final e in v) {
        list.add(_convertNode(e));
      }

      return list;
    }

    return v;
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    nodes.forEach((k, v) {
      map[(k as YamlScalar).value.toString()] = _convertNode(v.value);
    });

    return map;
  }
}
