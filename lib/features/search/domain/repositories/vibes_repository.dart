import '../entities/vibes_category.dart';

/// Domain contract for the vibes grid feature.
/// Defines the operations the presentation layer can request — implementation lives in the data layer.
abstract class VibesRepository {
  /// Returns the list of all vibe categories shown in the vibes grid.
  Future<List<VibeCategory>> getVibes();
}
