extension NullIfEmptyStringExtension on String {
  String? trimOrNull() {
    final str = trim();
    return str.isEmpty ? null : str;
  }
}
