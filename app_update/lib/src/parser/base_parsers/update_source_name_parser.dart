import '../../shared/entities/update_source_name.dart';
import '../common.dart';

class UpdateSourceNameParser {
  const UpdateSourceNameParser();

  UpdateSourceName? parse(
    dynamic value,
  ) {
    if (value == null) return null;

    if (value is! String) throw const UpdateConfigException();

    return UpdateSourceName.custom(value);
  }
}
