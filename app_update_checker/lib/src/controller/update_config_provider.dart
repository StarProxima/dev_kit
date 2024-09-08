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
    final onFetch = _onFetch;
    if (onFetch != null) return onFetch();

    // ignore: unused_local_variable
    final url = _url;

    // TODO: Implement it
    throw UnimplementedError();
  }
}
