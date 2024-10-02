// ignore_for_file: prefer-test-matchers, avoid-long-functions

import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:update_check/src/shared/version_x.dart';

void main() {
  group('Version.parse', () {
    test('should parse simple version string', () {
      final version = Version.parse('1.0.0');
      expect(version.major, 1);
      expect(version.minor, 0);
      expect(version.patch, 0);
      expect(version.isPreRelease, isFalse);
      expect(version.build, isEmpty);
    });

    test('should parse version string with pre-release', () {
      final version = Version.parse('1.0.0-beta');
      expect(version.major, 1);
      expect(version.minor, 0);
      expect(version.patch, 0);
      expect(version.isPreRelease, isTrue);
      expect(version.preRelease, ['beta']);
    });

    test('should parse version string with pre-release and build info', () {
      final version = Version.parse('1.0.0-beta+build123');
      expect(version.major, 1);
      expect(version.minor, 0);
      expect(version.patch, 0);
      expect(version.isPreRelease, isTrue);
      expect(version.preRelease, ['beta']);
      expect(version.build.firstOrNull, 'build123');
    });

    test('should parse version string with multiple pre-release segments', () {
      final version = Version.parse('1.0.0-beta.1');
      expect(version.major, 1);
      expect(version.minor, 0);
      expect(version.patch, 0);
      expect(version.isPreRelease, isTrue);
      expect(version.preRelease, ['beta', 1]);
    });

    test('should parse version string with build info only', () {
      final version = Version.parse('1.0.0+123');
      expect(version.major, 1);
      expect(version.minor, 0);
      expect(version.patch, 0);
      expect(version.isPreRelease, isFalse);
      expect(version.build.firstOrNull, 123);
    });

    test('should throw FormatException version with missing minor or patch', () {
      expect(() => Version.parse('2.0'), throwsFormatException);
    });

    test('should throw FormatException for invalid version string', () {
      expect(() => Version.parse('invalid-version'), throwsFormatException);
    });

    test('should throw FormatException for empty version string', () {
      expect(() => Version.parse(''), throwsFormatException);
    });
  });

  group('VersionX Extension', () {
    test('toOnlyNumbersString should return version without pre-release or build info', () {
      final version = Version.parse('1.2.3-beta+build123');
      final result = version.toOnlyNumbersString();
      expect(result, '1.2.3');
    });

    test('toVersionWithBuildString should return version with build info but without pre-releases', () {
      final version = Version.parse('1.2.3-beta+build123');
      final result = version.toVersionWithBuildString();
      expect(result, '1.2.3+build123');
    });

    test('toVersionWithBuildString should return only version and build when there is no pre-release', () {
      final version = Version.parse('1.2.3+build123');
      final result = version.toVersionWithBuildString();
      expect(result, '1.2.3+build123');
    });

    test(
      'toVersionWithBuildString should return just version numbers when there is no build or pre-release',
      () {
        final version = Version.parse('1.2.3');
        final result = version.toVersionWithBuildString();
        expect(result, '1.2.3');
      },
    );

    test('toVersionWithBuildString should return version without pre-release and empty build info', () {
      final version = Version.parse('1.2.3-beta');
      final result = version.toVersionWithBuildString();
      expect(result, '1.2.3');
    });
  });
}
