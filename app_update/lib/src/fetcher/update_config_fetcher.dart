// ignore_for_file: avoid-dynamic, avoid-recursive-calls

import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:yaml/yaml.dart';

import '../parser/common.dart';
import '../parser/update_config_parser.dart';
import '../shared/models/update/update_config.dart';

/// Базовый класс для фетчера конфига
///
/// Дает интерфейс [fetch]
/// и предоставляет конструкторы с дефолтной реализацией.
interface class UpdateConfigFetcher {
  final UpdateConfigParser _updateConfigParser;
  final FutureOr<Map<String, dynamic>> Function()? _fetchRawConfig;
  final FutureOr<UpdateConfig> Function()? _fetchConfig;

  factory UpdateConfigFetcher.config(UpdateConfig config) =>
      UpdateConfigFetcher.custom(
        () => config,
      );

  const UpdateConfigFetcher.custom(
    FutureOr<UpdateConfig> Function() fetchConfig,
  )   : _fetchConfig = fetchConfig,
        _fetchRawConfig = null,
        _updateConfigParser = const UpdateConfigParser();

  const UpdateConfigFetcher.customRaw(
    FutureOr<Map<String, dynamic>> Function() fetchRawConfig, {
    UpdateConfigParser? updateConfigParser,
  })  : _fetchRawConfig = fetchRawConfig,
        _fetchConfig = null,
        _updateConfigParser = updateConfigParser ?? const UpdateConfigParser();

  factory UpdateConfigFetcher.byUrl(Uri uri) => UpdateConfigFetcher.customRaw(
        () => _defaultFetchByUrl(uri),
      );

  factory UpdateConfigFetcher.byFile(File file) =>
      UpdateConfigFetcher.customRaw(
        () => _defaultFetchByFile(file),
      );

  /// Fetch UpdateConfig
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
