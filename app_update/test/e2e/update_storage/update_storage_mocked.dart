// ignore_for_file: avoid-top-level-members-in-tests

import 'package:app_update/src/storage/update_storage.dart';

class UpdateStorageMocked extends UpdateStorage {
  DateTime _nowDateTime;

  @override
  DateTime get nowDateTime => _nowDateTime;

  set nowDateTime(DateTime value) => _nowDateTime = value;

  UpdateStorageMocked(this._nowDateTime, super._prefs);
}
