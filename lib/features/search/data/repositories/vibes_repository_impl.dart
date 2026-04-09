import '../../domain/entities/vibes_category.dart';
import '../../domain/repositories/vibes_repository.dart';
import '../datasources/vibes_remote_datasource.dart';

/// Concrete implementation of [VibesRepository].
/// Delegates directly to [VibesRemoteSource] — no local caching or transformation needed.
class VibesRepositoryImpl implements VibesRepository {
  final VibesRemoteSource remoteSource;

  VibesRepositoryImpl({required this.remoteSource});

  @override
  Future<List<VibeCategory>> getVibes() => remoteSource.getVibes();
}
