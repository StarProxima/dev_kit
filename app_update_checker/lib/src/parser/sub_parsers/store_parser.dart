// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

part of '../update_config_parser.dart';

class StoreParser {
  const StoreParser();

  SourceConfig? parse(
    // ignore: avoid-dynamic
    dynamic value, {
    required bool isGlobalStore,
    required bool isDebug,
  }) {
    // short string syntax
    if (value is! Map<String, dynamic>) {
      if (!isGlobalStore && value is String) {
        return SourceConfig(
          name: value,
          url: null,
          platforms: null,
          customData: null,
        );
      }

      if (isDebug) throw const UpdateConfigException();

      return null;
    }

    // full syntax

    final map = value;

    // name
    var name = map.remove('name');

    if (name is! String?) {
      if (isDebug) throw const UpdateConfigException();
      name = null;
    }

    if (name == null) {
      if (isDebug) throw const UpdateConfigException();

      return null;
    }

    // url
    var url = map.remove('url');

    if (url is! String?) {
      if (isDebug) throw const UpdateConfigException();
      url = null;
    }

    url = url == null ? null : Uri.tryParse(url);
    url as Uri?;

    if (isGlobalStore && url == null) return null;
    if (isDebug && url == null) throw const UpdateConfigException();

    // platforms
    var platforms = map.remove('platforms');

    if (platforms is! List<String>?) {
      if (isDebug) throw const UpdateConfigException();
      platforms = null;
    }

    platforms = platforms?.map(UpdatePlatform.new).toList();
    platforms as List<UpdatePlatform>?;

    return SourceConfig(
      name: name,
      url: url,
      platforms: platforms,
      customData: map,
    );
  }
}
