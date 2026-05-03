import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/playlist/data/mock/playlist_mock_data.dart';
import 'package:rythmify/features/playlist/domain/entities/playlist_entity.dart';
import 'package:rythmify/features/playlist/domain/entities/playlist_track.dart';

void main() {
  final cache = PlaylistMockData.instance;

  final playlist = PlaylistEntity(
    id: 'playlist-1',
    name: 'Playlist',
    ownerName: 'Owner',
    ownerId: 'owner-1',
    isPublic: true,
    type: PlaylistType.playlist,
    trackCount: 0,
    totalDuration: Duration.zero,
    createdAt: DateTime(2024, 1, 1),
  );
  final album = playlist.copyWith(id: 'album-1', type: PlaylistType.album);
  final station = playlist.copyWith(
    id: 'station-1',
    type: PlaylistType.station,
  );
  final track = PlaylistTrack(
    id: 'track-1',
    title: 'One',
    artistName: 'Artist',
    duration: const Duration(seconds: 30),
    playCount: 1,
    position: 99,
  );

  setUp(() {
    cache.syncFromBackend([]);
  });

  test('syncFromBackend replaces playlists and prunes orphaned tracks', () {
    cache.syncFromBackend([playlist]);
    cache.addTrack(playlistId: 'playlist-1', track: track);

    cache.syncFromBackend([album, station]);

    expect(cache.getById('playlist-1'), isNull);
    expect(cache.getTracksFor('playlist-1'), isEmpty);
    expect(cache.getAlbums().single.id, 'album-1');
    expect(cache.getStations().single.id, 'station-1');
  });

  test('createWithId is idempotent and stores initial empty tracks', () {
    final first = cache.createWithId(
      id: 'playlist-1',
      name: 'First',
      isPublic: true,
      ownerName: 'Owner',
      ownerId: 'owner-1',
    );
    final second = cache.createWithId(
      id: 'playlist-1',
      name: 'Second',
      isPublic: false,
    );

    expect(identical(first, second), isTrue);
    expect(cache.getMyPlaylists(), hasLength(1));
    expect(cache.getTracksFor('playlist-1'), isEmpty);
  });

  test('update and cover changes are no-ops for missing playlists', () {
    cache.syncFromBackend([playlist]);

    cache.update(
      playlistId: 'playlist-1',
      name: 'Updated',
      isPublic: false,
      description: 'desc',
    );
    cache.updateCoverImage(playlistId: 'playlist-1', localPath: 'cover.jpg');
    cache.update(playlistId: 'missing', name: 'Missing', isPublic: true);
    cache.updateCoverImage(playlistId: 'missing', localPath: 'missing.jpg');

    final updated = cache.getById('playlist-1')!;
    expect(updated.name, 'Updated');
    expect(updated.isPublic, isFalse);
    expect(updated.description, 'desc');
    expect(updated.coverUrl, 'cover.jpg');
  });

  test(
    'track add prevents duplicates, repositions after removal, and updates totals',
    () {
      cache.syncFromBackend([playlist]);

      cache.addTrack(playlistId: 'playlist-1', track: track);
      cache.addTrack(
        playlistId: 'playlist-1',
        track: track.copyWith(position: 1),
      );
      cache.addTrack(
        playlistId: 'playlist-1',
        track: const PlaylistTrack(
          id: 'track-2',
          title: 'Two',
          artistName: 'Artist',
          duration: Duration(seconds: 45),
          playCount: 1,
          position: 4,
        ),
      );

      expect(cache.getTracksFor('playlist-1').map((t) => t.position), [1, 2]);
      expect(cache.getById('playlist-1')!.trackCount, 2);
      expect(
        cache.getById('playlist-1')!.totalDuration,
        const Duration(seconds: 75),
      );

      cache.removeTrack(playlistId: 'playlist-1', trackId: 'track-1');
      expect(cache.getTracksFor('playlist-1').single.position, 1);
      expect(cache.getById('playlist-1')!.trackCount, 1);

      cache.removeTrack(playlistId: 'missing', trackId: 'track-2');
      cache.addTrack(playlistId: 'missing', track: track);
      expect(cache.getTracksFor('missing'), hasLength(1));
    },
  );

  test('delete removes playlists and tracks', () {
    cache.syncFromBackend([playlist]);
    cache.addTrack(playlistId: 'playlist-1', track: track);

    cache.delete('playlist-1');

    expect(cache.getById('playlist-1'), isNull);
    expect(cache.getTracksFor('playlist-1'), isEmpty);
  });

  test(
    'conversions update type and handle missing ids using existing first playlist',
    () {
      cache.syncFromBackend([playlist]);

      expect(cache.convertToAlbum('playlist-1').type, PlaylistType.album);
      expect(cache.convertToPlaylist('playlist-1').type, PlaylistType.playlist);
      expect(
        cache
            .convertToStation('playlist-1', seedArtistName: 'Seed')
            .seedArtistName,
        'Seed',
      );
      expect(cache.convertToAlbum('missing').id, 'playlist-1');
      expect(cache.convertToPlaylist('missing').id, 'playlist-1');
      expect(cache.convertToStation('missing').id, 'playlist-1');
    },
  );

  test('createStation creates a local station seeded by the track artist', () {
    final station = cache.createStation(seedTrack: track);

    expect(station.type, PlaylistType.station);
    expect(station.name, 'Artist Radio');
    expect(station.seedArtistName, 'Artist');
    expect(station.coverUrl, isNull);
    expect(cache.getStations().single.id, station.id);
  });
}
