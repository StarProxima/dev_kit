// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment, prefer-correct-identifier-length, avoid-recursive-calls, avoid-non-null-assertion, avoid-explicit-type-declaration

part of '../update_config_parser.dart';

class UpdateTextContainerParser {
  UpdateTextParser get _updateTextParser => const UpdateTextParser();

  RawContainerParser get _rawContainerParser => const RawContainerParser();

  const UpdateTextContainerParser();

  UpdateTextConfigContainer? parse(
    // ignore: avoid-dynamic
    dynamic value, {
    required bool isDebug,
  }) {
    if (value is! Map?) {
      throw const UpdateConfigException();
    }

    if (value == null || value.isEmpty) return null;

    // ignore: avoid-unnecessary-type-assertions
    if (value is! Map<String, dynamic>) return null;

    final map = _rawContainerParser.parse<UpdateTextConfig>(
      value,
      parse: (e) => _updateTextParser.parse(e, isDebug: false),
    );

    return UpdateTextConfigContainer(map);
  }
}
