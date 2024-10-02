// // ignore_for_file: prefer-test-matchers, avoid-long-functions

// import 'package:flutter_test/flutter_test.dart';
// import 'package:update_check/src/parser/models/update_config_exception.dart';
// import 'package:update_check/src/parser/update_config_parser.dart';
// import 'package:update_check/src/shared/update_platform.dart';

// void main() {
//   group('StoreParser', () {
//     const storeParser = StoreParser();
//     const isDebug = true;

//     test('should parse store with short syntax', () {
//       const value = 'googlePlay';
//       final result = storeParser.parse(value, isGlobalStore: false, isDebug: isDebug);

//       expect(result, isNotNull);
//       expect(result?.name, 'googlePlay');
//       expect(result?.url, isNull);
//       expect(result?.platforms, isNull);
//     });

//     test('should parse store with full syntax', () {
//       final value = {
//         'name': 'gitHub',
//         'platforms': ['android', 'Windows', 'macOS', 'linux', 'Aurora'],
//         'url': 'https://example.com',
//       };
//       final result = storeParser.parse(value, isGlobalStore: false, isDebug: isDebug);

//       expect(result, isNotNull);
//       expect(result?.name, 'gitHub');
//       expect(result?.url?.toString(), 'https://example.com');
//       expect(result?.platforms, [
//         UpdatePlatform.android,
//         UpdatePlatform.windows,
//         UpdatePlatform.macos,
//         UpdatePlatform.linux,
//         const UpdatePlatform('aurora'),
//       ]);
//     });

//     test('should return null if global store with invalid URL', () {
//       final value = {
//         'name': 'gitHub',
//         'url': '::invalid-url::',
//       };
//       final result = storeParser.parse(value, isGlobalStore: true, isDebug: isDebug);

//       expect(result, isNull);
//     });

//     test('should return null if store name is missing', () {
//       final value = {
//         'url': 'https://example.com',
//       };

//       expect(
//         () => storeParser.parse(value, isGlobalStore: false, isDebug: isDebug),
//         throwsA(isA<UpdateConfigException>()),
//       );
//     });

//     test('should throw exception in debug mode when name is not a string', () {
//       final value = {
//         'name': 123, // Некорректный тип для name
//         'url': 'https://example.com',
//       };

//       expect(
//         () => storeParser.parse(value, isGlobalStore: false, isDebug: isDebug),
//         throwsA(isA<UpdateConfigException>()),
//       );
//     });

//     test('should return null if platforms is not a list', () {
//       final value = {
//         'name': 'gitHub',
//         'platforms': 'not-a-list', // Некорректный тип для platforms
//         'url': 'https://example.com',
//       };
//       final result = storeParser.parse(value, isGlobalStore: false, isDebug: false);

//       expect(result, isNotNull);
//       expect(result?.platforms, isNull);
//     });

//     test('should parse store with custom data', () {
//       final value = {
//         'customField': 'customValue',
//         'name': 'customStore',
//         'url': 'https://example.com',
//       };
//       final result = storeParser.parse(value, isGlobalStore: false, isDebug: isDebug);

//       expect(result, isNotNull);
//       expect(result?.name, 'customStore');
//       expect(result?.url?.toString(), 'https://example.com');
//       expect(result?.customData?['customField'], 'customValue');
//     });
//   });
// }
