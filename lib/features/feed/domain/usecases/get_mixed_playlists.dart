import '../repositories/home_repository.dart';
import '../entities/mixed_for_you_item.dart';

class GetMixedForYou {
  final HomeRepository repository;
  GetMixedForYou(this.repository);

  Future<List<MixedForYouItem>> call() => repository.getMixedForYou();
}
