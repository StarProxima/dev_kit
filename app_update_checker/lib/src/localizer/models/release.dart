import '../../linker/models/release_data.dart';
import '../../sources/source.dart';
import 'update_text.dart';

class Release extends ReleaseData {
  final UpdateText localizedText;
  final Source targetSource;

  const Release({
    required super.version,
    required this.localizedText,
    required this.targetSource,
    required super.releaseNoteTranslations,
    required super.dateUtc,
    required super.settings,
    required super.sources,
    required super.customData,
  });
}
