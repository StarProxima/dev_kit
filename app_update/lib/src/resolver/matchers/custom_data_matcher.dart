import '../../utils/mergeable.dart';
import '../../models/update_rule/update_rule_config.dart';
import '../../models/update_search/update_search_data.dart';
import '../base/reg_exp_matcher_mixin.dart';
import '../base/rule_matcher.dart';

/// Матчер для проверки кастомных полей правила с суффиксом '_is'.
///
/// Работает аналогично другим матчерам: поддерживает 'any' значения,
/// case-insensitive сравнение и списки.
///
/// Работает только с примитивными типами: null, String, num, bool и List примитивов.
/// Поля с Map или List<Map> игнорируются для безопасности.
class CustomDataMatcher extends RuleMatcher with RegExpMatcherMixin {
  const CustomDataMatcher();

  @override
  bool isMatches<T extends Mergeable<T>>(
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

    // Проверяем наличие неизвестных полей (не заканчивающихся на '_is')
    final hasUnknownFields =
        ruleCustom.keys.any((key) => !key.toLowerCase().endsWith('_is'));
    if (hasUnknownFields) {
      return false; // Не понимаю неизвестные поля - не подходит
    }

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

  /// Сравнивает два примитивных значения или списка примитивов с поддержкой регулярок
  bool _primitiveValuesMatch(dynamic rule, dynamic search) {
    if (rule == null) return true;
    if (search == null) return false;

    // Обработка строк с поддержкой регулярок
    if (rule is String && search is String) {
      return matchesStringInListWithRegExp(search, [rule]);
    }

    // Точное сравнение для чисел и булевых
    if (rule is num && search is num) return rule == search;
    if (rule is bool && search is bool) return rule == search;

    // Обработка списков
    if (rule is List && search is List) {
      return _matchListToList(rule, search);
    }

    if (search is List) {
      return _matchValueToList(rule, search);
    }

    if (rule is List) {
      return _matchListToValue(rule, search);
    }

    return rule == search;
  }

  /// Сравнивает список правил со списком поиска (пересечение)
  bool _matchListToList(List<dynamic> ruleValues, List<dynamic> searchValues) {
    if (ruleValues.isEmpty) return false; // Пустой список никого не пускает

    // Проверка на 'any' в списке правил
    if (ruleValues
        .any((value) => value is String && value.toLowerCase() == 'any')) {
      return true;
    }

    if (searchValues.isEmpty) return false;

    // Проверяем пересечение списков
    for (final searchValue in searchValues) {
      for (final ruleValue in ruleValues) {
        if (_primitiveValuesMatch(ruleValue, searchValue)) return true;
      }
    }

    return false;
  }

  /// Сравнивает одно значение правила со списком поиска
  bool _matchValueToList(dynamic ruleValue, List<dynamic> searchValues) {
    if (searchValues.isEmpty) return false;

    return searchValues
        .any((searchValue) => _primitiveValuesMatch(ruleValue, searchValue));
  }

  /// Сравнивает список правил с одним значением поиска
  bool _matchListToValue(List<dynamic> ruleValues, dynamic searchValue) {
    if (ruleValues.isEmpty) return false; // Пустой список никого не пускает

    // Проверка на 'any' в списке правил
    if (ruleValues
        .any((value) => value is String && value.toLowerCase() == 'any')) {
      return true;
    }

    // Для строковых значений используем миксин
    if (searchValue is String) {
      final stringRules = ruleValues.whereType<String>().toList();
      if (stringRules.isNotEmpty &&
          matchesStringInListWithRegExp(searchValue, stringRules)) {
        return true;
      }
    }

    // Проверяем остальные типы
    return ruleValues
        .any((ruleValue) => _primitiveValuesMatch(ruleValue, searchValue));
  }
}
