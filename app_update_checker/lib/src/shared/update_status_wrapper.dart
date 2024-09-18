import 'update_status.dart';

class UpdateStatusWrapper<T> {
  final T required;
  final T recommended;
  final T available;

  const UpdateStatusWrapper({
    required this.required,
    required this.recommended,
    required this.available,
  });

  T byStatus(UpdateStatus status) => switch (status) {
        UpdateStatus.required => required,
        UpdateStatus.recommended => recommended,
        UpdateStatus.available => available,
      };
}
