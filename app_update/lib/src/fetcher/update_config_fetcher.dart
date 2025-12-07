// ignore_for_file: avoid-dynamic, avoid-recursive-calls

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:yaml/yaml.dart';

import '../models/update_config/update_config.dart';
import '../parser/parse_config_exeption.dart';
import '../parser/update_config_parser.dart';

/// Базовый класс для фетчера конфига
///
/// Дает интерфейс [fetch]
/// и предоставляет конструкторы с дефолтной реализацией.
interface class UpdateConfigFetcher {
  final UpdateConfigParser _updateConfigParser;
  final FutureOr<Map<String, dynamic>> Function()? _onFetchRawConfig;
  final FutureOr<UpdateConfig> Function()? _onFetchConfig;

  factory UpdateConfigFetcher.config(UpdateConfig config) =>
      UpdateConfigFetcher.custom(
        () => config,
      );

  const UpdateConfigFetcher.custom(
    FutureOr<UpdateConfig> Function() fetchConfig,
  )   : _onFetchConfig = fetchConfig,
        _onFetchRawConfig = null,
        _updateConfigParser = const UpdateConfigParser();

  const UpdateConfigFetcher.customRaw(
    FutureOr<Map<String, dynamic>> Function() fetchRawConfig, {
    UpdateConfigParser? updateConfigParser,
  })  : _onFetchRawConfig = fetchRawConfig,
        _onFetchConfig = null,
        _updateConfigParser = updateConfigParser ?? const UpdateConfigParser();

  factory UpdateConfigFetcher.byUrl(Uri uri) => UpdateConfigFetcher.customRaw(
        () => _defaultFetchByUrl(uri),
      );

  factory UpdateConfigFetcher.byFile(File file) =>
      UpdateConfigFetcher.customRaw(
        () => _defaultFetchByFile(file),
      );

  /// Fetch UpdateConfig.
  Future<UpdateConfig> fetch({
    required Locale locale,
    required PackageInfo packageInfo,
  }) async {
    final fetchRawConfig = _onFetchRawConfig;
    if (fetchRawConfig != null) {
      final result = await fetchRawConfig();
      final config = _updateConfigParser.parse(
        result,
        isDebug: true,
      );

      if (config == null) {
        throw const ParseConfigException();
      }

      return config;
    }

    final fetchConfig = _onFetchConfig;
    if (fetchConfig != null) {
      final config = await fetchConfig();

      return config;
    }

    throw const ParseConfigException();
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
      // ignore: avoid-type-casts
      map[(k as YamlScalar).value.toString()] = _convertNode(v.value);
    });

    return map;
  }
}
