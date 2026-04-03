import '../../../../core/domain/entities/track.dart';
import '../../domain/entities/vibes_genre_content.dart';

abstract class GenreRemoteSource {
  Future<GenreContent> getGenreContent(String genreId);
}

class GenreRemoteSourceMock implements GenreRemoteSource {
  static final _tracks = {
    'hiphop': [
      Track(
        id: 'h1',
        userId: 'u1',
        title: 'HUMBLE.',
        artist: 'Kendrick Lamar',
        audioUrl: '',
        duration: const Duration(minutes: 2, seconds: 57),
        createdAt: DateTime(2017, 4, 7),
        coverImage: 'assets/images/vibes_hiphop.jpeg',
        genre: 'Hip Hop',
      ),
      Track(
        id: 'h2',
        userId: 'u1',
        title: 'God\'s Plan',
        artist: 'Drake',
        audioUrl: '',
        duration: const Duration(minutes: 3, seconds: 18),
        createdAt: DateTime(2018, 1, 19),
        coverImage: 'assets/images/vibes_hiphop.jpeg',
        genre: 'Hip Hop',
      ),
      Track(
        id: 'h3',
        userId: 'u2',
        title: 'SICKO MODE',
        artist: 'Travis Scott',
        audioUrl: '',
        duration: const Duration(minutes: 5, seconds: 12),
        createdAt: DateTime(2018, 8, 3),
        coverImage: 'assets/images/vibes_hiphop.jpeg',
        genre: 'Hip Hop',
      ),
      Track(
        id: 'h4',
        userId: 'u2',
        title: 'Lucid Dreams',
        artist: 'Juice WRLD',
        audioUrl: '',
        duration: const Duration(minutes: 3, seconds: 59),
        createdAt: DateTime(2018, 5, 23),
        coverImage: 'assets/images/vibes_hiphop.jpeg',
        genre: 'Hip Hop',
      ),
      Track(
        id: 'h5',
        userId: 'u3',
        title: 'Rockstar',
        artist: 'Post Malone',
        audioUrl: '',
        duration: const Duration(minutes: 3, seconds: 38),
        createdAt: DateTime(2017, 9, 15),
        coverImage: 'assets/images/vibes_hiphop.jpeg',
        genre: 'Hip Hop',
      ),
      Track(
        id: 'h6',
        userId: 'u3',
        title: 'Old Town Road',
        artist: 'Lil Nas X',
        audioUrl: '',
        duration: const Duration(minutes: 1, seconds: 53),
        createdAt: DateTime(2019, 4, 5),
        coverImage: 'assets/images/vibes_hiphop.jpeg',
        genre: 'Hip Hop',
      ),
    ],
    'electronic': [
      Track(
        id: 'e1',
        userId: 'u4',
        title: 'Levels',
        artist: 'Avicii',
        audioUrl: '',
        duration: const Duration(minutes: 3, seconds: 19),
        createdAt: DateTime(2011, 10, 28),
        coverImage: 'assets/images/vibes_electronic.jpeg',
        genre: 'Electronic',
      ),
      Track(
        id: 'e2',
        userId: 'u4',
        title: 'Strobe',
        artist: 'deadmau5',
        audioUrl: '',
        duration: const Duration(minutes: 10, seconds: 33),
        createdAt: DateTime(2009, 9, 22),
        coverImage: 'assets/images/vibes_electronic.jpeg',
        genre: 'Electronic',
      ),
      Track(
        id: 'e3',
        userId: 'u5',
        title: 'Clarity',
        artist: 'Zedd',
        audioUrl: '',
        duration: const Duration(minutes: 4, seconds: 8),
        createdAt: DateTime(2012, 9, 24),
        coverImage: 'assets/images/vibes_electronic.jpeg',
        genre: 'Electronic',
      ),
      Track(
        id: 'e4',
        userId: 'u5',
        title: 'Animals',
        artist: 'Martin Garrix',
        audioUrl: '',
        duration: const Duration(minutes: 3, seconds: 37),
        createdAt: DateTime(2013, 8, 1),
        coverImage: 'assets/images/vibes_electronic.jpeg',
        genre: 'Electronic',
      ),
    ],
  };

