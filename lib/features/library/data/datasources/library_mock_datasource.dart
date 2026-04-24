import 'dart:math';
import '../../../../core/data/models/track_dto.dart';
import '../models/library_models.dart';
import 'library_remote_datasource.dart';

/// Mock implementation of [LibraryRemoteDatasource].
///
/// Provides realistic in-memory data for development and testing.
/// Toggle via [useLibraryMockData] in [library_providers.dart].
class LibraryMockDatasource implements LibraryRemoteDatasource {
  // ── Following data ────────────────────────────────────────────────────────

  static final List<FollowedUserModel> _following = [
    FollowedUserModel(
      id: 'user-002',
      displayName: 'Bassel Alaa',
      username: 'basselalaa',
      avatarUrl: 'https://i.pravatar.cc/400?img=33',
      followersCount: 4120,
      isVerified: true,
    ),
    FollowedUserModel(
      id: 'user-004',
      displayName: 'Rana Elgharabawy',
      username: 'rana_eg',
      avatarUrl: 'https://i.pravatar.cc/400?img=47',
      followersCount: 8900,
    ),
    FollowedUserModel(
      id: 'user-005',
      displayName: '~H',
      username: 'hxmusic',
      avatarUrl: 'https://i.pravatar.cc/400?img=60',
      followersCount: 560,
    ),
    FollowedUserModel(
      id: 'user-006',
      displayName: '~sohaila',
      username: 'sohaila_s',
      avatarUrl: 'https://i.pravatar.cc/400?img=44',
      followersCount: 2300,
    ),
    FollowedUserModel(
      id: 'user-007',
      displayName: 'DJ Menna',
      username: 'djmenna',
      avatarUrl: 'https://i.pravatar.cc/400?img=25',
      followersCount: 15400,
      isVerified: true,
    ),
    FollowedUserModel(
      id: 'user-008',
      displayName: 'Cairo Beats',
      username: 'cairobeats',
      avatarUrl: 'https://i.pravatar.cc/400?img=12',
      followersCount: 7800,
    ),
  ];

  // ── Playlists data ────────────────────────────────────────────────────────

  static final List<LibraryPlaylistModel> _playlists = [
    LibraryPlaylistModel(
      id: 'pl-001',
      name: 'Late Night Drive',
      description: 'Chill electronic for long drives',
      coverUrl: 'https://picsum.photos/seed/pl1/300/300',
      trackCount: 18,
      likeCount: 42,
      isPublic: true,
      isOwned: true,
      createdAt: DateTime(2026, 1, 15),
    ),
    LibraryPlaylistModel(
      id: 'pl-002',
      name: 'Morning Coffee',
      description: null,
      coverUrl: 'https://picsum.photos/seed/pl2/300/300',
      trackCount: 12,
      likeCount: 8,
      isPublic: false,
      isOwned: true,
      createdAt: DateTime(2026, 2, 3),
    ),
    LibraryPlaylistModel(
      id: 'pl-003',
      name: 'Gym Session',
      coverUrl: 'https://picsum.photos/seed/pl3/300/300',
      trackCount: 25,
      likeCount: 190,
      isPublic: true,
      isOwned: true,
      createdAt: DateTime(2025, 12, 20),
    ),
    LibraryPlaylistModel(
      id: 'pl-004',
      name: 'Egyptian Hip-Hop Hits',
      coverUrl: 'https://picsum.photos/seed/pl4/300/300',
      trackCount: 32,
      likeCount: 1200,
      isPublic: true,
      isOwned: false,
      createdAt: DateTime(2025, 11, 5),
    ),
  ];

  // ── Uploads data ──────────────────────────────────────────────────────────

