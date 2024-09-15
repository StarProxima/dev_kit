import 'update_status.dart';

class UpdateStatusWrapper<T> {
  final T required;
  final T recommended;
  final T available;

  bool get isOnlyAvailable => available != null && required == null && recommended == null;

  const UpdateStatusWrapper({
    required this.required,
    required this.recommended,
    required this.available,
  });

  const UpdateStatusWrapper.all(
    T all,
  )   : required = all,
        recommended = all,
        available = all;

  T byStatus(UpdateStatus status) => switch (status) {
        UpdateStatus.required => required,
        UpdateStatus.recommended => recommended,
        UpdateStatus.available => available,
      };
}
