// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var

part of '../checker_config_dto_parser.dart';

class _StoreParser {
  const _StoreParser();

  StoreDTO? parse(
    Map<String, dynamic> map, {
    required bool isStrict,
    required bool isDebug,
  }) {
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

    return StoreDTO(
      name: name,
      url: url,
      platforms: platforms,
      customData: map,
    );
  }
}
