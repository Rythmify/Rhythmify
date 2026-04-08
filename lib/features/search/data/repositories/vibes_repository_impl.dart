import '../../domain/entities/vibes_category.dart';
import '../../domain/repositories/vibes_repository.dart';
import '../datasources/vibes_remote_datasource.dart';

class VibesRepositoryImpl implements VibesRepository {
  final VibesRemoteSource remoteSource;
  VibesRepositoryImpl({required this.remoteSource});

  @override
  Future<List<VibeCategory>> getVibes() => remoteSource.getVibes();
}
