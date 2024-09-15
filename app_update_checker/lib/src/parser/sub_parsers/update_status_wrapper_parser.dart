// ignore_for_file: avoid-dynamic, avoid-inferrable-type-arguments

part of '../update_config_parser.dart';

enum WrapperMode {
  all,
  noRequired,
}

class UpdateStatusWrapperParser {
  const UpdateStatusWrapperParser();

  UpdateStatusWrapper<T?> parse<T>(
    dynamic value, {
    required T Function(dynamic value) parse,
    required WrapperMode mode,
  }) {
    if (value is Map<String, dynamic> && value.keys.any((e) => UpdateStatus.values.map((e) => e.name).contains(e))) {
      final requiredValue = value[UpdateStatus.required.name];
      final recommendedValue = value[UpdateStatus.recommended.name];
      final availableValue = value[UpdateStatus.available.name];

      final required = requiredValue == null ? null : parse(requiredValue);
      final recommended = recommendedValue == null ? null : parse(recommendedValue);
      final available = availableValue == null ? null : parse(availableValue);

      return UpdateStatusWrapper<T?>(
        required: required,
        recommended: recommended,
        available: available,
      );
    }

    final parsedValue = parse(value);

    switch (mode) {
      case WrapperMode.all:
        return UpdateStatusWrapper<T?>.all(parsedValue);

      case WrapperMode.noRequired:

        // Extends to `recommended` and `available`, but not `required`
        return UpdateStatusWrapper<T?>(
          required: null,
          recommended: parsedValue,
          // ignore: no-equal-arguments
          available: parsedValue,
        );
    }
  }
}
