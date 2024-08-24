import 'store_dto.dart';

class ReleaseDTO {
  const ReleaseDTO({
    required this.version,
    required this.isActive,
    required this.isRequired,
    required this.isBroken,
    required this.title,
    required this.description,
    required this.releaseNote,
    required this.stores,
  });

  final String? version;
  final bool? isActive;
  final bool? isRequired;
  final bool? isBroken;
  final Map<String, String>? title;
  final Map<String, String>? description;
  final Map<String, String>? releaseNote;
  final List<StoreDTO>? stores;
}
