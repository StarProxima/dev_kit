import '../../shared/update_date.dart';
import '../primitive_parsers/date_time_parser.dart';
import '../common.dart';

class UpdateDateParser {
  static const _dateParser = DateTimeParser();

  const UpdateDateParser();

  UpdateDate? parse(
    dynamic value,
  ) {
    if (value == null) return null;

    if (value is! String) throw const UpdateConfigException();

    final byName = UpdateDate(null, name: value);

    if (UpdateDate.values.contains(byName)) {
      return byName;
    }

    final date = _dateParser.parse(value);

    if (date == null) return null;

    return UpdateDate(date);
  }
}
