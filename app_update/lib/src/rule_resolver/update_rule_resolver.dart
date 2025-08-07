// ignore_for_file: comment_references

import 'package:pub_semver/pub_semver.dart';

import '../parser/common.dart';
import '../parser/sub_parsers/update_rule_config/update_rule_config.dart';
import '../shared/app_status.dart';
import '../shared/update_date.dart';
import '../shared/update_locale.dart';
import '../shared/update_platform.dart';
import '../shared/update_source.dart';
import '../shared/update_version_constraint.dart';
import '../shared/update_view_target.dart';
import 'models/mergeable.dart';
import 'models/update_search_data.dart';

class UpdateRuleResolver {
  const UpdateRuleResolver();

  /// Резолвит список правил в одно значение типа [T], применяя:
  /// - фильтрацию по контексту (таргет, локаль, источники, версии, статусы)
  /// - временные условия: [date] + [delay] + [rollout]
  /// - сегментацию пользователей: [segmentationPercent]
  ///
  /// Правила применяются по порядку. Последующие правила переопределяют поля предыдущих
  /// через реализацию [Mergeable.merge]. Если ни одно правило не подошло — кидает
  /// [UpdateConfigException].
  ///
  /// Временные условия:
  /// - date: базовая дата срабатывания (или ссылка $localReleaseDate / $updateReleaseDate)
  /// - delay_hours: правило начинает действовать только после (date + delay)
  /// - rollout_hours: прогресс выката = (now - date) / rollout_hours
  ///   - правило доступно, если rolloutPointer <= прогрессу выката (в диапазоне 0..1)
  /// - segmentation_percent: доля пользователей 0..100; правило доступно, если
  ///   segmentationPointer (0..1) <= segmentation_percent / 100
  T resolve<T extends Mergeable>({
    required UpdateSearchData searchData,
    required List<UpdateRuleConfig<T>> rules,
  }) {
    T? result;

    for (final rule in rules) {
      if (!_isRuleMatched(rule: rule, searchData: searchData)) continue;

      final data = rule.data;
      result = result == null ? data : (result.merge(data) as T);
    }

    if (result == null) throw const UpdateConfigException();
    return result;
  }

  bool _isRuleMatched<T extends Mergeable>({
    required UpdateRuleConfig<T> rule,
    required UpdateSearchData searchData,
  }) {
    // 1) Таргет
    if (!_matchByViewTarget(rule.viewTargets, searchData.displayTarget)) return false;

    // 2) Локаль
    if (!_matchByLocale(rule.locales, searchData.locale)) return false;

    // 3) Источники (+ платформа)
    if (!_matchBySources(rule.sources, searchData.sources, searchData.platform)) return false;

    // 4) Версии
    if (!_matchByVersions(rule.versions, searchData.localVersion)) return false;

    // 5) Статус (если задан в поиске)
    if (!_matchByAppStatus(rule.appStatuses, searchData.appStatus)) return false;

    // 6) Дата/задержка/выкатывание/сегментация
    if (!_matchByDateAndRollout(
      ruleDate: rule.date,
      delay: rule.delay,
      rollout: rule.rollout,
      segmentationPercent: rule.segmentationPercent,
      currentDate: searchData.currentDate,
      localReleaseDate: searchData.localReleaseDate,
      updateReleaseDate: searchData.updateReleaseDate,
      rolloutPointer: searchData.rolloutPointer,
      segmentationPointer: searchData.segmentationPointer,
    )) {
      return false;
    }

    // 7) Кастомные поля
    if (!_matchByCustomData(rule.customData, searchData.customData)) return false;

    return true;
  }

  bool _matchByViewTarget(List<UpdateViewTarget> targets, UpdateViewTarget target) {
    return targets.contains(UpdateViewTarget.any) || targets.contains(target);
  }

  bool _matchByLocale(List<UpdateLocale> locales, UpdateLocale locale) {
    return locales.contains(UpdateLocale.any) || locales.contains(locale);
  }

  bool _matchBySources(
    List<UpdateSource> ruleSources,
    List<UpdateSource> searchSources,
    UpdatePlatform platform,
  ) {
    if (ruleSources.contains(UpdateSource.any)) return true;

    for (final ruleSource in ruleSources) {
      final matchedSearchSource = _findSource(searchSources, ruleSource);
      if (matchedSearchSource == null) continue;

      if (_sourceSupportsPlatform(ruleSource, platform, matchedSearchSource)) {
        return true;
      }
    }
    return false;
  }

  UpdateSource? _findSource(List<UpdateSource> sources, UpdateSource target) {
    for (final s in sources) {
      if (s == target) return s;
    }
    return null;
  }

  bool _sourceSupportsPlatform(
    UpdateSource ruleSource,
    UpdatePlatform platform,
    UpdateSource searchSource,
  ) {
    final rulePlatforms = ruleSource.platforms;
    if (rulePlatforms == null) {
      // Берём платформы из глобального дефинишена (что пришёл в поиске)
      final globalPlatforms = searchSource.platforms;
      if (globalPlatforms == null || globalPlatforms.isEmpty) return true;
      return globalPlatforms.any((p) => p == platform || p == UpdatePlatform.any);
    }
    if (rulePlatforms.isEmpty) return false; // явное отключение
    return rulePlatforms.any((p) => p == platform || p == UpdatePlatform.any);
  }

