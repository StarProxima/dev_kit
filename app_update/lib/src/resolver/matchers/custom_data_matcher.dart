import '../../shared/models/mergeable.dart';
import '../../shared/models/update_rule/update_rule_config.dart';
import '../../shared/models/update_search/update_search_data.dart';
import '../rule_matcher.dart';

/// Матчер для проверки кастомных полей правила с суффиксом '_is'.
///
/// Работает аналогично другим матчерам: поддерживает 'any' значения,
/// case-insensitive сравнение и списки.
///
/// Работает только с примитивными типами: null, String, num, bool и List примитивов.
/// Поля с Map или List<Map> игнорируются для безопасности.
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

    // Фильтруем только поля правила, заканчивающиеся на '_is' и содержащие примитивы
    final filteredRuleCustom = <String, dynamic>{};
    for (final entry in ruleCustom.entries) {
      final key = entry.key.toLowerCase();
      if (key.endsWith('_is') && _isPrimitiveValue(entry.value)) {
        // Убираем суффикс '_is' для сопоставления с полем поиска
        final searchKey = key.substring(0, key.length - 3);
        filteredRuleCustom[searchKey] = entry.value;
      }
    }

    if (filteredRuleCustom.isEmpty) return true;
    return _primitiveContainsCaseInsensitive(filteredRuleCustom, searchCustom);
  }

  /// Проверяет, является ли значение примитивным типом или списком примитивов
  bool _isPrimitiveValue(dynamic value) {
    if (value == null) return true;
    if (value is String || value is num || value is bool) return true;
    if (value is List) {
      return value.every((item) =>
          item == null || item is String || item is num || item is bool);
    }
    return false; // Map и другие сложные типы не поддерживаются
  }

  /// Сравнение только примитивных типов с поддержкой case-insensitive для строк
  bool _primitiveContainsCaseInsensitive(
      Map<String, dynamic> ruleFields, Map<String, dynamic> searchFields) {
    for (final entry in ruleFields.entries) {
      final key = entry.key.toLowerCase();
      final ruleValue = entry.value;

      // Найти соответствующее поле в данных поиска (case-insensitive)
      final searchEntry = searchFields.entries.firstWhere(
        (e) => e.key.toLowerCase() == key,
        orElse: () => MapEntry('', null),
      );

      if (searchEntry.key.isEmpty) return false; // Поле не найдено

      final searchValue = searchEntry.value;
      if (!_primitiveValuesMatch(ruleValue, searchValue)) {
        return false;
      }
    }
    return true;
  }

  /// Сравнивает два примитивных значения или списка примитивов
  bool _primitiveValuesMatch(dynamic rule, dynamic search) {
    if (rule == null) return true;
    if (search == null) return false;

    if (rule is String) {
      if (rule.toLowerCase() == 'any') return true;
      if (search is String) {
        return rule.toLowerCase() == search.toLowerCase();
      }
      if (search is List) {
        return search
            .any((s) => s is String && s.toLowerCase() == rule.toLowerCase());
      }
      return false;
    }

    if (rule is num && search is num) return rule == search;
    if (rule is bool && search is bool) return rule == search;

    if (rule is List && search is List) {
      // Пустой список в правиле означает "никто не разрешен"
      if (rule.isEmpty) return false;

      // Проверяем наличие 'any' в списке правила
      final hasAny = rule.any((e) => e is String && e.toLowerCase() == 'any');
      if (hasAny) return true;

      // Ищем пересечение списков - хотя бы один элемент из search должен быть в rule
      for (final searchItem in search) {
        for (final ruleItem in rule) {
          if (_primitiveValuesMatch(ruleItem, searchItem)) return true;
        }
      }
      return false;
    }

    if (search is List) {
      return search.any((s) => _primitiveValuesMatch(rule, s));
    }
    if (rule is List) {
      // Пустой список в правиле означает "никто не разрешен"
      if (rule.isEmpty) return false;
      return rule.any((r) => _primitiveValuesMatch(r, search));
    }

    return rule == search;
  }
}
