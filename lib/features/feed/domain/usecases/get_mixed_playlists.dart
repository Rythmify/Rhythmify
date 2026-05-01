import '../repositories/home_repository.dart';
import '../entities/mixed_for_you_item.dart';

/// Use case for getting mixed playlists
class GetMixedForYou {
  final HomeRepository repository;
  GetMixedForYou(this.repository);

  /// Executes the use case, returning a list of mixed playlists
  Future<List<MixedForYouItem>> call() => repository.getMixedForYou();
}
