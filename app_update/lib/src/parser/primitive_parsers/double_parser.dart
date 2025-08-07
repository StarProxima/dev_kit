import '../common.dart';

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
        throw const UpdateConfigException();
      }
      return doubleValue;
    }

    throw const UpdateConfigException();
  }
}
