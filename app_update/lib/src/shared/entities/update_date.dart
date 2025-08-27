import 'update_entity.dart';

base class UpdateDate extends UpdateEntityName {
  static const any = UpdateDate(null, name: 'any');
  static const localReleaseDate = UpdateDate(null, name: r'$localReleaseDate');
  static const updateReleaseDate =
      UpdateDate(null, name: r'$updateReleaseDate');

  final DateTime? date;

  const UpdateDate(
    this.date, {
    String name = 'direct',
  }) : super(name);

  @override
  List<Object?> get params => [name, date];

  static const values = [
    localReleaseDate,
    updateReleaseDate,
  ];

  static const allValues = [
    ...values,
    any,
  ];
}
