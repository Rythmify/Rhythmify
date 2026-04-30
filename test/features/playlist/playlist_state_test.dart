import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/playlist/presentation/providers/playlist_provider.dart';
import 'package:rythmify/features/playlist/domain/entities/playlist_track.dart';

void main() {
  group('PlaylistListState', () {
    test('copyWith updates playlists correctly', () {
      final state = PlaylistListState(playlists: [], isLoading: false);

      final updated = state.copyWith(playlists: [], isLoading: true);

      expect(updated.isLoading, true);
      expect(updated.playlists.length, 0);
    });
  });

  group('PlaylistDetailState', () {
    test('totalDuration sums track durations correctly', () {
      final state = PlaylistDetailState(
        tracks: [
          PlaylistTrack(
            id: '1',
            title: 't1',
            artistName: 'a',
            duration: const Duration(seconds: 30),
            position: 1,
            playCount: 100,
          ),
          PlaylistTrack(
            id: '2',
            title: 't2',
            artistName: 'a',
            duration: const Duration(seconds: 90),
            position: 2,
            playCount: 40,
          ),
        ],
      );

      expect(state.totalDuration, const Duration(seconds: 120));
    });

    test('copyWith updates liked state', () {
      final state = const PlaylistDetailState(isLiked: false);

      final updated = state.copyWith(isLiked: true);

      expect(updated.isLiked, true);
    });
  });
}
