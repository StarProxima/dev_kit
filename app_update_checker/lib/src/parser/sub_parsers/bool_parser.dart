part of '../update_config_parser.dart';

class BoolParser {
  UpdateStatusWrapperParser get updateStatusWrapperParser => const UpdateStatusWrapperParser();

  const BoolParser();

  UpdateStatusWrapper<bool?> parseWithStatuses(
    // ignore: avoid-dynamic
    dynamic value, {
    required bool isDebug,
  }) {
    // ignore: avoid-inferrable-type-arguments
    return updateStatusWrapperParser.parse<bool?>(
      value,
      (value) => parse(value, isDebug: isDebug),
    );
  }

  // ignore: prefer-boolean-prefixes
  bool? parse(
    // ignore: avoid-dynamic
    dynamic value, {
    required bool isDebug,
  }) {
    if (value is bool?) return value;
    if (isDebug) throw const UpdateConfigException();

    return null;
  }
}
