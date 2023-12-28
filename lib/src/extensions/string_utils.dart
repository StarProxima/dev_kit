extension StringUtilsX on String {
  String? trimOrNull() {
    final str = trim();
    return str.isEmpty ? null : str;
  }

  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
