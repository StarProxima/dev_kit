extension StringUtilsX on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

extension StringTrimOrNullX on String? {
  String? trimOrNull() {
    final str = this;
    if (str == null) return null;

    final trim = str.trim();
    return trim.isEmpty ? null : trim;
  }
}
