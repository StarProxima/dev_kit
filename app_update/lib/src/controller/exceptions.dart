import '../localizer/models/app_update.dart';

abstract class UpdateException implements Exception {}

class UpdateNotFoundException implements UpdateException {
  const UpdateNotFoundException();

  @override
  String toString() => 'UpdateNotFoundException';
}

class UpdateSkippedException implements UpdateException {
  final AppUpdate update;

  const UpdateSkippedException({
    required this.update,
  });

  @override
  String toString() => 'UpdateSkippedException: $update';
}

class UpdatePostponedException implements UpdateException {
  final AppUpdate update;

  const UpdatePostponedException({
    required this.update,
  });

  @override
  String toString() => 'UpdateNotFoundException';
}
