import '../../entities/update_source_name.dart';
import '../parse_config_exeption.dart';

class UpdateSourceNameParser {
  const UpdateSourceNameParser();

  UpdateSourceName? parse(
    dynamic value,
  ) {
    if (value == null) return null;

    if (value is! String) {
      throw ParseConfigException.wrongType(
        rightType: String,
        wrongType: value.runtimeType,
        parserType: UpdateSourceNameParser,
        configs: [value],
      );
    }

    return UpdateSourceName.custom(value);
  }
}
