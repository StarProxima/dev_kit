/// Миксин для поддержки регулярных выражений в матчерах правил.
mixin RegExpMatcherMixin {
  static const _regexpPrefix = 'regexp:';

  /// Проверяет совпадение значения со списком возможных вариантов.
  /// Поддерживает:
  /// - Обычные строки: точное совпадение (case-insensitive)
  /// - 'any': всегда true
  /// - 'regexp:pattern': проверка по регулярному выражению.
  bool isMatchesStringInListWithRegExp(
    String searchValue,
    List<String> ruleValues,
  ) {
    // Проверка на 'any' в списке правил
    if (ruleValues.any((ruleValue) => ruleValue.toLowerCase() == 'any')) {
      return true;
    }

    final searchStr = searchValue.toLowerCase();

    // Проверяем каждое значение из списка правил
    for (final ruleValue in ruleValues) {
      final ruleStr = ruleValue.toLowerCase();

      // Проверка на регулярное выражение
      if (ruleStr.startsWith(_regexpPrefix)) {
        final pattern = ruleStr.substring(_regexpPrefix.length);

        final regex = RegExp(pattern, caseSensitive: false);
        if (regex.hasMatch(searchStr)) return true;
      }
      // Обычное сравнение строк
      else if (ruleStr == searchStr) {
        return true;
      }
    }

    return false;
  }
}
