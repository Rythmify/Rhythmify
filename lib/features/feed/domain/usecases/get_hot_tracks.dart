import '../repositories/home_repository.dart';
import '../entities/hot_for_you.dart';

class GetHotForYou {
  final HomeRepository repository;
  GetHotForYou(this.repository);

  Future<HotForYou> call() => repository.getHotForYou();
}
