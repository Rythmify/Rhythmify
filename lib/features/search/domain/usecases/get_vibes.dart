import '../entities/vibes_category.dart';
import '../repositories/vibes_repository.dart';

class GetVibes {
  final VibesRepository repository;
  GetVibes(this.repository);

  Future<List<VibeCategory>> call() => repository.getVibes();
}