  static final _playlists = {
    'hiphop': [
      {
        'id': 'p1',
        'title': 'Hip Hop Bangers',
        'creatorName': 'Rythmify',
        'coverImage': 'assets/images/vibes_hiphop.jpeg',
      },
      {
        'id': 'p2',
        'title': 'Rap Classics',
        'creatorName': 'Rythmify',
        'coverImage': 'assets/images/vibes_hiphop.jpeg',
      },
      {
        'id': 'p3',
        'title': 'New School Rap',
        'creatorName': 'Rythmify',
        'coverImage': 'assets/images/vibes_hiphop.jpeg',
      },
      {
        'id': 'p4',
        'title': 'Trap Hits',
        'creatorName': 'Rythmify',
        'coverImage': 'assets/images/vibes_hiphop.jpeg',
      },
    ],
    'electronic': [
      {
        'id': 'p5',
        'title': 'EDM Anthems',
        'creatorName': 'Rythmify',
        'coverImage': 'assets/images/vibes_electronic.jpeg',
      },
      {
        'id': 'p6',
        'title': 'House Classics',
        'creatorName': 'Rythmify',
        'coverImage': 'assets/images/vibes_electronic.jpeg',
      },
      {
        'id': 'p7',
        'title': 'Techno Underground',
        'creatorName': 'Rythmify',
        'coverImage': 'assets/images/vibes_electronic.jpeg',
      },
      {
        'id': 'p8',
        'title': 'Festival Hits',
        'creatorName': 'Rythmify',
        'coverImage': 'assets/images/vibes_electronic.jpeg',
      },
    ],
  };

  static final _albums = {
    'hiphop': [
      {
        'id': 'a1',
        'title': 'DAMN.',
        'artistName': 'Kendrick Lamar',
        'coverImage': 'assets/images/vibes_hiphop.jpeg',
      },
      {
        'id': 'a2',
        'title': 'Scorpion',
        'artistName': 'Drake',
        'coverImage': 'assets/images/vibes_hiphop.jpeg',
      },
      {
        'id': 'a3',
        'title': 'Astroworld',
        'artistName': 'Travis Scott',
        'coverImage': 'assets/images/vibes_hiphop.jpeg',
      },
      {
        'id': 'a4',
        'title': 'Hollywood\'s Bleeding',
        'artistName': 'Post Malone',
        'coverImage': 'assets/images/vibes_hiphop.jpeg',
      },
    ],
    'electronic': [
      {
        'id': 'a5',
        'title': 'Random Access Memories',
        'artistName': 'Daft Punk',
        'coverImage': 'assets/images/vibes_electronic.jpeg',
      },
      {
        'id': 'a6',
        'title': 'For Lack of a Better Name',
        'artistName': 'deadmau5',
        'coverImage': 'assets/images/vibes_electronic.jpeg',
      },
      {
        'id': 'a7',
        'title': 'True',
        'artistName': 'Avicii',
        'coverImage': 'assets/images/vibes_electronic.jpeg',
      },
      {
        'id': 'a8',
        'title': 'Clarity',
        'artistName': 'Zedd',
        'coverImage': 'assets/images/vibes_electronic.jpeg',
      },
    ],
  };

  static final _profiles = {
    'hiphop': [
      {'id': 'pr1', 'username': 'Kendrick Lamar'},
      {'id': 'pr2', 'username': 'Drake'},
      {'id': 'pr3', 'username': 'Travis Scott'},
      {'id': 'pr4', 'username': 'Post Malone'},
    ],
    'electronic': [
      {'id': 'pr5', 'username': 'Avicii'},
      {'id': 'pr6', 'username': 'deadmau5'},
      {'id': 'pr7', 'username': 'Zedd'},
      {'id': 'pr8', 'username': 'Martin Garrix'},
    ],
  };

  @override
  Future<GenreContent> getGenreContent(String genreId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final tracks = _tracks[genreId] ?? [];
    return GenreContent(
      trendingTracks: tracks.take(3).toList(),
      playlists: _playlists[genreId] ?? [],
      albums: _albums[genreId] ?? [],
      profiles: _profiles[genreId] ?? [],
      discoverTracks: tracks,
    );
  }
}
