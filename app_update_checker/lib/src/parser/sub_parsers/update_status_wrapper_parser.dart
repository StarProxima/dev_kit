part of '../update_config_parser.dart';

class UpdateStatusWrapperParser {
  const UpdateStatusWrapperParser();

  // ignore: avoid-dynamic, prefer-named-parameters
  UpdateStatusWrapper<T?> parse<T>(dynamic value, T Function(dynamic value) parse) {
    if (value is Map<String, dynamic> && value.keys.any((e) => UpdateStatus.values.map((e) => e.name).contains(e))) {
      final requiredValue = value[UpdateStatus.required.name];
      final recommendedValue = value[UpdateStatus.recommended.name];
      final availableValue = value[UpdateStatus.available.name];

      final required = requiredValue == null ? null : parse(requiredValue);
      final recommended = recommendedValue == null ? null : parse(recommendedValue);
      final available = availableValue == null ? null : parse(availableValue);

      // ignore: avoid-inferrable-type-arguments
      return UpdateStatusWrapper<T?>(
        required: required,
        recommended: recommended,
        available: available,
      );
    }

    final parsedValue = parse(value);

    // Extends to `recommended` and `available`, but not `required`
    return UpdateStatusWrapper<T?>(
      required: null,
      recommended: parsedValue,
      // ignore: no-equal-arguments
      available: parsedValue,
    );
  }
}