  bool _matchByVersions(List<UpdateVersionConstraint> constraints, Version localVersion) {
    if (constraints.contains(UpdateVersionConstraint.any)) return true;
    for (final c in constraints) {
      final vc = c.versionConstraint;
      if (vc != null && vc.allows(localVersion)) return true;
    }
    return false;
  }

  bool _matchByAppStatus(List<AppStatus> ruleStatuses, AppStatus? status) {
    if (status == null) return true; // Поиск для app_status_rules
    return ruleStatuses.contains(AppStatus.any) || ruleStatuses.contains(status);
  }

  bool _matchByDateAndRollout({
    required UpdateDate ruleDate,
    required Duration? delay,
    required Duration? rollout,
    required double? segmentationPercent,
    required DateTime currentDate,
    required DateTime? localReleaseDate,
    required DateTime? updateReleaseDate,
    required double rolloutPointer,
    required double segmentationPointer,
  }) {
    // Сегментация по пользователям (0..100) против pointer (0..1)
    if (segmentationPercent != null) {
      final threshold = segmentationPercent.clamp(0, 100) / 100.0;
      if (segmentationPointer > threshold) return false;
    }

    // Дата/задержка/выкатывание
    // Если даты нет и нет условий по времени — правило подходит
    final hasTemporalConditions = delay != null || rollout != null;
    if (ruleDate == UpdateDate.any && !hasTemporalConditions) return true;

    // Определяем базовую дату для правила
    DateTime? baseDate = ruleDate.date;

    // Динамические ссылки на дату — используем значения из searchData
    if (baseDate == null && ruleDate != UpdateDate.any) {
      if (ruleDate == UpdateDate.localReleaseDate) {
        baseDate = localReleaseDate;
      } else if (ruleDate == UpdateDate.updateReleaseDate) {
        baseDate = updateReleaseDate;
      }
    }

    if (!hasTemporalConditions) {
      // Даже без delay/rollout правило активно не ранее базовой даты
      return baseDate != null && currentDate.isAfter(baseDate) ||
          baseDate != null && currentDate.isAtSameMomentAs(baseDate);
    }

    // Для delay/rollout необходимо знать базовую дату
    if (baseDate == null) return false;

    if (delay != null) {
      final start = baseDate.add(delay);
      if (currentDate.isBefore(start)) return false;
    }

    if (rollout != null) {
      final elapsed = currentDate.difference(baseDate);
      if (elapsed.isNegative) return false;
      final totalMs = rollout.inMilliseconds;
      if (totalMs <= 0) return false;
      final fraction = (elapsed.inMilliseconds / totalMs).clamp(0.0, 1.0);
      if (rolloutPointer > fraction) return false;
    }

    return true;
  }

  bool _matchByCustomData(Map<String, dynamic>? ruleCustom, Map<String, dynamic>? searchCustom) {
    if (ruleCustom == null || ruleCustom.isEmpty) return true;
    if (searchCustom == null || searchCustom.isEmpty) return false;

    return _deepContainsCaseInsensitive(ruleCustom, searchCustom);
  }

  bool _deepContainsCaseInsensitive(dynamic rule, dynamic search) {
    // nulls
    if (rule == null) return true; // отсутствие ограничений в правиле
    if (search == null) return false;

    // String: сравниваем без регистра
    if (rule is String) {
      if (rule.toLowerCase() == 'any') return true;
      if (search is String) {
        return rule.toLowerCase() == search.toLowerCase();
      }
      if (search is List) {
        return search.any((s) => _deepContainsCaseInsensitive(rule, s));
      }
      return false;
    }

    // num/bool: точное сравнение
    if (rule is num && search is num) return rule == search;
    if (rule is bool && search is bool) return rule == search;

    // Map: каждый ключ из rule должен присутствовать в search; ключи без регистра
    if (rule is Map && search is Map) {
      // Построим мапу ключей search в нижнем регистре -> значение
      final Map<String, dynamic> searchNormalized = {
        for (final e in search.entries)
          if (e.key is String)
            (e.key as String).toLowerCase(): e.value
          else
            e.key.toString().toLowerCase(): e.value,
      };
      for (final e in rule.entries) {
        final keyLc = (e.key is String ? (e.key as String) : e.key.toString()).toLowerCase();
        if (!searchNormalized.containsKey(keyLc)) return false;
        if (!_deepContainsCaseInsensitive(e.value, searchNormalized[keyLc])) return false;
      }
      return true;
    }

    // List: принцип как для других условий — достаточно вхождения хотя бы одного элемента из search в rule
    if (rule is List && search is List) {
      // Если в правиле есть 'any' -> любое значение подходит
      final hasAny = rule.any((e) => e is String && e.toLowerCase() == 'any');
      if (hasAny) return true;

      // Достаточно, чтобы хотя бы один элемент из search совпал с любым элементом rule
      for (final s in search) {
        for (final r in rule) {
          if (_deepContainsCaseInsensitive(r, s)) return true;
        }
      }
      return false;
    }

    // Правило-скаляр против списка: достаточно наличия элемента
    if (search is List) {
      return search.any((s) => _deepContainsCaseInsensitive(rule, s));
    }

    // Правило-скаляр против списка: достаточно наличия элемента
    if (rule is List) {
      return rule.any((r) => _deepContainsCaseInsensitive(r, search));
    }

    // По умолчанию — точное сравнение
    return rule == search;
  }
}
