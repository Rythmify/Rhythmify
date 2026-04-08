import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/vibes_remote_datasource.dart';
import '../../data/repositories/vibes_repository_impl.dart';
import '../../domain/usecases/get_vibes.dart';
import '../../domain/entities/vibes_category.dart';

final vibesRemoteSourceProvider = Provider<VibesRemoteSource>(
  (_) => VibesRemoteSourceMock(),
);

final vibesRepositoryProvider = Provider(
  (ref) =>
      VibesRepositoryImpl(remoteSource: ref.watch(vibesRemoteSourceProvider)),
);

final getVibesProvider = Provider(
  (ref) => GetVibes(ref.watch(vibesRepositoryProvider)),
);

final vibesProvider = FutureProvider.autoDispose<List<VibeCategory>>((ref) {
  return ref.read(getVibesProvider).call();
});
