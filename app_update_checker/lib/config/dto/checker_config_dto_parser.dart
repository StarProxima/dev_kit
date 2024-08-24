// ignore_for_file: prefer-type-over-var, avoid-negated-conditions, avoid-collection-mutating-methods

import 'package:yaml/yaml.dart';

import '../entity/version.dart';
import 'checker_config_dto.dart';
import 'release_dto.dart';
import 'store_dto.dart';

class CheckerConfigDTOParser {
  final bool isDebug;

  const CheckerConfigDTOParser({required this.isDebug});

  CheckerConfigDTO parseFromYaml(String yamlString) {
    final parsedConfig = loadYaml(yamlString);

    return parseConfig(parsedConfig as Map<String, dynamic>);
  }

  CheckerConfigDTO parseConfig(Map<String, dynamic> map) {
    var reminderPeriodInHours = map.remove('reminderPeriodInHours');
    var releaseDelayInHours = map.remove('releaseDelayInHours');
    var deprecatedBeforeVersion = map.remove('deprecatedBeforeVersion');
    var requiredMinimumVersion = map.remove('requiredMinimumVersion');
    var stores = map.remove('stores');
    var releases = map.remove('releases');

    if (reminderPeriodInHours is! int?) {
      if (isDebug) throw const Err();
      reminderPeriodInHours = null;
    } else if (reminderPeriodInHours != null && reminderPeriodInHours < 0) {
      throw const Err();
    }

    if (releaseDelayInHours is! int?) {
      if (isDebug) throw const Err();
      releaseDelayInHours = null;
    } else if (releaseDelayInHours != null && releaseDelayInHours < 0) {
      throw const Err();
    }

    if (deprecatedBeforeVersion is! String?) {
      if (isDebug) throw const Err();
      deprecatedBeforeVersion = null;
    } else if (deprecatedBeforeVersion != null) {
      deprecatedBeforeVersion =
          _safeParse<Version>(() => Version.parse(deprecatedBeforeVersion));
    }

    if (requiredMinimumVersion is! String?) {
      if (isDebug) throw const Err();
      requiredMinimumVersion = null;
    } else if (requiredMinimumVersion != null) {
      requiredMinimumVersion =
          _safeParse<Version>(() => Version.parse(requiredMinimumVersion));
    }

    if (stores is! List<Map<String, dynamic>>?) {
      if (isDebug) throw const Err();
      stores = null;
    } else if (stores != null) {
      stores = stores.map(parseStore).toList().whereType<StoreDTO>();
      stores as List<Object>;
      stores as List<StoreDTO>;
    }

    if (releases is! List<Map<String, dynamic>>?) {
      if (isDebug) throw const Err();
      releases = null;
    } else if (releases != null) {
      releases = releases.map(parseRelease).toList().whereType<ReleaseDTO>();
      releases as List<Object>;
      releases as List<ReleaseDTO>;
    }

    return CheckerConfigDTO(
      reminderPeriod: reminderPeriodInHours != null
          ? Duration(hours: reminderPeriodInHours)
          : null,
      releaseDelay: releaseDelayInHours != null
          ? Duration(hours: releaseDelayInHours)
          : null,
      deprecatedBeforeVersion: deprecatedBeforeVersion,
      requiredMinimumVersion: requiredMinimumVersion,
      stores: stores,
      releases: releases,
      customData: map,
    );
  }

  StoreDTO? parseStore(Map<String, dynamic> map) {
    return null;
  }

  ReleaseDTO? parseRelease(Map<String, dynamic> map) {
    return null;
  }

  // ignore: unused_element
  T? _safeParse<T>(T Function() parse) {
    try {
      return parse();
    } catch (e) {
      if (isDebug) rethrow;

      return null;
    }
  }
}

class Err implements Exception {
  const Err();

  @override
  String toString() {
    // TODO: implement toString
    return super.toString();
  }
}
