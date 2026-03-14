import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../feed/data/datasources/home_datasource.dart';
import '../../data/repositories/home_repository_impl.dart';

import '../../domain/usecases/get_trending_tracks.dart';
import '../../domain/usecases/get_hot_tracks.dart';

import '../../../../core/domain/entities/track_summary.dart';

final datasourceProvider = Provider((ref) => HomeDatasource());

final repositoryProvider = Provider(
  (ref) => HomeRepositoryImpl(ref.read(datasourceProvider)),
);

final getTrendingTracksProvider = Provider(
  (ref) => GetTrendingTracks(ref.read(repositoryProvider)),
);

final getHotTracksProvider = Provider(
  (ref) => GetHotTracks(ref.read(repositoryProvider)),
);

final trendingTracksProvider =
    FutureProvider.family<List<TrackSummary>, String>((ref, genre) {
      return ref.read(getTrendingTracksProvider).call(genre);
    });

final hotTracksProvider = FutureProvider<List<TrackSummary>>((ref) {
  return ref.read(getHotTracksProvider).call();
});
