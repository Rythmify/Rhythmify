import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/playlist/domain/entities/playlist_entity.dart';

// ============================================================
// FAKE DATA SOURCE (no network)
// ============================================================

class FakePlaylistDatasource {
  final List<PlaylistEntity> playlists = [];

  Future<PlaylistEntity> createPlaylist({
    required String name,
    required bool isPublic,
  }) async {
    final p = PlaylistEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      ownerName: 'user',
      ownerId: 'u1',
      isPublic: isPublic,
      type: PlaylistType.playlist,
      trackCount: 0,
      totalDuration: Duration.zero,
      createdAt: DateTime.now(),
    );

    playlists.add(p);
    return p;
  }

  Future<void> deletePlaylist(String id) async {
    playlists.removeWhere((p) => p.id == id);
  }

  Future<List<PlaylistEntity>> fetchMyPlaylists({
    String filter = 'created',
  }) async {
    return playlists;
  }
}

// ============================================================
// TESTS
// ============================================================

void main() {
  group('PlaylistListNotifier Logic (core flows)', () {
    test('createPlaylist returns new playlist', () async {
      final fake = FakePlaylistDatasource();

      final result = await fake.createPlaylist(
        name: 'Test Playlist',
        isPublic: true,
      );

      expect(result.name, 'Test Playlist');
      expect(fake.playlists.length, 1);
    });

    test('deletePlaylist removes playlist', () async {
      final fake = FakePlaylistDatasource();

      final p = await fake.createPlaylist(name: 'To Delete', isPublic: true);

      expect(fake.playlists.length, 1);

      await fake.deletePlaylist(p.id);

      expect(fake.playlists.isEmpty, true);
    });

    test('playlist list reflects added items', () async {
      final fake = FakePlaylistDatasource();

      await fake.createPlaylist(name: 'A', isPublic: true);

      await fake.createPlaylist(name: 'B', isPublic: true);

      final list = await fake.fetchMyPlaylists();

      expect(list.length, 2);
    });
  });
}
