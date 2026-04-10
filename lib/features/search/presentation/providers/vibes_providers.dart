import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/vibes_remote_datasource.dart';
import '../../data/repositories/vibes_repository_impl.dart';
import '../../domain/usecases/get_vibes.dart';
import '../../domain/entities/vibes_category.dart';

// ── Dependency graph ──────────────────────────────────────────────────────────

/// Provides the mock data source. Swap to a real HTTP source at integration time.
final vibesRemoteSourceProvider = Provider<VibesRemoteSource>(
  (_) => VibesRemoteSourceMock(),
);

/// Provides the repository, injecting the remote source.
final vibesRepositoryProvider = Provider(
  (ref) =>
      VibesRepositoryImpl(remoteSource: ref.watch(vibesRemoteSourceProvider)),
);

/// Provides the [GetVibes] use case.
final getVibesProvider = Provider(
  (ref) => GetVibes(ref.watch(vibesRepositoryProvider)),
);

// ── Data provider ─────────────────────────────────────────────────────────────

/// Fetches the list of vibe categories for the vibes grid.
/// autoDispose ensures the data is released when the search screen is left.
final vibesProvider = FutureProvider.autoDispose<List<VibeCategory>>((ref) {
  return ref.read(getVibesProvider).call();
});
