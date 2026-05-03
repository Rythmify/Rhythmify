import 'dart:math';
import '../models/profile_model.dart';
import '../models/profile_user_summary_model.dart';
import '../models/track_model.dart';
import '../models/follow_status_model.dart';
import '../../../playlist/domain/entities/playlist_entity.dart';
import 'profile_remote_datasource.dart';

/// In-memory profile datasource for local development and repeatable tests.
class ProfileMockDatasource implements ProfileRemoteDatasource {
  // ── Base mock profiles ────────────────────────────────
  static final List<Map<String, dynamic>> _mockProfiles = [
    {
      'id': 'user-001',
      'username': 'karimwi',
      'display_name': 'KarimWI',
      'avatar_url': 'https://i.pravatar.cc/400?img=11',
      'cover_url': 'https://picsum.photos/seed/karim/1500/500',
      'city': 'Giza',
      'country': 'EG',
      'bio':
          'Music producer from Egypt. Into beats, basslines, and everything in between.',
      'followers_count': 1240,
      'following_count': 380,
      'tracks_count': 14,
      'is_following': false,
      'is_user_premium': true,
    },
    {
      'id': 'user-002',
      'username': 'basselalaa',
      'display_name': 'Bassel Alaa',
      'avatar_url': 'https://i.pravatar.cc/400?img=33',
      'cover_url': 'https://picsum.photos/seed/bassel/1500/500',
      'city': 'Cairo',
      'country': 'EG',
      'bio': 'Sub-team leader. Backend engineer. 0.001% of the internet.',
      'followers_count': 4120,
      'following_count': 88,
      'tracks_count': 23,
      'is_following': true,
      'is_user_premium': true,
    },
    {
      'id': 'user-003',
      'username': 'moh_alabasy',
      'display_name': 'Mohammed Al Abasy',
      'avatar_url': 'https://i.pravatar.cc/400?img=57',
      'cover_url': 'https://picsum.photos/seed/mohammed/1500/500',
      'city': 'Alexandria',
      'country': 'EG',
      'bio': 'Software engineer by day, music listener by night.',
      'followers_count': 134,
      'following_count': 210,
      'tracks_count': 7,
      'is_following': false,
    },
    {
      'id': 'user-004',
      'username': 'rana_eg',
      'display_name': 'Rana Elgharabawy',
      'avatar_url': 'https://i.pravatar.cc/400?img=47',
      'cover_url': 'https://picsum.photos/seed/rana/1500/500',
      'city': 'Cairo',
      'country': 'PS',
      'bio': 'Just here for the music and the vibes.',
      'followers_count': 8900,
      'following_count': 345,
      'tracks_count': 15,
      'is_following': true,
    },
    {
      'id': 'user-005',
      'username': 'hxmusic',
      'display_name': '~H',
      'avatar_url': 'https://i.pravatar.cc/400?img=60',
      'cover_url': 'https://picsum.photos/seed/hx/1500/500',
      'city': 'Cairo',
      'country': 'EG',
      'bio': null,
      'followers_count': 560,
      'following_count': 120,
      'tracks_count': 3,
      'is_following': false,
    },
    {
      'id': 'user-006',
      'username': 'sohaila_s',
      'display_name': '~sohaila',
      'avatar_url': 'https://i.pravatar.cc/400?img=44',
      'cover_url': 'https://picsum.photos/seed/sohaila/1500/500',
      'city': 'Cairo',
      'country': 'EG',
      'bio': 'Listener. Dreamer. Coffee addict.',
      'followers_count': 2300,
      'following_count': 178,
      'tracks_count': 0,
      'is_following': false,
    },
  ];

