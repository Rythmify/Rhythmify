import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/core/domain/entities/track.dart';
import 'package:rythmify/features/playlist/domain/entities/playlist_entity.dart';
import 'package:rythmify/features/playlist/domain/entities/playlist_track.dart';

void main() {
  group('Playlist domain entities', () {
    test('PlaylistTrack.fromTrack keeps player-facing track identity', () {
      final track = Track(
        id: 'track-001',
        userId: 'user-001',
        title: 'Neon Lights',
        artist: 'DJ Sample',
        audioUrl: 'https://example.com/audio.mp3',
        streamUrl: 'https://example.com/stream',
        duration: const Duration(minutes: 3, seconds: 31),
        createdAt: DateTime(2024, 1, 1),
        playCount: 99000,
        isLiked: true,
        coverImage: 'https://example.com/cover.jpg',
      );

      final playlistTrack = PlaylistTrack.fromTrack(track, position: 4);

      expect(playlistTrack.id, 'track-001');
      expect(playlistTrack.trackId, 'track-001');
      expect(playlistTrack.title, 'Neon Lights');
      expect(playlistTrack.artistName, 'DJ Sample');
      expect(playlistTrack.position, 4);
      expect(playlistTrack.formattedDuration, '3:31');
      expect(playlistTrack.formattedPlayCount, '99.0K');
      expect(playlistTrack.isLiked, isTrue);
      expect(playlistTrack.isUnavailable, isFalse);
      expect(playlistTrack.toTrack().audioUrl, 'https://example.com/stream');
    });

    test(
      'PlaylistEntity labels public/private playlist variants correctly',
      () {
        final playlist = PlaylistEntity(
          id: 'playlist-1',
          name: 'My Playlist',
          ownerName: 'Hana',
          ownerId: 'user-me',
          isPublic: false,
          type: PlaylistType.playlist,
          trackCount: 3,
          totalDuration: const Duration(minutes: 9, seconds: 25),
          createdAt: DateTime(2024, 1, 1),
        );

        expect(playlist.typeLabel, 'Playlist');
        expect(playlist.subtitleLine, contains('3 tracks'));
        expect(playlist.detailSubtitle, '3 tracks');
        expect(playlist.isPublic, isFalse);

        expect(playlist.copyWith(type: PlaylistType.album).typeLabel, 'Album');
        expect(
          playlist.copyWith(type: PlaylistType.station).typeLabel,
          'Station',
        );
        expect(
          playlist.copyWith(type: PlaylistType.album).detailSubtitle,
          contains('3 tracks'),
        );
        expect(
          playlist.copyWith(type: PlaylistType.station).detailSubtitle,
          contains('3 tracks'),
        );
        expect(
          playlist.copyWith(type: PlaylistType.album).subtitleLine,
          contains('3 tracks'),
        );
        expect(
          playlist.copyWith(type: PlaylistType.station).subtitleLine,
          contains('3 tracks'),
        );
        expect(playlist.copyWith(isGeneratedMix: true).typeLabel, 'Mix');
        expect(
          playlist.copyWith(isTrackRadio: true).subtitleLine,
          contains('3 tracks'),
        );
      },
    );

    test('copyWith can clear cover while preserving unrelated metadata', () {
      final playlist = PlaylistEntity(
        id: 'playlist-1',
        name: 'My Playlist',
        ownerName: 'Hana',
        ownerId: 'user-me',
        isPublic: true,
        type: PlaylistType.playlist,
        trackCount: 0,
        totalDuration: Duration.zero,
        createdAt: DateTime(2024, 1, 1),
        coverUrl: 'https://example.com/cover.jpg',
      );

      final updated = playlist.copyWith(
        name: 'Updated',
        clearCover: true,
        isPublic: false,
      );

      expect(updated.name, 'Updated');
      expect(updated.coverUrl, isNull);
      expect(updated.ownerId, 'user-me');
      expect(updated.isPublic, isFalse);
    });

    test(
      'PlaylistTrack formats play counts and preserves copyWith defaults',
      () {
        const small = PlaylistTrack(
          id: 'small',
          title: 'Small',
          artistName: 'Artist',
          duration: Duration(seconds: 61),
          playCount: 999,
          position: 3,
          streamUrl: 'stream',
          audioUrl: 'audio',
        );
        const thousands = PlaylistTrack(
          id: 'thousands',
          title: 'Thousands',
          artistName: 'Artist',
          duration: Duration.zero,
          playCount: 1200,
          position: 1,
        );
        const millions = PlaylistTrack(
          id: 'millions',
          title: 'Millions',
          artistName: 'Artist',
          duration: Duration(seconds: 30),
          playCount: 1500000,
          position: 1,
        );

        expect(small.formattedDuration, '1:01');
        expect(small.formattedPlayCount, '999');
        expect(thousands.formattedPlayCount, '1.2K');
        expect(millions.formattedPlayCount, '1.5M');
        expect(small.copyWith().position, 3);
        expect(small.copyWith(position: 4).position, 4);
        expect(small.copyWith(isLiked: true).isLiked, isTrue);
        expect(small.copyWith(streamUrl: 'new').streamUrl, 'new');
        expect(small.copyWith(audioUrl: 'new-audio').audioUrl, 'new-audio');
      },
    );
  });
}

// import 'package:flutter_test/flutter_test.dart';
// import 'package:rythmify/features/playlist/domain/entities/playlist_entity.dart';
// import 'package:rythmify/features/playlist/domain/entities/playlist_track.dart';
// import 'package:rythmify/core/domain/entities/track.dart';

