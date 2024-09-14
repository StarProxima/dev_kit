part of '../update_config_parser.dart';

class UpdateStatusWrapperParser {
  const UpdateStatusWrapperParser();

  // ignore: avoid-dynamic, prefer-named-parameters
  UpdateStatusWrapper<T?> parse<T>(dynamic value, T Function(dynamic value) parse) {
    if (value is Map<String, dynamic> &&
        value.keys.any((e) => const ['required', 'recommended', 'available'].contains(e))) {
      final requiredValue = value['required'];
      final recommendedValue = value['recommended'];
      final availableValue = value['available'];

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

    return UpdateStatusWrapper<T?>(
      required: null,
      recommended: null,
      available: parse(value),
    );
  }
}
