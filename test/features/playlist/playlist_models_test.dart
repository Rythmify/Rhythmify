import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/playlist/data/models/playlist_model.dart';
import 'package:rythmify/features/playlist/data/models/playlist_track_model.dart';
import 'package:rythmify/features/playlist/domain/entities/playlist_entity.dart';

Map<String, dynamic> _playlistJson({
  String id = 'playlist-1',
  String name = 'Night Drive',
  String ownerId = 'user-1',
  String subtype = 'playlist',
  String type = 'regular',
  bool? isPublic = true,
  String? releaseDate,
  int? trackCount = 3,
  String? coverImage = 'https://cdn/cover.jpg',
  bool? isLiked = false,
}) {
  return {
    'playlist_id': id,
    'name': name,
    'owner_user_id': ownerId,
    'subtype': subtype,
    'type': type,
    'is_public': isPublic,
    'track_count': trackCount,
    'created_at': '2024-01-02T03:04:05Z',
    'cover_image': coverImage,
    'description': 'Late-night playlist',
    'like_count': 7,
    'repost_count': 2,
    'is_liked_by_me': isLiked,
    'release_date': releaseDate,
  };
}

Map<String, dynamic> _trackJson({
  String id = 'track-1',
  String title = 'Intro',
  String artist = 'Artist',
  int duration = 125,
  int position = 1,
  bool isPublic = true,
  String? deletedAt,
}) {
  return {
    'track_id': id,
    'title': title,
    'artist_name': artist,
    'duration': duration,
    'position': position,
    'cover_image': 'https://cdn/$id.jpg',
    'is_public': isPublic,
    'deleted_at': deletedAt,
  };
}

void main() {
  group('PlaylistModel', () {
    test('maps a full playlist payload including ownership and engagement', () {
      final result = PlaylistModel.fromJson(
        _playlistJson(isPublic: false, isLiked: true),
        isOwned: true,
      );

      expect(result.id, 'playlist-1');
      expect(result.name, 'Night Drive');
      expect(result.ownerId, 'user-1');
      expect(result.isPublic, isFalse);
      expect(result.type, PlaylistType.playlist);
      expect(result.trackCount, 3);
      expect(result.coverUrl, 'https://cdn/cover.jpg');
      expect(result.description, 'Late-night playlist');
      expect(result.likeCount, 7);
      expect(result.repostCount, 2);
      expect(result.isLiked, isTrue);
      expect(result.isOwned, isTrue);
    });

    test(
      'defaults nullable backend fields without changing access semantics',
      () {
        final result = PlaylistModel.fromJson(
          _playlistJson(isPublic: null, trackCount: null, coverImage: null)
            ..remove('is_liked_by_me'),
        );

        expect(result.isPublic, isTrue);
        expect(result.trackCount, 0);
        expect(result.coverUrl, isNull);
        expect(result.isLiked, isFalse);
      },
    );

    test('maps album subtypes and release years', () {
      final result = PlaylistModel.fromJson(
        _playlistJson(subtype: 'album', releaseDate: '2026-04-12'),
      );

      expect(result.type, PlaylistType.album);
      expect(result.typeLabel, 'Album');
      expect(result.releaseYear, 2026);
    });

    test('detects generated mixes and track radios from backend markers', () {
      final mix = PlaylistModel.fromJson(
        _playlistJson(id: 'mix-1', subtype: 'curated_daily'),
      );
      final radio = PlaylistModel.fromJson(
        _playlistJson(id: 'radio-1', type: 'track_radio'),
      );

      expect(mix.isGeneratedMix, isTrue);
      expect(mix.typeLabel, 'Mix');
      expect(radio.isTrackRadio, isTrue);
      expect(radio.typeLabel, 'Radio');
    });

    test('fromJsonListOwned marks every created playlist as owned', () {
      final result = PlaylistModel.fromJsonListOwned([
        _playlistJson(id: 'p1'),
        _playlistJson(id: 'p2', isPublic: false),
      ]);

      expect(result.map((p) => p.id), ['p1', 'p2']);
      expect(result.every((p) => p.isOwned), isTrue);
    });

    test(
      'toCreateJson sends the API contract for public and private lists',
      () {
        expect(PlaylistModel.toCreateJson(name: 'Secret', isPublic: false), {
          'name': 'Secret',
          'is_public': false,
          'subtype': 'playlist',
        });
        expect(
          PlaylistModel.toCreateJson(
            name: 'Album',
            isPublic: true,
            subtype: 'album',
          ),
          {'name': 'Album', 'is_public': true, 'subtype': 'album'},
        );
      },
    );
  });

  group('PlaylistTrackModel', () {
    test('maps track fields and formats duration through entity behavior', () {
      final result = PlaylistTrackModel.fromJson(_trackJson());

      expect(result.id, 'track-1');
      expect(result.title, 'Intro');
      expect(result.artistName, 'Artist');
      expect(result.duration, const Duration(seconds: 125));
      expect(result.formattedDuration, '2:05');
      expect(result.position, 1);
      expect(result.coverUrl, 'https://cdn/track-1.jpg');
      expect(result.isUnavailable, isFalse);
    });

    test('marks private and deleted tracks unavailable', () {
      final private = PlaylistTrackModel.fromJson(
        _trackJson(id: 'private', isPublic: false),
      );
      final deleted = PlaylistTrackModel.fromJson(
        _trackJson(id: 'deleted', deletedAt: '2024-02-01T00:00:00Z'),
      );

      expect(private.isUnavailable, isTrue);
      expect(deleted.isUnavailable, isTrue);
    });

    test('sorts tracks by playlist position and allows empty playlists', () {
      final result = PlaylistTrackModel.fromJsonList([
        _trackJson(id: 'last', position: 3),
        _trackJson(id: 'first', position: 1),
        _trackJson(id: 'middle', position: 2),
      ]);

      expect(result.map((t) => t.id), ['first', 'middle', 'last']);
      expect(PlaylistTrackModel.fromJsonList([]), isEmpty);
    });
  });
}
