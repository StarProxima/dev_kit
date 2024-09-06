// ignore_for_file: prefer_initializing_formals

import 'dart:async';

typedef RawUpdateConfig = Map<String, dynamic>;

class UpdateConfigProvider {
  final Future<RawUpdateConfig> Function()? _onFetch;
  final String? _url;

  const UpdateConfigProvider.custom({
    required Future<RawUpdateConfig> Function() onFetch,
  })  : _onFetch = onFetch,
        _url = null;

  const UpdateConfigProvider.url({
    required String url,
  })  : _url = url,
        _onFetch = null;

  Future<RawUpdateConfig> fetch() {
    // ignore: avoid-non-null-assertion
    if (_onFetch != null) return _onFetch!();

    // ignore: unnecessary_statements
    _url;

    throw UnimplementedError();
  }
}
