import '../repositories/home_repository.dart';
import '../entities/hot_for_you.dart';

/// Use case for getting hot track
class GetHotForYou {
  final HomeRepository repository;
  GetHotForYou(this.repository);

  /// Executes the use case, returning a hot track
  Future<HotForYou> call() => repository.getHotForYou();
}
