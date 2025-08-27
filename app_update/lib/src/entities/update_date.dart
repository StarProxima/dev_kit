import 'update_entity.dart';

// ignore: prefer-overriding-parent-equality
base class UpdateDate extends UpdateEntityName {
  static const localReleaseDate = UpdateDate(
    null,
    name: r'$localReleaseDate',
  );
  static const updateReleaseDate = UpdateDate(
    null,
    name: r'$updateReleaseDate',
  );
  static const appUpdateDate = UpdateDate(
    null,
    name: r'$appUpdateDate',
  );
  static const appInstallDate = UpdateDate(
    null,
    name: r'$appInstallDate',
  );
  static const any = UpdateDate(
    null,
    name: 'any',
  );

  final DateTime? date;

  static const values = [
    localReleaseDate,
    updateReleaseDate,
    appUpdateDate,
    appInstallDate,
  ];

  static const valuesWithAny = [
    ...values,
    any,
  ];

  const UpdateDate(
    this.date, {
    String name = 'direct',
  }) : super(name);

  @override
  List<Object?> get params => [name, date];

  @override
  String get debugString =>
      // ignore: prefer-date-format
      'UpdateDate(${date == null ? '' : '$date, '}$name)';
}
