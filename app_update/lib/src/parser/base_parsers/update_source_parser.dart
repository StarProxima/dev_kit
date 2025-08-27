import '../../entities/update_source.dart';
import '../parse_config_exeption.dart';
import '../primitive_parsers/string_parser.dart';
import 'update_platform_parser.dart';
import 'update_source_name_parser.dart';

class UpdateSourceParser {
  static const _updatePlatformParser = UpdatePlatformParser();
  static const _updateSourceNameParser = UpdateSourceNameParser();
  static const _stringParser = StringParser();

  const UpdateSourceParser();

  UpdateSource? parse(
    Object? value,
  ) {
    if (value == null) return null;

    // Short syntax
    if (value is String) {
      final name = _updateSourceNameParser.parse(value)!;

      return UpdateSource.custom(name);
    }

    if (value is! Map) {
      throw ParseConfigException.wrongType(
        rightType: Map,
        wrongType: value.runtimeType,
        parserType: UpdateSourceParser,
        configs: [value],
      );
    }

    final map = value;

    final nameValue = map.remove('name');
    final name = _stringParser.parse(nameValue);

    final sourceName = _updateSourceNameParser.parse(name);

    if (sourceName == null) throw const ParseConfigException();

    final platformsValue = map.remove('platforms');
    if (platformsValue is! List?) throw const ParseConfigException();

    final platforms =
        platformsValue?.map(_updatePlatformParser.parse).nonNulls.toList();

    final source = UpdateSource.custom(sourceName, platforms: platforms);

    return source;
  }
}
