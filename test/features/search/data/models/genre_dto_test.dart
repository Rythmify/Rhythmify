import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/search/data/models/genre_dto.dart';

void main() {
  group('GenreDto', () {
    test('parses track with alternate artist and genre fields', () {
      final track = GenreDto.parseTrack({
        'id': 'track-1',
        'user_id': 'user-1',
        'title': 'Track One',
        'artist_name': 'Artist One',
        'genre_name': 'Rock',
        'stream_url': 'https://example.com/audio.mp3',
        'duration': 180,
        'created_at': '2026-01-01T00:00:00Z',
      });

      expect(track.id, 'track-1');
      expect(track.artist, 'Artist One');
      expect(track.genre, 'Rock');
      expect(track.duration.inSeconds, 180);
    });

    test('parses genre info with defaults', () {
      final info = GenreDto.parseGenreInfo({});

      expect(info.id, '');
      expect(info.name, 'Unknown');
      expect(info.coverImage, '');
      expect(info.trackCount, 0);
      expect(info.artistCount, 0);
      expect(info.playlistCount, 0);
      expect(info.albumCount, 0);
    });

    test('parses introducing section with preview track', () {
      final section = GenreDto.parseIntroducingSection({
        'id': 'intro-1',
        'owner_id': 'owner-1',
        'name': 'Intro Playlist',
        'created_at': '2026-01-02T00:00:00Z',
        'track_count': 3,
        'like_count': 5,
        'cover_image': 'cover.jpg',
        'tracks_preview': [
          {
            'id': 'track-1',
            'user_id': 'user-1',
            'title': 'Preview Track',
            'artist': 'Preview Artist',
            'audio_url': 'audio.mp3',
            'duration': 90,
            'created_at': '2026-01-01T00:00:00Z',
          },
        ],
      });

      expect(section.playlist.playlistId, 'intro-1');
      expect(section.playlist.ownerUserId, 'owner-1');
      expect(section.playlist.previewTrack.title, 'Preview Track');
      expect(section.tracksPreview.single.artist, 'Preview Artist');
    });

    test('parses introducing section with empty preview track fallback', () {
      final section = GenreDto.parseIntroducingSection({
        'id': 'intro-1',
        'owner_id': 'owner-1',
        'name': 'Intro Playlist',
        'created_at': '2026-01-02T00:00:00Z',
        'tracks_preview': [],
      });

      expect(section.playlist.trackCount, 0);
      expect(section.playlist.likeCount, 0);
      expect(section.playlist.coverImage, '');
      expect(section.playlist.previewTrack.id, '');
      expect(section.tracksPreview, isEmpty);
    });

    test('parses introducing playlist', () {
      final playlist = GenreDto.parseIntroducingPlaylist({
        'playlist_id': 'playlist-1',
        'owner_user_id': 'owner-1',
        'name': 'Featured',
        'description': null,
        'is_public': false,
        'created_at': '2026-01-02T00:00:00Z',
        'track_count': 12,
        'like_count': 34,
        'cover_image': null,
        'preview_track': {
          'id': 'track-1',
          'user_id': 'user-1',
          'title': 'Preview',
          'artist': 'Artist',
          'audio_url': 'audio.mp3',
          'duration': 100,
          'created_at': '2026-01-01T00:00:00Z',
        },
      });

      expect(playlist.playlistId, 'playlist-1');
      expect(playlist.description, '');
      expect(playlist.isPublic, false);
      expect(playlist.coverImage, '');
      expect(playlist.previewTrack.title, 'Preview');
    });

    test('parses playlist, album, and artist entries', () {
      final playlist = GenreDto.parsePlaylist({
        'id': 'playlist-1',
        'name': 'Playlist One',
        'cover_image': null,
        'owner_id': 'owner-1',
        'owner_name': 'Owner One',
        'track_count': 10,
        'like_count': 20,
        'source': null,
        'created_at': '2026-01-01T00:00:00Z',
      });
      final album = GenreDto.parseAlbum({
        'id': 'album-1',
        'name': 'Album One',
        'cover_image': null,
        'owner_id': 'owner-1',
        'owner_name': 'Artist One',
        'track_count': 8,
        'like_count': 16,
        'release_date': null,
      });
      final artist = GenreDto.parseArtist({
        'id': 'artist-1',
        'display_name': 'Artist One',
        'username': null,
        'profile_picture': null,
        'is_verified': null,
        'follower_count': 100,
        'track_count_in_genre': 7,
      });

      expect(playlist.coverImage, '');
      expect(playlist.source, '');
      expect(album.releaseDate, '');
      expect(artist.username, '');
      expect(artist.profilePicture, '');
      expect(artist.isVerified, false);
    });

    test('parses genre content with all sections', () {
      final content = GenreDto.parseGenreContent({
        'genre': {
          'id': 'rock',
          'name': 'Rock',
          'cover_image': 'cover.jpg',
          'track_count': 1,
          'artist_count': 1,
          'playlist_count': 1,
          'album_count': 1,
        },
        'introducing': {
          'id': 'intro-1',
          'owner_id': 'owner-1',
          'name': 'Intro',
          'created_at': '2026-01-01T00:00:00Z',
          'tracks_preview': [],
        },
        'tracks': [_trackJson()],
        'playlists': [_playlistJson()],
        'albums': [_albumJson()],
        'artists': [_artistJson()],
      });

      expect(content.genreInfo.id, 'rock');
      expect(content.tracks.single.id, 'track-1');
      expect(content.playlists.single.id, 'playlist-1');
      expect(content.albums.single.id, 'album-1');
      expect(content.artists.single.id, 'artist-1');
    });

    test('parses genre content with missing introducing section', () {
      final content = GenreDto.parseGenreContent({});

      expect(content.genreInfo.name, 'Unknown');
      expect(content.introducing.playlist.playlistId, '');
      expect(content.tracks, isEmpty);
      expect(content.playlists, isEmpty);
      expect(content.albums, isEmpty);
      expect(content.artists, isEmpty);
    });

    test('parses paginated list responses', () {
      expect(
        GenreDto.parsePlaylistList({
          'data': {
            'playlists': [_playlistJson()],
          },
        }).single.id,
        'playlist-1',
      );
      expect(
        GenreDto.parseAlbumList({
          'data': {
            'albums': [_albumJson()],
          },
        }).single.id,
        'album-1',
      );
      expect(
        GenreDto.parseArtistList({
          'data': {
            'artists': [_artistJson()],
          },
        }).single.id,
        'artist-1',
      );
      expect(
        GenreDto.parseTrackList({
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
  'artist': 'Artist One',
  'audio_url': 'audio.mp3',
  'duration': 180,
  'created_at': '2026-01-01T00:00:00Z',
};

Map<String, dynamic> _playlistJson() => {
  'id': 'playlist-1',
  'name': 'Playlist One',
  'cover_image': 'cover.jpg',
  'owner_id': 'owner-1',
  'owner_name': 'Owner One',
  'track_count': 10,
  'like_count': 20,
  'source': 'tagged',
  'created_at': '2026-01-01T00:00:00Z',
};

Map<String, dynamic> _albumJson() => {
  'id': 'album-1',
  'name': 'Album One',
  'cover_image': 'cover.jpg',
  'owner_id': 'owner-1',
  'owner_name': 'Artist One',
  'track_count': 8,
  'like_count': 16,
  'release_date': '2026-01-01',
};

Map<String, dynamic> _artistJson() => {
  'id': 'artist-1',
  'display_name': 'Artist One',
  'username': 'artistone',
  'profile_picture': 'avatar.jpg',
  'is_verified': true,
  'follower_count': 100,
  'track_count_in_genre': 7,
};
