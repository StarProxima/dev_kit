import 'package:collection/collection.dart';

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
class CustomParamsMatcher extends RuleMatcher with RegExpMatcherMixin {
  const CustomParamsMatcher();

  @override
  bool isMatches({
    required UpdateRuleConfig rule,
    required UpdateSearchData search,
  }) {
    return _isMatchBycustomParams(
      rule.when?.customParams,
      search.customParams,
    );
  }

  bool _isMatchBycustomParams(
    Map<String, dynamic>? ruleCustom,
    Map<String, dynamic>? searchCustom,
  ) {
    if (ruleCustom == null || ruleCustom.isEmpty) return true;

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

    return _isPrimitiveContainsCaseInsensitive(
      filteredRuleCustom,
      searchCustom,
    );
  }

  /// Проверяет, является ли значение примитивным типом или списком примитивов.
  static bool _isPrimitiveValue(Object? value) {
    if (value == null) return true;
    if (value is String || value is num || value is bool) return true;

    // Map и другие сложные типы не поддерживаются
    final isPrimitive = value is List &&
        value.every(
          (item) =>
              item == null || item is String || item is num || item is bool,
        );

    return isPrimitive;
  }

  /// Сравнение только примитивных типов с поддержкой case-insensitive для строк.
  bool _isPrimitiveContainsCaseInsensitive(
    Map<String, dynamic> ruleFields,
    Map<String, dynamic>? searchFields,
  ) {
    for (final entry in ruleFields.entries) {
      final key = entry.key.toLowerCase();
      final ruleValue = entry.value;

      // Найти соответствующее поле в данных поиска (case-insensitive)
      final searchEntry = searchFields?.entries.firstWhereOrNull(
        (e) => e.key.toLowerCase() == key,
      );

      final searchValue = searchEntry?.value;
      if (!_isPrimitiveValuesMatch(ruleValue, searchValue)) {
        return false;
      }
    }

    return true;
  }

  /// Сравнивает два примитивных значения или списка примитивов с поддержкой регулярок.
  bool _isPrimitiveValuesMatch(Object? rule, Object? search) {
    if (rule == null) return true;

    // Обработка строк с поддержкой регулярок
    if (rule is String && search is String?) {
      return isMatchesStringWithRegExp(
        searchValue: search,
        ruleValue: rule,
      );
    }

    // Точное сравнение для чисел и булевых
    if (rule is num && search is num) return rule == search;
    if (rule is bool && search is bool) return rule == search;

    // Обработка списков
    if (rule is List && search is List) {
      return _isMatchListToList(rule, search);
    }

    if (search is List) {
      return _isMatchValueToList(rule, search);
    }

    if (rule is List) {
      return _isMatchListToValue(rule, search);
    }

    return rule == search;
  }

  /// Сравнивает список правил со списком поиска (пересечение).
  bool _isMatchListToList(
    List<Object?> ruleValues,
    List<Object?> searchValues,
  ) {
    if (ruleValues.contains('any')) return true;

    // Проверяем пересечение списков
    for (final searchValue in searchValues) {
      for (final ruleValue in ruleValues) {
        if (_isPrimitiveValuesMatch(ruleValue, searchValue)) return true;
      }
    }

    return false;
  }

  /// Сравнивает одно значение правила со списком поиска.
  bool _isMatchValueToList(Object ruleValue, List<Object?> searchValues) {
    if (ruleValue == 'any') return true;

    final isMatch = searchValues.any(
      (searchValue) => _isPrimitiveValuesMatch(ruleValue, searchValue),
    );

    return isMatch;
  }

  /// Сравнивает список правил с одним значением поиска.
  bool _isMatchListToValue(List<Object?> ruleValues, Object? searchValue) {
    if (ruleValues.contains('any')) return true;

    final isMatch = ruleValues.any(
      (ruleValue) => _isPrimitiveValuesMatch(ruleValue, searchValue),
    );

    return isMatch;
  }
}
