import '../repositories/home_repository.dart';
import '../entities/home_data.dart';

/// Use case for getting full home data
class GetHomeData {
  final HomeRepository repository;
  GetHomeData(this.repository);

  /// Executes the use case, returning a list of home data
  Future<HomeData> call() => repository.getHomeData();
}
