// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var

part of '../checker_config_dto_parser.dart';

class _StoreParser {
  const _StoreParser();

  StoreDTO? parse(
    Map<String, dynamic> map, {
    required bool isStrict,
    required bool isDebug,
  }) {
    var name = map.remove('name');
    var url = map.remove('url');
    var platforms = map.remove('platforms');

    if (name is! String?) {
      if (isDebug) throw const DtoParserException();
      name = null;
    }

    if (name == null) {
      if (isDebug) throw const DtoParserException();

      return null;
    }

    if (url is! String?) {
      if (isDebug) throw const DtoParserException();
      url = null;
    }

    if (isStrict && url == null) return null;

    url = url == null ? null : Uri.tryParse(url);

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