  static final List<UploadedTrackModel> _uploads = [
    UploadedTrackModel(
      track: TrackDto.fromJson({
        'id': 'track-u1',
        'title': 'Cairo Nights v2',
        'artwork_url': 'https://picsum.photos/seed/t1/300/300',
        'play_count': 4200,
        'like_count': 87,
        'created_at': DateTime(2026, 3, 1).toIso8601String(),
      }),
      isPublic: true,
      status: 'ready',
    ),
    UploadedTrackModel(
      track: TrackDto.fromJson({
        'id': 'track-u2',
        'title': 'Desert Echo (Remaster)',
        'artwork_url': 'https://picsum.photos/seed/t7/300/300',
        'play_count': 3400,
        'like_count': 61,
        'created_at': DateTime(2026, 2, 14).toIso8601String(),
      }),
      isPublic: true,
      status: 'ready',
    ),
    UploadedTrackModel(
      track: TrackDto.fromJson({
        'id': 'track-u3',
        'title': 'Pyramids at Dusk',
        'artwork_url': 'https://picsum.photos/seed/t11/300/300',
        'play_count': 0,
        'like_count': 0,
        'created_at': DateTime(2026, 3, 5).toIso8601String(),
      }),
      isPublic: false,
      status: 'processing',
    ),
    UploadedTrackModel(
      track: TrackDto.fromJson({
        'id': 'track-u4',
        'title': 'Old Draft WIP',
        'play_count': 120,
        'like_count': 3,
        'created_at': DateTime(2025, 10, 10).toIso8601String(),
      }),
      isPublic: false,
      status: 'ready',
    ),
  ];

  // ── History data ──────────────────────────────────────────────────────────

