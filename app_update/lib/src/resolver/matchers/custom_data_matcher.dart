import '../../shared/models/mergeable.dart';
import '../../shared/models/update_rule/update_rule_config.dart';
import '../../shared/models/update_search/update_search_data.dart';
import 'rule_matcher.dart';

/// Матчер для проверки кастомных полей правила с суффиксом '_is'.
/// Работает аналогично другим матчерам: поддерживает 'any' значения,
/// case-insensitive сравнение и списки.
class CustomDataMatcher implements RuleMatcher {
  const CustomDataMatcher();

  @override
  bool matches<T extends Mergeable>(
      {required UpdateRuleConfig<T> rule, required UpdateSearchData search}) {
    return _matchByCustomData(
      rule.customData,
      search.customData,
    );
  }

  bool _matchByCustomData(
      Map<String, dynamic>? ruleCustom, Map<String, dynamic>? searchCustom) {
    if (ruleCustom == null || ruleCustom.isEmpty) return true;
    if (searchCustom == null || searchCustom.isEmpty) return false;

    // Фильтруем только поля правила, заканчивающиеся на '_is'
    final filteredRuleCustom = <String, dynamic>{};
    for (final entry in ruleCustom.entries) {
      final key = entry.key.toLowerCase();
      if (key.endsWith('_is')) {
        // Убираем суффикс '_is' для сопоставления с полем поиска
        final searchKey = key.substring(0, key.length - 3);
        filteredRuleCustom[searchKey] = entry.value;
      }
    }

    if (filteredRuleCustom.isEmpty) return true;
    return _deepContainsCaseInsensitive(filteredRuleCustom, searchCustom);
  }

  bool _deepContainsCaseInsensitive(dynamic rule, dynamic search) {
    if (rule == null) return true;
    if (search == null) return false;

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

    if (rule is num && search is num) return rule == search;
    if (rule is bool && search is bool) return rule == search;

    if (rule is Map && search is Map) {
      final Map<String, dynamic> searchNormalized = {
        for (final e in search.entries)
          (e.key is String ? (e.key as String) : e.key.toString())
              .toLowerCase(): e.value,
      };
      for (final e in rule.entries) {
        final keyLc = (e.key is String ? (e.key as String) : e.key.toString())
            .toLowerCase();
        if (!searchNormalized.containsKey(keyLc)) return false;
        if (!_deepContainsCaseInsensitive(e.value, searchNormalized[keyLc])) {
          return false;
        }
      }
      return true;
    }

    if (rule is List && search is List) {
      final hasAny = rule.any((e) => e is String && e.toLowerCase() == 'any');
      if (hasAny) return true;
      for (final s in search) {
        for (final r in rule) {
          if (_deepContainsCaseInsensitive(r, s)) return true;
        }
      }
      return false;
    }

    if (search is List) {
      return search.any((s) => _deepContainsCaseInsensitive(rule, s));
    }
    if (rule is List) {
      return rule.any((r) => _deepContainsCaseInsensitive(r, search));
    }

    return rule == search;
  }
}