// void main() {
//   // ── PlaylistTrack ──────────────────────────────────────────────────────────

//   group('PlaylistTrack', () {
//     final track = Track(
//       id: 'track-001',
//       userId: 'user-001',
//       title: 'Neon Lights',
//       artist: 'DJ Sample',
//       audioUrl: 'https://example.com/audio.mp3',
//       duration: const Duration(minutes: 3, seconds: 31),
//       createdAt: DateTime(2024, 1, 1),
//       playCount: 99000,
//       isLiked: false,
//     );

//     test('fromTrack maps fields correctly', () {
//       final pt = PlaylistTrack.fromTrack(track, position: 1);

//       expect(pt.id, 'track-001');
//       expect(pt.trackId, 'track-001');
//       expect(pt.title, 'Neon Lights');
//       expect(pt.artistName, 'DJ Sample');
//       expect(pt.position, 1);
//       expect(pt.isLiked, false);
//       expect(pt.isUnavailable, false);
//     });

//     test('formattedDuration returns m:ss', () {
//       final pt = PlaylistTrack.fromTrack(track);
//       expect(pt.formattedDuration, '3:31');
//     });

//     test('formattedPlayCount returns compact string', () {
//       final pt = PlaylistTrack.fromTrack(track);
//       expect(pt.formattedPlayCount, '99.0K');
//     });

//     test('copyWith preserves trackId', () {
//       final pt = PlaylistTrack.fromTrack(track, position: 1);
//       final copy = pt.copyWith(position: 2);

//       expect(copy.trackId, pt.trackId);
//       expect(copy.position, 2);
//       expect(copy.title, pt.title);
//     });

//     test('suggestion track has position 0', () {
//       final pt = PlaylistTrack.fromTrack(track);
//       expect(pt.position, 0);
//     });
//   });

//   // ── PlaylistEntity ─────────────────────────────────────────────────────────

//   group('PlaylistEntity', () {
//     final playlist = PlaylistEntity(
//       id: 'pl-001',
//       name: 'My Playlist',
//       ownerName: 'Hana',
//       ownerId: 'user-me',
//       isPublic: true,
//       type: PlaylistType.playlist,
//       trackCount: 3,
//       totalDuration: const Duration(minutes: 9, seconds: 25),
//       createdAt: DateTime(2024, 1, 1),
//     );

//     test('typeLabel returns correct string', () {
//       expect(playlist.typeLabel, 'Playlist');

//       final album = playlist.copyWith(type: PlaylistType.album);
//       expect(album.typeLabel, 'Album');

//       final station = playlist.copyWith(type: PlaylistType.station);
//       expect(station.typeLabel, 'Station');
//     });

//     test('subtitleLine formats correctly', () {
//       expect(playlist.subtitleLine, 'Playlist · 3 tracks · 09:25');
//     });

//     test('detailSubtitle for album uses releaseYear', () {
//       final album = playlist.copyWith(
//         type: PlaylistType.album,
//         releaseYear: '2026',
//       );
//       expect(album.detailSubtitle, '2026 · Album');
//     });

//     test('detailSubtitle for album falls back to createdAt year', () {
//       final album = playlist.copyWith(type: PlaylistType.album);
//       expect(album.detailSubtitle, '2024 · Album');
//     });

//     test('copyWith clearCover nulls out coverUrl', () {
//       final withCover = playlist.copyWith(
//         coverUrl: 'https://example.com/cover.jpg',
//       );
//       final cleared = withCover.copyWith(clearCover: true);
//       expect(cleared.coverUrl, isNull);
//     });

//     test('copyWith without clearCover preserves coverUrl', () {
//       final withCover = playlist.copyWith(
//         coverUrl: 'https://example.com/cover.jpg',
//       );
//       final updated = withCover.copyWith(name: 'New Name');
//       expect(updated.coverUrl, 'https://example.com/cover.jpg');
//     });
//   });

//   // ── PlaylistMockData ───────────────────────────────────────────────────────

//   group('PlaylistMockData', () {
//     final sampleTrack = Track(
//       id: 'track-001',
//       userId: 'user-001',
//       title: 'Neon Lights',
//       artist: 'DJ Sample',
//       audioUrl: 'https://example.com/audio.mp3',
//       duration: const Duration(minutes: 3, seconds: 31),
//       createdAt: DateTime(2024, 1, 1),
//     );

//     test('formattedPlayCount for millions', () {
//       final track = Track(
//         id: 't',
//         userId: 'u',
//         title: 'T',
//         artist: 'A',
//         audioUrl: '',
//         duration: Duration.zero,
//         createdAt: DateTime(2024),
//         playCount: 1900000,
//       );
//       final pt = PlaylistTrack.fromTrack(track);
//       expect(pt.formattedPlayCount, '1.9M');
//     });

//     test('formattedPlayCount for small numbers', () {
//       final track = Track(
//         id: 't',
//         userId: 'u',
//         title: 'T',
//         artist: 'A',
//         audioUrl: '',
//         duration: Duration.zero,
//         createdAt: DateTime(2024),
//         playCount: 41,
//       );
//       final pt = PlaylistTrack.fromTrack(track);
//       expect(pt.formattedPlayCount, '41');
//     });

//     test('unavailable track isUnavailable is false from fromTrack', () {
//       final pt = PlaylistTrack.fromTrack(sampleTrack);
//       expect(pt.isUnavailable, false);
//     });
//   });
// }
