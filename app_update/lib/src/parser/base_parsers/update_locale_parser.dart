import '../../shared/update_locale.dart';
import '../primitive_parsers/locale_parser.dart';
import '../update_config_exception.dart';

class UpdateLocaleParser {
  static const _localeParser = LocaleParser();

  const UpdateLocaleParser();

  UpdateLocale? parse(
    dynamic value,
  ) {
    if (value is! String?) throw const UpdateConfigException();

    if (value == null) return null;

    final byName = UpdateLocale(null, name: value);

    if (UpdateLocale.values.contains(byName)) {
      return byName;
    }

    final locale = _localeParser.parse(value);

    if (locale == null) return null;

    return UpdateLocale(locale);
  }
}
