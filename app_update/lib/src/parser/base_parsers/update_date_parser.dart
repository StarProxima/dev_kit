import '../../entities/update_date.dart';
import '../parse_config_exeption.dart';
import '../primitive_parsers/date_time_parser.dart';

class UpdateDateParser {
  static const _dateParser = DateTimeParser();

  const UpdateDateParser();

  UpdateDate? parse(
    dynamic value,
  ) {
    if (value == null) return null;

    if (value is! String) {
      throw ParseConfigException.wrongType(
        rightType: String,
        wrongType: value.runtimeType,
        parserType: UpdateDateParser,
        configs: [value],
      );
    }

    final byName = UpdateDate(null, name: value);

    if (UpdateDate.values.contains(byName)) {
      return byName;
    }

    final date = _dateParser.parse(value);

    if (date == null) return null;

    return UpdateDate(date);
  }
}
