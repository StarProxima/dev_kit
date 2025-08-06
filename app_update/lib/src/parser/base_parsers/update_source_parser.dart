import '../../shared/update_platform.dart';
import '../../shared/update_source.dart';
import '../primitive_parsers/string_parser.dart';
import '../update_config_exception.dart';
import 'update_platform_parser.dart';

class UpdateSourceParser {
  static const _updatePlatformParser = UpdatePlatformParser();
  static const _stringParser = StringParser();

  const UpdateSourceParser();

  UpdateSource? parse(
    dynamic value,
  ) {
    if (value == null) return null;

    // Short syntax
    if (value is String) {
      return UpdateSource.custom(value);
    }

    if (value is! Map) throw const UpdateConfigException();
    final map = value;

    final nameValue = map.remove('name');
    final name = _stringParser.parse(nameValue);

    if (name == null) throw const UpdateConfigException();

    final platformsValue = map.remove('platforms');
    if (platformsValue is! List?) throw const UpdateConfigException();

    final platforms = platformsValue?.map(_updatePlatformParser.parse).nonNulls.toList();

    final source = UpdateSource.custom(name, platforms: platforms);

    return source;
  }
}
