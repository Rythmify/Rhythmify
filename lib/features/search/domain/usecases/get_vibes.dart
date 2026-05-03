import '../entities/vibes_category.dart';
import '../repositories/vibes_repository.dart';

/// Use case that fetches vibes for vibes grid
class GetVibes {
  final VibesRepository repository;
  GetVibes(this.repository);

  Future<List<VibeCategory>> call() => repository.getVibes();
}
