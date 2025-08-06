// ignore_for_file: parameter_assignments

class ListOrValueParser {
  const ListOrValueParser();

  List<dynamic>? parse(
    // ignore: avoid-dynamic
    dynamic value,
  ) {
    if (value == null) return null;

    if (value is List) return value;

    return [value];
  }
}
