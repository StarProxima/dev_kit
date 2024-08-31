// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

part of '../checker_config_dto_parser.dart';

class _StoreParser {
  const _StoreParser();

  StoreDTO? parse(
    // ignore: avoid-dynamic
    dynamic value, {
    required bool isStrict,
    required bool isDebug,
  }) {
    // short string syntax
    if (value is! Map<String, dynamic>) {
      if (isStrict && value is String) {
        return StoreDTO(
          name: value,
          url: null,
          platforms: null,
          customData: {},
        );
      }

      if (isDebug) throw const DtoParserException();

      return null;
    }

    // full syntax

    final map = value;

    // name
    var name = map.remove('name');

    if (name is! String?) {
      if (isDebug) throw const DtoParserException();
      name = null;
    }

    if (name == null) {
      if (isDebug) throw const DtoParserException();

      return null;
    }

    // url
    var url = map.remove('url');

    if (url is! String?) {
      if (isDebug) throw const DtoParserException();
      url = null;
    }

    if (isStrict && url == null) return null;

    url = url == null ? null : Uri.tryParse(url);

    // platforms
    var platforms = map.remove('platforms');

    if (platforms is! List<String>?) {
      if (isDebug) throw const DtoParserException();
      platforms = null;
    }

    platforms = platforms?.map(UpdatePlatform.new);
    platforms as List<Object>?;
    platforms as List<UpdatePlatform>?;

    return StoreDTO(
      name: name,
      url: url,
      platforms: platforms,
      customData: map,
    );
  }
}
