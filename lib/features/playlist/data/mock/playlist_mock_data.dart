// ============================================================
// PLAYLIST MOCK DATA
// ============================================================
// This file is our fake "backend" for development.
// When useMock = true in the provider, everything reads from here.
// No internet needed. Replace with real API calls later.
// ============================================================

import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/playlist_track.dart';

class PlaylistMockData {
  // ── Singleton so the same "database" is shared everywhere ──
  PlaylistMockData._();
  static final PlaylistMockData instance = PlaylistMockData._();

  // ── The in-memory list of playlists ────────────────────────
  // This mirrors what Image 6 (the Library playlists screen) shows.
  final List<PlaylistEntity> _playlists = [
    PlaylistEntity(
      id: 'pl-001',
      name: 'Untitled playlist',
      ownerName: 'Hana',
      ownerId: 'user-001',
      isPublic: true,
      type: PlaylistType.playlist,
      trackCount: 1,
      totalDuration: const Duration(minutes: 3, seconds: 44),
      coverUrl: null,
      createdAt: DateTime(2026, 3, 1),
    ),
    PlaylistEntity(
      id: 'pl-002',
      name: 'Hi',
      ownerName: 'Hana',
      ownerId: 'user-001',
      isPublic: true,
      type: PlaylistType.playlist,
      trackCount: 3,
      totalDuration: const Duration(minutes: 9, seconds: 25),
      coverUrl: null,
      createdAt: DateTime(2026, 2, 20),
    ),
    PlaylistEntity(
      id: 'pl-003',
      name: 'Lowkey House',
      ownerName: 'Discovery Playlists',
      ownerId: 'user-999',
      isPublic: true,
      type: PlaylistType.playlist,
      trackCount: 158,
      totalDuration: const Duration(hours: 11, minutes: 4, seconds: 23),
      coverUrl: null,
      createdAt: DateTime(2026, 1, 10),
    ),
  ];

  // ── Tracks inside each playlist ──
  // Key = playlist id, value = list of tracks in that playlist.
  final Map<String, List<PlaylistTrack>> _playlistTracks = {
    'pl-001': [
      PlaylistTrack(
        id: 'tr-001',
        title: "We Can't Be Friends",
        artistName: 'Ariana Grande',
        duration: const Duration(minutes: 3, seconds: 44),
        coverUrl: null,
        playCount: 23200,
        position: 1,
      ),
    ],
    'pl-002': [
      PlaylistTrack(
        id: 'tr-002',
        title: 'Sonic Mine - Drugs (Remix T...)',
        artistName: 'QWXNTUM',
        duration: const Duration(minutes: 2, seconds: 53),
        coverUrl: null,
        playCount: 1900000,
        position: 1,
      ),
      PlaylistTrack(
        id: 'tr-003',
        title: "Chosin' Texas",
        artistName: 'Alanna Iman',
        duration: const Duration(seconds: 35),
        coverUrl: null,
        playCount: 37100,
        position: 2,
      ),
      PlaylistTrack(
        id: 'tr-004',
        title: 'YUKON',
        artistName: 'Justin Bieber',
        duration: const Duration(minutes: 3, seconds: 7),
        coverUrl: null,
        playCount: 0,
        position: 3,
        isUnavailable: true,
      ),
    ],
  };

  // ── Suggestion tracks (shown on empty/new playlist) ──
  // These are shown in Images 1 & 2 as "Suggestions for your new playlist"
  final List<PlaylistTrack> _suggestions = [
    PlaylistTrack(
      id: 'sg-001',
      title: 'Birds Of A Feather (Hor...',
      artistName: 'Horacio Payan',
      duration: const Duration(minutes: 3, seconds: 31),
      coverUrl: null,
      playCount: 99000,
      position: 0,
      isLiked: true,
    ),
    PlaylistTrack(
      id: 'sg-002',
      title: 'Notion',
      artistName: 'The Rare Occasions',
      duration: const Duration(minutes: 3, seconds: 0),
      coverUrl: null,
      playCount: 0,
      position: 0,
      isUnavailable: true,
    ),
    PlaylistTrack(
      id: 'sg-003',
      title: 'Lesley Gore - Misty SLOWED VER',
      artistName: '',
      duration: const Duration(minutes: 3, seconds: 4),
      coverUrl: null,
      playCount: 43800,
      position: 0,
    ),
    PlaylistTrack(
      id: 'sg-004',
      title: 'Wine Pon You - Doja Cat (sped up + r...',
      artistName: 'Doja Cat',
      duration: const Duration(minutes: 3, seconds: 22),
      coverUrl: null,
      playCount: 7000000,
      position: 0,
      isLiked: true,
    ),
    PlaylistTrack(
      id: 'sg-005',
      title: "Ariana Grande - We Can't Be Friends...",
      artistName: 'Ariana Grande',
      duration: const Duration(minutes: 3, seconds: 44),
      coverUrl: null,
      playCount: 23200,
      position: 0,
    ),
  ];

  // ════════════════════════════════════════════════════════════
  // READ OPERATIONS
  // ════════════════════════════════════════════════════════════

