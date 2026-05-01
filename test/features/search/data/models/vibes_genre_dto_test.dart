import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/search/data/models/vibes_genre_dto.dart'
    as vibes_genre_dto;

void main() {
  group('vibes_genre_dto.GenreDto', () {
    test('parses full genre page response', () {
      final content = vibes_genre_dto.GenreDto.fromJson({
        'data': {
          'genre': {
            'id': 'rock',
            'name': 'Rock',
            'cover_image': null,
            'track_count': null,
            'artist_count': null,
            'playlist_count': null,
            'album_count': null,
          },
          'introducing': {
            'playlist': {
              'playlist_id': 'intro-1',
              'owner_user_id': 'owner-1',
              'name': 'Intro Playlist',
              'description': null,
              'is_public': null,
              'created_at': '2026-01-01T00:00:00Z',
              'track_count': null,
              'like_count': null,
              'cover_image': null,
              'preview_track': _trackJson(),
            },
            'tracks_preview': [_trackJson()],
          },
          'playlists': [_playlistJson()],
          'albums': [_albumJson()],
          'artists': [_artistJson()],
          'tracks': [_trackJson()],
        },
      });

      expect(content.genreInfo.id, 'rock');
      expect(content.genreInfo.coverImage, '');
      expect(content.introducing.playlist.description, '');
      expect(content.introducing.playlist.isPublic, true);
      expect(content.introducing.playlist.coverImage, '');
      expect(content.playlists.single.ownerName, '');
      expect(content.albums.single.ownerName, '');
      expect(content.artists.single.displayName, '');
      expect(content.tracks.single.artist, 'Artist One');
    });

    test('parses endpoint-specific list responses', () {
      expect(
        vibes_genre_dto.GenreDto.playlistsFromJson({
          'data': {
            'playlists': [_playlistJson()],
          },
        }).single.id,
        'playlist-1',
      );
      expect(
        vibes_genre_dto.GenreDto.albumsFromJson({
          'data': {
            'albums': [_albumJson()],
          },
        }).single.id,
        'album-1',
      );
      expect(
        vibes_genre_dto.GenreDto.artistsFromJson({
          'data': {
            'artists': [_artistJson()],
          },
        }).single.id,
        'artist-1',
      );
      expect(
        vibes_genre_dto.GenreDto.tracksFromJson({
          'data': {
            'tracks': [_trackJson()],
          },
        }).single.id,
        'track-1',
      );
    });
  });
}

Map<String, dynamic> _trackJson() => {
  'id': 'track-1',
  'user_id': 'user-1',
  'title': 'Track One',
  'artist_name': 'Artist One',
  'audio_url': 'audio.mp3',
  'duration': 180,
  'created_at': '2026-01-01T00:00:00Z',
};

Map<String, dynamic> _playlistJson() => {
  'id': 'playlist-1',
  'name': 'Playlist One',
  'cover_image': null,
  'owner_id': 'owner-1',
  'owner_name': null,
  'track_count': null,
  'like_count': null,
  'source': null,
  'created_at': '2026-01-01T00:00:00Z',
};

Map<String, dynamic> _albumJson() => {
  'id': 'album-1',
  'name': 'Album One',
  'cover_image': null,
  'owner_id': 'owner-1',
  'owner_name': null,
  'track_count': null,
  'like_count': null,
  'release_date': null,
};

Map<String, dynamic> _artistJson() => {
  'id': 'artist-1',
  'display_name': null,
  'username': null,
  'profile_picture': null,
  'is_verified': null,
  'follower_count': null,
  'track_count_in_genre': null,
};
