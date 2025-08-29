import 'dart:convert';

class ParseConfigException implements Exception {
  final String? message;
  final List<Object> configs;

  final Type? parserType;

  // ignore: prefer-named-parameters
  const ParseConfigException([
    this.message,
    this.parserType,
    this.configs = const [],
  ]);

  ParseConfigException.wrongType({
    required Type rightType,
    required Type wrongType,
    required this.parserType,
    required this.configs,
  }) : message = 'Wrong type: $wrongType, expected: $rightType';

  ParseConfigException.unexpectedParams({
    required Map<String, Object?> params,
    required this.parserType,
    required this.configs,
  }) : message =
            // ignore: avoid-nullable-interpolation
            'Unexpected params:\n[\n${params.entries.map((e) => '  "${e.key}": "${e.value}"').join(',\n')}\n]';

  ParseConfigException.requiredParams({
    required List<String> params,
    required this.parserType,
    required this.configs,
  }) : message = 'Required params not found: [\n  ${params.join(',\n  ')}\n]';

  @override
  String toString() =>
      // ignore: avoid-nullable-interpolation
      'ParseConfigException in $parserType - $message\n\nrelated configs:\n[\n  ${configs.map(jsonEncode).join(',\n  ')}\n]';
}
