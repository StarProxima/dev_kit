import 'app_update.dart';

class UpdateNotFoundException implements Exception {
  const UpdateNotFoundException();
}

class UpdateSkippedException implements Exception {
  final AppUpdate update;

  const UpdateSkippedException({
    required this.update,
  });
}

class UpdatePostponedException implements Exception {
  final AppUpdate update;

  const UpdatePostponedException({
    required this.update,
  });
}
