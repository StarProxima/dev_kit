import 'update_entity.dart';

class UpdateDate extends UpdateEntity {
  static const any = UpdateDate(null, 'any');
  static const localReleaseDate = UpdateDate(null, 'localReleaseDate');
  static const updateReleaseDate = UpdateDate(null, 'updateReleaseDate');

  final DateTime? date;

  const UpdateDate(
    this.date, [
    super._name = 'direct',
  ]);

  @override
  List<Object?> get params => [name, date];
}
