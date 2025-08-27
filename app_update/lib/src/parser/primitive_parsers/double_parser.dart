import '../parse_config_exeption.dart';

class DoubleParser {
  const DoubleParser();

  double? parse({
    // ignore: avoid-dynamic
    required dynamic value,
  }) {
    if (value == null) return null;

    if (value is num) {
      final doubleValue = value.toDouble();
      if (doubleValue.isNaN || !doubleValue.isFinite) {
        throw const ParseConfigException();
      }
      return doubleValue;
    }

    throw ParseConfigException.wrongType(
      rightType: double,
      wrongType: value.runtimeType,
      parserType: DoubleParser,
      configs: [value],
    );
  }
}
