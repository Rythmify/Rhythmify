import 'dart:math';
import '../models/profile_model.dart';
import '../models/track_model.dart';
import 'profile_remote_datasource.dart';

class ProfileMockDatasource implements ProfileRemoteDatasource {
  // ── Mock Profiles ─────────────────────────────────────────────────────
  static const _mockProfiles = [
    {
      'id': 'user-001',
      'display_name': 'KarimWI',
      'avatar_url': null,
      'cover_url': null,
      'city': 'Giza',
      'country': 'Egypt',
      'bio': 'Music producer from Egypt. Into beats, basslines, and everything in between.',
      'followers_count': 0,
      'following_count': 0,
      'tracks_count': 0,
      'is_following': false,
    },
    {
      'id': 'user-002',
      'display_name': 'Bassel Alaa',
      'avatar_url': null,
      'cover_url': null,
      'city': 'Cairo',
      'country': 'Egypt',
      'bio': 'Sub-team leader. 0.001% of the internet.',
      'followers_count': 412,
      'following_count': 88,
      'tracks_count': 23,
      'is_following': true,
    },
    {
      'id': 'user-003',
      'display_name': 'Mohammed Al Abasy',
      'avatar_url': null,
      'cover_url': null,
      'city': 'Alexandria',
      'country': 'Egypt',
      'bio': 'Software engineer by day, music listener by night.',
      'followers_count': 134,
      'following_count': 210,
      'tracks_count': 7,
      'is_following': false,
    },
    {
      'id': 'user-004',
      'display_name': 'Rana Elgharabawy',
      'avatar_url': null,
      'cover_url': null,
      'city': 'Cairo',
      'country': 'Palestine',
      'bio': 'Just here for the music and the vibes.',
      'followers_count': 890,
      'following_count': 345,
      'tracks_count': 15,
      'is_following': true,
    },
    {
      'id': 'user-005',
      'display_name': '~H',
      'avatar_url': null,
      'cover_url': null,
      'city': 'Cairo',
      'country': 'Egypt',
      'bio': null,
      'followers_count': 56,
      'following_count': 120,
      'tracks_count': 3,
      'is_following': false,
    },
    {
      'id': 'user-006',
      'display_name': '~sohaila',
      'avatar_url': null,
      'cover_url': null,
      'city': 'Cairo',
      'country': 'Egypt',
      'bio': 'Listener. Dreamer. Coffee addict.',
      'followers_count': 230,
      'following_count': 178,
      'tracks_count': 0,
      'is_following': false,
    },
  ];

  // ── Mock Tracks ───────────────────────────────────────────────────────
  static const _mockTracks = [
    {
      'id': 'track-001',
      'title': 'Cairo Nights',
      'user': {'display_name': 'Bassel Alaa'},
      'artwork_url': null,
      'play_count': 4200,
      'duration': 238,
      'is_liked': true,
    },
    {
      'id': 'track-002',
      'title': 'Alexandria Waves',
      'user': {'display_name': 'Mohammed Al Abasy'},
      'artwork_url': null,
      'play_count': 1800,
      'duration': 195,
      'is_liked': true,
    },
    {
      'id': 'track-003',
      'title': 'Free Palestine',
      'user': {'display_name': 'Rana Elgharabawy'},
      'artwork_url': null,
      'play_count': 9900,
      'duration': 312,
      'is_liked': true,
    },
    {
      'id': 'track-004',
      'title': 'Midnight Cat',
      'user': {'display_name': '~H'},
      'artwork_url': null,
      'play_count': 560,
      'duration': 174,
      'is_liked': true,
    },
    {
      'id': 'track-005',
      'title': 'Coffee at 3am',
      'user': {'display_name': '~sohaila'},
      'artwork_url': null,
      'play_count': 2300,
      'duration': 221,
      'is_liked': true,
    },
    {
      'id': 'track-006',
      'title': 'Basslines from Giza',
      'user': {'display_name': 'KarimWI'},
      'artwork_url': null,
      'play_count': 1200,
      'duration': 275,
      'is_liked': true,
    },
    {
      'id': 'track-007',
      'title': 'Desert Echo',
      'user': {'display_name': 'Bassel Alaa'},
      'artwork_url': null,
      'play_count': 3400,
      'duration': 198,
      'is_liked': true,
    },
    {
      'id': 'track-008',
      'title': 'Nile Flow',
      'user': {'display_name': 'Mohammed Al Abasy'},
      'artwork_url': null,
      'play_count': 7800,
      'duration': 263,
      'is_liked': true,
    },
    {
      'id': 'track-009',
      'title': 'Rooftop Sessions',
      'user': {'display_name': 'Rana Elgharabawy'},
      'artwork_url': null,
      'play_count': 4500,
      'duration': 187,
      'is_liked': true,
    },
    {
      'id': 'track-010',
      'title': 'Lost Signal',
      'user': {'display_name': '~H'},
      'artwork_url': null,
      'play_count': 890,
      'duration': 244,
      'is_liked': true,
    },
  ];

  // ── Current profile state ─────────────────────────────────────────────
  static Map<String, dynamic>? _currentUserProfile;

  // Called by profile provider when user logs in
  static void setCurrentUser(String userId) {
    _currentUserProfile = Map.from(
      _mockProfiles.firstWhere(
        (p) => p['id'] == userId,
        orElse: () => _mockProfiles[0],
      ),
    );
  }

  // ── Helper ────────────────────────────────────────────────────────────
  Map<String, dynamic> _getProfileById(String userId) {
    if (userId == 'me' ||
        userId == (_currentUserProfile?['id'] ?? 'user-001')) {
      return _currentUserProfile ?? Map.from(_mockProfiles[0]);
    }
    return _mockProfiles.firstWhere(
      (p) => p['id'] == userId,
      orElse: () => throw Exception('PROFILE_NOT_FOUND'),
    );
  }

  // ── Methods ───────────────────────────────────────────────────────────
  @override
  Future<ProfileModel> getProfile({required String userId}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final profile = _getProfileById(userId);
    return ProfileModel.fromJson(profile);
  }

  @override
  Future<ProfileModel> updateProfile({
    required String displayName,
    required String city,
    required String country,
    required String bio,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    if (displayName.trim().isEmpty) {
      throw Exception('VALIDATION_FAILED: display name cannot be empty');
    }

    _currentUserProfile = {
      ...(_currentUserProfile ?? Map.from(_mockProfiles[0])),
      'display_name': displayName,
      'city': city,
      'country': country,
      'bio': bio,
    };

    return ProfileModel.fromJson(_currentUserProfile!);
  }

  @override
  Future<ProfileModel> uploadAvatar({required String filePath}) async {
    await Future.delayed(const Duration(seconds: 2));

    _currentUserProfile = {
      ...(_currentUserProfile ?? Map.from(_mockProfiles[0])),
      'avatar_url':
          'https://mock-cdn.rythmify.com/avatars/${_currentUserProfile?['id']}-${DateTime.now().millisecondsSinceEpoch}.jpg',
    };

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
          'https://mock-cdn.rythmify.com/covers/${_currentUserProfile?['id']}-${DateTime.now().millisecondsSinceEpoch}.jpg',
    };

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
  Future<List<TrackModel>> getLikedTracks({
    required String userId,
    required int page,
    required int limit,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final start = (page - 1) * limit;
    final end = min(start + limit, _mockTracks.length);

    if (start >= _mockTracks.length) return [];

    return _mockTracks
        .sublist(start, end)
        .map((t) => TrackModel.fromJson(Map<String, dynamic>.from(t)))
        .toList();
  }
}