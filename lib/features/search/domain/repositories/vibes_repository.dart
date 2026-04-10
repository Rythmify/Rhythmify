import '../entities/vibes_category.dart';

abstract class VibesRepository {
  Future<List<VibeCategory>> getVibes();
}