  static final List<RecentlyPlayedEntryModel> _history = [
    RecentlyPlayedEntryModel(
      trackId: 'track-001',
      userId: 'user-001',
      title: 'Cairo Nights',
      artistName: 'Bassel Alaa',
      artworkUrl: 'https://picsum.photos/seed/t1/300/300',
      durationSeconds: 238,
      playCount: 1250,
      playedAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    RecentlyPlayedEntryModel(
      trackId: 'track-002',
      userId: 'user-002',
      title: 'Alexandria Waves',
      artistName: 'Mohammed Al Abasy',
      artworkUrl: 'https://picsum.photos/seed/t2/300/300',
      durationSeconds: 195,
      playCount: 890,
      playedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    RecentlyPlayedEntryModel(
      trackId: 'track-003',
      userId: 'user-003',
      title: 'Free Palestine',
      artistName: 'Rana Elgharabawy',
      artworkUrl: 'https://picsum.photos/seed/t3/300/300',
      durationSeconds: 312,
      playCount: 4500,
      playedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    RecentlyPlayedEntryModel(
      trackId: 'track-004',
      userId: 'user-004',
      title: 'Midnight Cat',
      artistName: '~H',
      artworkUrl: 'https://picsum.photos/seed/t4/300/300',
      durationSeconds: 174,
      playCount: 320,
      playedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    RecentlyPlayedEntryModel(
      trackId: 'track-005',
      userId: 'user-005',
      title: 'Coffee at 3am',
      artistName: '~sohaila',
      artworkUrl: 'https://picsum.photos/seed/t5/300/300',
      durationSeconds: 221,
      playCount: 150,
      playedAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    ),
    RecentlyPlayedEntryModel(
      trackId: 'track-006',
      userId: 'user-006',
      title: 'Basslines from Giza',
      artistName: 'KarimWI',
      artworkUrl: 'https://picsum.photos/seed/t6/300/300',
      durationSeconds: 275,
      playCount: 670,
      playedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    RecentlyPlayedEntryModel(
      trackId: 'track-007',
      userId: 'user-007',
      title: 'Desert Echo',
      artistName: 'KarimWI',
      artworkUrl: 'https://picsum.photos/seed/t7/300/300',
      durationSeconds: 198,
      playCount: 430,
      playedAt: DateTime.now().subtract(const Duration(days: 2, hours: 6)),
    ),
    RecentlyPlayedEntryModel(
      trackId: 'track-008',
      userId: 'user-008',
      title: 'Nile Flow',
      artistName: 'Mohammed Al Abasy',
      artworkUrl: 'https://picsum.photos/seed/t8/300/300',
      durationSeconds: 263,
      playCount: 2100,
      playedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  // ── Stations data ─────────────────────────────────────────────────────────

  static final List<LibraryStationModel> _stations = [
    LibraryStationModel(
      id: 'st-001',
      name: 'Based on Bassel Alaa',
      coverUrl: 'https://picsum.photos/seed/st1/300/300',
      seedArtistName: 'Bassel Alaa',
      trackCount: 50,
    ),
    LibraryStationModel(
      id: 'st-002',
      name: 'Based on Rana Elgharabawy',
      coverUrl: 'https://picsum.photos/seed/st2/300/300',
      seedArtistName: 'Rana Elgharabawy',
      trackCount: 50,
    ),
    LibraryStationModel(
      id: 'st-003',
      name: 'Based on DJ Menna',
      coverUrl: 'https://picsum.photos/seed/st3/300/300',
      seedArtistName: 'DJ Menna',
      trackCount: 50,
    ),
    LibraryStationModel(
      id: 'st-004',
      name: 'Based on Cairo Beats',
      coverUrl: 'https://picsum.photos/seed/st4/300/300',
      seedArtistName: 'Cairo Beats',
      trackCount: 50,
    ),
  ];

  // ── Implementations ───────────────────────────────────────────────────────

  @override
  Future<List<FollowedUserModel>> getFollowing({
    required int page,
    required int limit,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final start = (page - 1) * limit;
    if (start >= _following.length) return [];
    return _following.sublist(start, min(start + limit, _following.length));
  }

  @override
  Future<void> unfollowUser({required String userId}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _following.removeWhere((u) => u.id == userId);
  }

  @override
  Future<List<LibraryPlaylistModel>> getMyPlaylists() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return List.from(_playlists);
  }

  @override
  Future<LibraryPlaylistModel> createPlaylist({
    required String name,
    String? description,
    required bool isPublic,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final newPlaylist = LibraryPlaylistModel(
      id: 'pl-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      coverUrl: null,
      trackCount: 0,
      likeCount: 0,
      isPublic: isPublic,
      isOwned: true,
      createdAt: DateTime.now(),
    );
    _playlists.insert(0, newPlaylist);
    return newPlaylist;
  }

  @override
  Future<void> deletePlaylist({required String playlistId}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _playlists.removeWhere((p) => p.id == playlistId);
  }

  @override
  Future<List<UploadedTrackModel>> getMyUploads({
    required int page,
    required int limit,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final start = (page - 1) * limit;
    if (start >= _uploads.length) return [];
    return _uploads.sublist(start, min(start + limit, _uploads.length));
  }

  @override
  Future<void> toggleTrackVisibility({
    required String trackId,
    required bool isPublic,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final idx = _uploads.indexWhere((t) => t.id == trackId);
    if (idx != -1) {
      final t = _uploads[idx];
      _uploads[idx] = UploadedTrackModel(
        track: t.track,
        isPublic: isPublic,
        status: t.status,
      );
    }
  }

  @override
  Future<void> deleteTrack({required String trackId}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _uploads.removeWhere((t) => t.id == trackId);
  }

  @override
  Future<List<TrackInsightModel>> getMyInsights() async {
    /// Fetches analytics insights for all tracks uploaded by the current user.
    ///
    /// Returns insights for all tracks including those still processing.
    /// Mock data includes play counts, listener counts, likes, reposts, and comments.
    await Future.delayed(const Duration(milliseconds: 800));
    return _uploads
        .map(
          (t) => TrackInsightModel(
            trackId: t.id,
            title: t.title,
            artworkUrl: t.artworkUrl,
            totalPlays: t.playCount,
            uniqueListeners: (t.playCount * 0.6).round(),
            likes: t.likeCount,
            reposts: (t.likeCount * 0.3).round(),
            comments: (t.likeCount * 0.15).round(),
          ),
        )
        .toList();
  }

  @override
  Future<List<RecentlyPlayedEntryModel>> getRecentlyPlayed() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _history.take(20).toList();
  }

  @override
  Future<List<RecentlyPlayedEntryModel>> getListeningHistory({
    required int page,
    required int limit,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final start = (page - 1) * limit;
    if (start >= _history.length) return [];
    return _history.sublist(start, min(start + limit, _history.length));
  }

  @override
  Future<void> clearListeningHistory() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _history.clear();
  }

  @override
  Future<List<LibraryStationModel>> getStations() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return List.from(_stations);
  }

  @override
  Future<List<LikedTrackModel>> getLikedTracks({
    required int page,
    required int limit,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    // Return a mix of mock liked tracks
    return _history
        .take(limit)
        .map(
          (h) => LikedTrackModel(
            track: TrackDto.fromJson({
              'id': h.trackId,
              'title': h.title,
              'artist_name': h.artistName,
              'cover_image': h.artworkUrl,
              'duration': h.durationSeconds,
              'play_count': h.playCount,
              'like_count': 1,
            }),
          ),
        )
        .toList();
  }
}