  // ── Liked tracks per user ─────────────────────────────
  static final Map<String, List<Map<String, dynamic>>> _likedTracksByUser = {
    'user-001': [
      {
        'id': 'track-001',
        'title': 'Cairo Nights',
        'user_id': 'user-002',
        'display_name': 'Bassel Alaa',
        'artwork_url': 'https://picsum.photos/seed/t1/300/300',
        'play_count': 4200,
        'duration': 238,
        'genre': 'Electronic',
      },
      {
        'id': 'track-002',
        'title': 'Alexandria Waves',
        'user_id': 'user-003',
        'display_name': 'Mohammed Al Abasy',
        'artwork_url': 'https://picsum.photos/seed/t2/300/300',
        'play_count': 1800,
        'duration': 195,
        'genre': 'Chill',
      },
      {
        'id': 'track-003',
        'title': 'Free Palestine',
        'user_id': 'user-004',
        'display_name': 'Rana Elgharabawy',
        'artwork_url': 'https://picsum.photos/seed/t3/300/300',
        'play_count': 9900,
        'duration': 312,
        'genre': 'Hip-Hop',
      },
      {
        'id': 'track-004',
        'title': 'Midnight Cat',
        'user_id': 'user-005',
        'display_name': '~H',
        'artwork_url': 'https://picsum.photos/seed/t4/300/300',
        'play_count': 560,
        'duration': 174,
        'genre': 'Lo-Fi',
      },
      {
        'id': 'track-005',
        'title': 'Coffee at 3am',
        'user_id': 'user-006',
        'display_name': '~sohaila',
        'artwork_url': 'https://picsum.photos/seed/t5/300/300',
        'play_count': 2300,
        'duration': 221,
        'genre': 'Ambient',
      },
    ],
    'user-002': [
      {
        'id': 'track-006',
        'title': 'Basslines from Giza',
        'user_id': 'user-001',
        'display_name': 'KarimWI',
        'artwork_url': 'https://picsum.photos/seed/t6/300/300',
        'play_count': 1200,
        'duration': 275,
        'genre': 'Electronic',
      },
      {
        'id': 'track-007',
        'title': 'Desert Echo',
        'user_id': 'user-001',
        'display_name': 'KarimWI',
        'artwork_url': 'https://picsum.photos/seed/t7/300/300',
        'play_count': 3400,
        'duration': 198,
        'genre': 'Electronic',
      },
      {
        'id': 'track-008',
        'title': 'Nile Flow',
        'user_id': 'user-003',
        'display_name': 'Mohammed Al Abasy',
        'artwork_url': 'https://picsum.photos/seed/t8/300/300',
        'play_count': 7800,
        'duration': 263,
        'genre': 'Chill',
      },
    ],
    'user-004': [
      {
        'id': 'track-009',
        'title': 'Rooftop Sessions',
        'user_id': 'user-002',
        'display_name': 'Bassel Alaa',
        'artwork_url': 'https://picsum.photos/seed/t9/300/300',
        'play_count': 4500,
        'duration': 187,
        'genre': 'R&B',
      },
      {
        'id': 'track-010',
        'title': 'Lost Signal',
        'user_id': 'user-005',
        'display_name': '~H',
        'artwork_url': 'https://picsum.photos/seed/t10/300/300',
        'play_count': 890,
        'duration': 244,
        'genre': 'Experimental',
      },
      {
        'id': 'track-001',
        'title': 'Cairo Nights',
        'user_id': 'user-002',
        'display_name': 'Bassel Alaa',
        'artwork_url': 'https://picsum.photos/seed/t1/300/300',
        'play_count': 4200,
        'duration': 238,
        'genre': 'Electronic',
      },
    ],
  };

  // ── Current logged in user ────────────────────────────
  static Map<String, dynamic>? _currentUserProfile;

  // ── Called by auth on signup ──────────────────────────
  static void addDynamicProfile({
    required String id,
    required String displayName,
    required String email,
    required String gender,
    required String dateOfBirth,
  }) {
    // ── Remove if already exists ──────────────────────
    _mockProfiles.removeWhere((p) => p['id'] == id);

    // ── Generate username from display name ───────────
    final username = displayName
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '');

