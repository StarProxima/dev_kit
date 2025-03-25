// ignore_for_file: avoid-dynamic, avoid-recursive-calls

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

  factory UpdateConfigFetcher.byFile({required File file}) {
    return UpdateConfigFetcher.custom(onFetch: () => _defaultFetchByFile(file));
  }

  Future<RawUpdateConfig> fetch() {
    return _onFetch();
  }
}

Future<RawUpdateConfig> _defaultFetchByUrl(Uri uri) async {
  final file = File.fromUri(uri);
  final fileText = await file.readAsString();
  final config = await loadYaml(fileText);
  if (config is YamlMap) {
    return config.toMap();
  }
  throw ArgumentError('Wrong yaml format file on $uri');
}

Future<RawUpdateConfig> _defaultFetchByFile(File file) async {
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