  /// Returns all playlists for the current user.
  /// This is what the Library screen shows.
  List<PlaylistEntity> getMyPlaylists() => List.from(_playlists);

  /// Returns the tracks inside one playlist.
  List<PlaylistTrack> getTracksFor(String playlistId) =>
      List.from(_playlistTracks[playlistId] ?? []);

  /// Returns suggestion tracks for adding to a playlist.
  /// In the real app these come from the backend based on listening history.
  List<PlaylistTrack> getSuggestions() => List.from(_suggestions);

  PlaylistEntity? getById(String id) {
    try {
      return _playlists.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // ════════════════════════════════════════════════════════════
  // WRITE OPERATIONS — these mutate the in-memory list
  // ════════════════════════════════════════════════════════════

  /// Creates a new playlist and adds it to the top of the list.
  PlaylistEntity create({required String name, required bool isPublic}) {
    final newPlaylist = PlaylistEntity(
      id: 'pl-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      ownerName: 'Hana', // replace with real user name later
      ownerId: 'user-001',
      isPublic: isPublic,
      type: PlaylistType.playlist,
      trackCount: 0,
      totalDuration: Duration.zero,
      coverUrl: null,
      createdAt: DateTime.now(),
    );
    // Insert at position 0 so it appears at the top of the list.
    _playlists.insert(0, newPlaylist);
    _playlistTracks[newPlaylist.id] = [];
    // Print to debug console so you can verify it worked.
    // ignore: avoid_print
    print('[MockDB] Created playlist: ${newPlaylist.name} (${newPlaylist.id})');
    return newPlaylist;
  }

  /// Renames a playlist and toggles its public/private state.
  void update({
    required String playlistId,
    required String name,
    required bool isPublic,
    String? description,
  }) {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return;
    _playlists[index] = _playlists[index].copyWith(
      name: name,
      isPublic: isPublic,
      description: description,
    );
    // ignore: avoid_print
    print('[MockDB] Updated playlist $playlistId → name=$name');
  }

  /// Deletes a playlist permanently.
  void delete(String playlistId) {
    _playlists.removeWhere((p) => p.id == playlistId);
    _playlistTracks.remove(playlistId);
    // ignore: avoid_print
    print('[MockDB] Deleted playlist $playlistId');
  }

  /// Adds a suggestion track into a playlist.
  void addTrack({required String playlistId, required PlaylistTrack track}) {
    final tracks = _playlistTracks[playlistId] ?? [];
    // Don't add duplicates.
    if (tracks.any((t) => t.id == track.id)) return;
    final withNewPosition = track.copyWith(position: tracks.length + 1);
    tracks.add(withNewPosition);
    _playlistTracks[playlistId] = tracks;
    // Update the track count on the playlist entity.
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      _playlists[index] = _playlists[index].copyWith(
        trackCount: tracks.length,
        totalDuration: _recalcDuration(tracks),
      );
    }
    // Remove this track from suggestions so it doesn't appear twice.
    _suggestions.removeWhere((s) => s.id == track.id);
    // ignore: avoid_print
    print('[MockDB] Added track ${track.title} to playlist $playlistId');
  }

  /// Removes a track from a playlist.
  void removeTrack({required String playlistId, required String trackId}) {
    final tracks = _playlistTracks[playlistId] ?? [];
    tracks.removeWhere((t) => t.id == trackId);
    // Re-number positions after removal.
    for (int i = 0; i < tracks.length; i++) {
      tracks[i] = tracks[i].copyWith(position: i + 1);
    }
    _playlistTracks[playlistId] = tracks;
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      _playlists[index] = _playlists[index].copyWith(
        trackCount: tracks.length,
        totalDuration: _recalcDuration(tracks),
      );
    }
  }

  Duration _recalcDuration(List<PlaylistTrack> tracks) =>
      tracks.fold(Duration.zero, (sum, t) => sum + t.duration);

  // ── Station creation ──────────────────────────────────────────
  // When user long-presses a track and taps "Start station", we create
  // a special playlist with type = station seeded from that track.
  PlaylistEntity createStation({required PlaylistTrack seedTrack}) {
    final station = PlaylistEntity(
      id: 'st-${DateTime.now().millisecondsSinceEpoch}',
      name: '${seedTrack.artistName} Radio',
      ownerName: 'Hana',
      ownerId: 'user-001',
      isPublic: false,
      type: PlaylistType.station,
      trackCount: 48,
      totalDuration: const Duration(hours: 2, minutes: 30),
      coverUrl: seedTrack.coverUrl,
      createdAt: DateTime.now(),
      seedTrackTitle: seedTrack.title,
      seedArtistName: seedTrack.artistName,
    );
    _playlists.insert(0, station);
    // For mock: fill with shuffled suggestions repeated to get 48 tracks.
    final fakeTracks = List.generate(
      48,
      (i) => _suggestions[i % _suggestions.length].copyWith(position: i + 1),
    );
    _playlistTracks[station.id] = fakeTracks;
    return station;
  }
}