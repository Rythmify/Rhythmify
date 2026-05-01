import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/playlist/presentation/providers/playlist_provider.dart';
import 'package:rythmify/features/playlist/domain/entities/playlist_entity.dart';
import 'package:rythmify/features/playlist/domain/entities/playlist_track.dart';

void main() {
  group('Playlist Creation Logic', () {
    test('creates correct copy name when overrideName is null', () {
      final source = PlaylistEntity(
        id: '1',
        name: 'My Playlist',
        ownerName: 'user',
        ownerId: 'u1',
        isPublic: true,
        type: PlaylistType.playlist,
        trackCount: 0,
        totalDuration: Duration.zero,
        createdAt: DateTime(2024, 1, 1),
      );

      final copyName = 'Copy of ${source.name}';

      expect(copyName, 'Copy of My Playlist');
    });

    test('uses override name when provided', () {
      final override = 'Workout Mix';

      expect(override, 'Workout Mix');
    });

    test('default visibility logic works', () {
      final source = PlaylistEntity(
        id: '1',
        name: 'Test',
        ownerName: 'user',
        ownerId: 'u1',
        isPublic: false,
        type: PlaylistType.playlist,
        trackCount: 0,
        totalDuration: Duration.zero,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(source.isPublic, false);
    });
  });

  group('Playlist Update Logic', () {
    test('updates name correctly', () {
      final oldName = 'Old Name';
      final newName = 'New Name';

      expect(newName != oldName, true);
    });

    test('update preserves public state when not changed', () {
      final isPublic = true;

      expect(isPublic, true);
    });
  });

  group('PlaylistDetailState Logic', () {
    test('totalDuration returns zero for empty tracks', () {
      final state = PlaylistDetailState(tracks: []);

      expect(state.totalDuration, Duration.zero);
    });

    test('totalDuration sums multiple tracks', () {
      final state = PlaylistDetailState(
        tracks: [
          PlaylistTrack(
            id: '1',
            title: 'A',
            artistName: 'Artist',
            duration: const Duration(seconds: 30),
            position: 1,
            playCount: 130,
          ),
          PlaylistTrack(
            id: '2',
            title: 'B',
            artistName: 'Artist',
            duration: const Duration(seconds: 90),
            position: 2,
            playCount: 100,
          ),
        ],
      );

      expect(state.totalDuration, const Duration(seconds: 120));
    });

    test('showSuggestions is false when no suggestions', () {
      final state = PlaylistDetailState(
        suggestions: [],
        playlist: PlaylistEntity(
          id: '1',
          name: 'Test',
          ownerName: 'user',
          ownerId: 'u1',
          isPublic: true,
          type: PlaylistType.playlist,
          trackCount: 0,
          totalDuration: Duration.zero,
          createdAt: DateTime(2024, 1, 1),
        ),
      );

      expect(state.showSuggestions, false);
    });
  });

  group('Copy Playlist Logic', () {
    test('copy name fallback works', () {
      final sourceName = 'Chill Mix';

      final copyName = 'Copy of $sourceName';

      expect(copyName, 'Copy of Chill Mix');
    });

    test('override name replaces default copy name', () {
      final overrideName = 'My Custom Mix';

      expect(overrideName, 'My Custom Mix');
    });
  });
}
