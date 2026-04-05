import '../repositories/home_repository.dart';
import '../entities/home_data.dart';

class GetHomeData {
  final HomeRepository repository;
  GetHomeData(this.repository);

  Future<HomeData> call() => repository.getHomeData();
}
