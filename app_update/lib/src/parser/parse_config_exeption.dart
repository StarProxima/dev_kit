import 'dart:convert';

class ParseConfigException implements Exception {
  final String? message;
  final List<Object>? configs;

  final Type? parserType;

  // ignore: prefer-named-parameters
  const ParseConfigException([
    this.message,
    this.parserType,
    this.configs,
  ]);

  ParseConfigException.wrongType({
    required Type rightType,
    required Type wrongType,
    required this.parserType,
    required this.configs,
  }) : message =
            'Wrong type: $wrongType, expected: $rightType, related configs:\n${jsonEncode(configs)}';

  ParseConfigException.unexpectedParams({
    required Map<String, Object?> params,
    required this.parserType,
    required this.configs,
  }) : message =
            'Unexpected params:\n${jsonEncode(params)}\nrelated configs:\n${jsonEncode(configs)}';

  @override
  // ignore: avoid-nullable-interpolation
  String toString() => 'ParseConfigException in $parserType - $message';
}
