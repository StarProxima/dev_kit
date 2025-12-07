import '../../entities/update_locale.dart';
import '../parse_config_exeption.dart';
import '../primitive_parsers/locale_parser.dart';

class UpdateLocaleParser {
  static const _localeParser = LocaleParser();

  const UpdateLocaleParser();

  UpdateLocale? parse(
    Object? value,
  ) {
    if (value == null) return null;

    if (value is! String) {
      throw ParseConfigException.wrongType(
        rightType: String,
        wrongType: value.runtimeType,
        parserType: UpdateLocaleParser,
        configs: [value],
      );
    }

    final byName = UpdateLocale(null, name: value);

    if (UpdateLocale.valuesWithAny.contains(byName)) {
      return byName;
    }

    final locale = _localeParser.parse(value);

    if (locale == null) return null;

    return UpdateLocale(locale);
  }
}