    // ── Generate avatar from email hash ───────────────
    final avatarSeed = email.hashCode.abs() % 70 + 1;

    _mockProfiles.add({
      'id': id,
      'username': username,
      'display_name': displayName,
      'avatar_url': 'https://i.pravatar.cc/400?img=$avatarSeed',
      'cover_url': 'https://picsum.photos/seed/$id/1500/500',
      'city': null,
      'country': null,
      'bio': null,
      'followers_count': 0,
      'following_count': 0,
      'tracks_count': 0,
      'is_following': false,
    });

    // ── Set as current user ───────────────────────────
    _currentUserProfile = _mockProfiles.last;

    // ── Add empty liked tracks list ───────────────────
    _likedTracksByUser[id] = [];
  }

  static void setCurrentUser(String userId) {
    _currentUserProfile = Map.from(
      _mockProfiles.firstWhere(
        (p) => p['id'] == userId,
        orElse: () => _mockProfiles[0],
      ),
    );
  }

  // ── Helper ────────────────────────────────────────────
  Map<String, dynamic> _getProfileById(String userId) {
    if (userId == 'me' ||
        userId == (_currentUserProfile?['id'] ?? 'user-001')) {
      return _currentUserProfile ?? Map.from(_mockProfiles[0]);
    }
    return Map.from(
      _mockProfiles.firstWhere(
        (p) => p['id'] == userId,
        orElse: () => throw Exception('PROFILE_NOT_FOUND'),
      ),
    );
  }

  @override
  Future<ProfileModel> getProfile({required String userId}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final profile = _getProfileById(userId);
    return ProfileModel.fromJson(profile);
  }

  @override
  Future<FollowStatusModel> getFollowStatus(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    const simulateBlocked = false; // ← toggle for UI dev

    return const FollowStatusModel(
      isFollowing: false,
      isFollowedBy: false,
      isBlocking: simulateBlocked,
      isBlockedBy: false,
    );
  }

  @override
  Future<ProfileModel> updateProfile({
    required String displayName,
    required String username,
    required String firstName,
    required String lastName,
    required String city,
    required String country,
    required String bio,
    String? instagramUrl,
    String? facebookUrl,
    String? githubUrl,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    if (displayName.trim().isEmpty) {
      throw Exception('VALIDATION_FAILED: display name cannot be empty');
    }

    _currentUserProfile = {
      ...(_currentUserProfile ?? Map.from(_mockProfiles[0])),
      'display_name': displayName,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'city': city,
      'country': country,
      'bio': bio,
      'instagram_url': instagramUrl ?? '',
      'facebook_url': facebookUrl ?? '',
      'github_url': githubUrl ?? '',
    };

    // ── Update in list too ────────────────────────────
    final idx = _mockProfiles.indexWhere(
      (p) => p['id'] == _currentUserProfile!['id'],
    );
    if (idx != -1) _mockProfiles[idx] = Map.from(_currentUserProfile!);

    return ProfileModel.fromJson(_currentUserProfile!);
  }

  @override
  Future<ProfileModel> uploadAvatar({required String filePath}) async {
    await Future.delayed(const Duration(seconds: 2));

    _currentUserProfile = {
      ...(_currentUserProfile ?? Map.from(_mockProfiles[0])),
      'avatar_url':
          'https://i.pravatar.cc/400?u=${_currentUserProfile?['id']}-${DateTime.now().millisecondsSinceEpoch}',
    };

    final idx = _mockProfiles.indexWhere(
      (p) => p['id'] == _currentUserProfile!['id'],
    );
    if (idx != -1) _mockProfiles[idx] = Map.from(_currentUserProfile!);

    return ProfileModel.fromJson(_currentUserProfile!);
  }

  @override
  Future<void> deleteAvatar() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUserProfile = {
      ...(_currentUserProfile ?? Map.from(_mockProfiles[0])),
      'avatar_url': null,
    };
  }

  @override
  Future<ProfileModel> uploadCoverPhoto({required String filePath}) async {
    await Future.delayed(const Duration(seconds: 2));

    _currentUserProfile = {
      ...(_currentUserProfile ?? Map.from(_mockProfiles[0])),
      'cover_url':
          'https://picsum.photos/seed/${_currentUserProfile?['id']}-${DateTime.now().millisecondsSinceEpoch}/1500/500',
    };

    final idx = _mockProfiles.indexWhere(
      (p) => p['id'] == _currentUserProfile!['id'],
    );
    if (idx != -1) _mockProfiles[idx] = Map.from(_currentUserProfile!);

    return ProfileModel.fromJson(_currentUserProfile!);
  }

  @override
  Future<void> deleteCoverPhoto() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUserProfile = {
      ...(_currentUserProfile ?? Map.from(_mockProfiles[0])),
      'cover_url': null,
    };
  }

  @override
  Future<void> followUser({required String userId}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (userId == (_currentUserProfile?['id'] ?? 'user-001')) {
      throw Exception('FOLLOW_SELF');
    }
  }

  @override
  Future<void> unfollowUser({required String userId}) async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<void> blockUser({required String userId}) async {
    return;
  }

  @override
  Future<void> unblockUser({required String userId}) async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<List<TrackModel>> getLikedTracks({
    required String userId,
    required int page,
    required int limit,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final resolvedId = userId == 'me'
        ? (_currentUserProfile?['id'] ?? 'user-001')
        : userId;

    final tracks = List<Map<String, dynamic>>.from(
      _likedTracksByUser[resolvedId] ?? [],
    );

    final start = (page - 1) * limit;
    final end = min(start + limit, tracks.length);

    if (start >= tracks.length) return [];

    return tracks
        .sublist(start, end)
        .map(
          (t) => TrackModel.fromJson({
            ...Map<String, dynamic>.from(t),
            'is_liked': true,
          }),
        )
        .toList();
  }

  @override
  Future<List<TrackModel>> getUploadedTracks({
    required String userId,
    required int page,
    required int limit,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final resolvedId = userId == 'me'
        ? (_currentUserProfile?['id'] ?? 'user-001')
        : userId;

    // Just reuse some likes as "uploads" for mock purposes
    final tracks = List<Map<String, dynamic>>.from(
      _likedTracksByUser[resolvedId] ?? [],
    ).reversed.toList();

    final start = (page - 1) * limit;
    final end = min(start + limit, tracks.length);

    if (start >= tracks.length) return [];

    return tracks
        .sublist(start, end)
        .map(
          (t) => TrackModel.fromJson({
            ...Map<String, dynamic>.from(t),
            'is_liked': false,
          }),
        )
        .toList();
  }

  @override
  Future<List<TrackModel>> getRepostedTracks({
    required String userId,
    required int page,
    required int limit,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // Return empty list if no reposts or use a subset
    return [];
  }

  @override
  Future<List<ProfileUserSummaryModel>> getFollowers({
    required String userId,
    required int page,
    required int limit,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final start = (page - 1) * limit;
    final end = min(start + limit, _mockProfiles.length);
    if (start >= _mockProfiles.length) return [];
    return _mockProfiles
        .sublist(start, end)
        .map(
          (user) => ProfileUserSummaryModel.fromJson(user, isFollowing: false),
        )
        .toList();
  }

  @override
  Future<List<ProfileUserSummaryModel>> getFollowing({
    required String userId,
    required int page,
    required int limit,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final start = (page - 1) * limit;
    final end = min(start + limit, _mockProfiles.length);
    if (start >= _mockProfiles.length) return [];
    return _mockProfiles.reversed
        .toList()
        .sublist(start, end)
        .map(
          (user) => ProfileUserSummaryModel.fromJson(user, isFollowing: true),
        )
        .toList();
  }

  @override
  Future<List<PlaylistEntity>> getAlbums({
    required String userId,
    required int limit,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [];
  }
}
