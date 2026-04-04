import '../../domain/entities/search_suggestion.dart';
import '../../domain/entities/search_results.dart';
import '../../../../core/domain/entities/track.dart';
import '../../../profile/domain/entities/profile_entity.dart';

abstract class SearchRemoteSource {
  Future<List<SearchSuggestion>> getSuggestions(String query);
  Future<SearchResults> getSearchResults(String query);
}

class SearchRemoteSourceMock implements SearchRemoteSource {
  static const _suggestions = [
    SearchSuggestion(id: '1', text: 'Blinding Lights', type: 'track'),
    SearchSuggestion(id: '2', text: 'The Weeknd', type: 'user'),
    SearchSuggestion(id: '3', text: 'Chill Vibes', type: 'playlist'),
    SearchSuggestion(id: '4', text: 'Bad Guy', type: 'track'),
    SearchSuggestion(id: '5', text: 'Billie Eilish', type: 'user'),
    SearchSuggestion(id: '6', text: 'Lo-Fi Beats', type: 'playlist'),
    SearchSuggestion(id: '7', text: 'Shape of You', type: 'track'),
    SearchSuggestion(id: '8', text: 'Ed Sheeran', type: 'user'),
  ];

  static final _mockTracks = [
    Track(
      id: 't1',
      userId: 'u1',
      title: 'Blinding Lights',
      artist: 'The Weeknd',
      audioUrl: '',
      duration: const Duration(minutes: 3, seconds: 20),
      createdAt: DateTime(2020, 11, 29),
      coverImage: 'assets/images/placeholder.png',
      genre: 'Pop',
    ),
    Track(
      id: 't2',
      userId: 'u1',
      title: 'Save Your Tears',
      artist: 'The Weeknd',
      audioUrl: '',
      duration: const Duration(minutes: 3, seconds: 35),
      createdAt: DateTime(2020, 11, 29),
      coverImage: 'assets/images/placeholder.png',
      genre: 'Pop',
    ),
    Track(
      id: 't5',
      userId: 'u2',
      title: 'ocean eyes',
      artist: 'Billie Eilish',
      audioUrl: '',
      duration: const Duration(minutes: 3, seconds: 20),
      createdAt: DateTime(2020, 11, 29),
      coverImage: 'assets/images/placeholder.png',
      genre: 'Pop',
    ),
    Track(
      id: 't3',
      userId: 'u2',
      title: 'Starboy',
      artist: 'The Weeknd',
      audioUrl: '',
      duration: const Duration(minutes: 3, seconds: 50),
      createdAt: DateTime(2016, 9, 22),
      coverImage: 'assets/images/placeholder.png',
      genre: 'Pop',
    ),
    Track(
      id: 't4',
      userId: 'u2',
      title: 'Die For You',
      artist: 'The Weeknd',
      audioUrl: '',
      duration: const Duration(minutes: 4, seconds: 20),
      createdAt: DateTime(2016, 11, 25),
      coverImage: 'assets/images/placeholder.png',
      genre: 'R&B',
    ),
  ];

  static final _mockProfiles = [
    ProfileEntity(
      id: 'pr1',
      displayName: 'The Weeknd',
      username: 'theweeknd',
      avatarUrl: null,
      followersCount: 5000000,
      followingCount: 100,
      tracksCount: 50,
      isFollowing: false,
    ),
    ProfileEntity(
      id: 'pr1',
      displayName: 'The Weeknd',
      username: 'theweeknd',
      avatarUrl: null,
      followersCount: 5000000,
      followingCount: 100,
      tracksCount: 50,
      isFollowing: false,
    ),
    ProfileEntity(
      id: 'pr2',
      displayName: 'Billie Eilish',
      username: 'billieeilish',
      avatarUrl: null,
      followersCount: 8000000,
      followingCount: 200,
      tracksCount: 30,
      isFollowing: false,
    ),
    ProfileEntity(
      id: 'pr3',
      displayName: 'Ed Sheeran',
      username: 'edsheeran',
      avatarUrl: null,
      followersCount: 6000000,
      followingCount: 150,
      tracksCount: 60,
      isFollowing: false,
    ),
  ];

  @override
  Future<List<SearchSuggestion>> getSuggestions(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final q = query.toLowerCase().trim();
    return _suggestions
        .where((s) => s.text.toLowerCase().startsWith(q))
        .toList();
  }

  @override
  Future<SearchResults> getSearchResults(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final q = query.toLowerCase().trim();

    final tracks = _mockTracks
        .where(
          (t) =>
              t.title.toLowerCase().contains(q) ||
              t.artist.toLowerCase().contains(q),
        )
        .toList();

    final profiles = _mockProfiles
        .where(
          (p) =>
              p.displayName.toLowerCase().contains(q) ||
              (p.username?.toLowerCase().contains(q) ?? false),
        )
        .toList();

    return SearchResults(tracks: tracks, profiles: profiles);
  }
}
