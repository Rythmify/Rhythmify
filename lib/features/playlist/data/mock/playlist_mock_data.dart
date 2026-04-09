// lib/features/playlist/data/mock/playlist_mock_data.dart
//
// In-memory fake database. All playlist/album/station CRUD goes here.
// When backend is ready, replace each method body with a real API call.

import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/playlist_track.dart';

class PlaylistMockData {
  PlaylistMockData._();
  static final PlaylistMockData instance = PlaylistMockData._();

  // ── In-memory playlist list ────────────────────────────────────────────────
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
    // Example album — shows "2026 · Album" in the header (Image 1 style)
    PlaylistEntity(
      id: 'al-001',
      name: 'Lost, Found & Forgotten',
      ownerName: 'Chris Stussy',
      ownerId: 'user-002',
      isPublic: true,
      type: PlaylistType.album,
      trackCount: 6,
      totalDuration: const Duration(minutes: 22, seconds: 10),
      coverUrl: null,
      createdAt: DateTime(2026, 1, 1),
      releaseYear: '2026',
    ),
    // Example station — shows "Artist Station · ... · 50 tracks" (Image 2 style)
    PlaylistEntity(
      id: 'st-001',
      name: 'HanaRadio',
      ownerName: 'Hana',
      ownerId: 'user-003',
      isPublic: false,
      type: PlaylistType.station,
      trackCount: 50,
      totalDuration: const Duration(hours: 2, minutes: 27, seconds: 8),
      coverUrl: null,
      createdAt: DateTime(2026, 3, 10),
      seedArtistName: 'Hana',
    ),
  ];

  // ── Tracks per playlist ────────────────────────────────────────────────────
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
        title: 'Sonic Mine - Drugs (Remix)',
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
    // Album tracks — matching Image 1's track list
    'al-001': [
      PlaylistTrack(
        id: 'al-tr-001',
        title: 'Moonlight',
        artistName: 'Chris Stussy, Elena Moroder',
        duration: const Duration(minutes: 4, seconds: 10),
        coverUrl: null,
        playCount: 0,
        position: 1,
        isUnavailable: true,
      ),
      PlaylistTrack(
        id: 'al-tr-002',
        title: 'Side to Side',
        artistName: 'Chris Stussy',
        duration: const Duration(minutes: 3, seconds: 50),
        coverUrl: null,
        playCount: 0,
        position: 2,
        isUnavailable: true,
      ),
      PlaylistTrack(
        id: 'al-tr-003',
        title: 'Here for the summer',
        artistName: 'Chris Stussy',
        duration: const Duration(minutes: 3, seconds: 55),
        coverUrl: null,
        playCount: 0,
        position: 3,
        isUnavailable: true,
      ),
      PlaylistTrack(
        id: 'al-tr-004',
        title: 'Tryna find a way',
        artistName: 'Chris Stussy, Leanne Louise',
        duration: const Duration(minutes: 4, seconds: 5),
        coverUrl: null,
        playCount: 0,
        position: 4,
        isUnavailable: true,
      ),
      PlaylistTrack(
        id: 'al-tr-005',
        title: 'Linger (Interlude)',
        artistName: 'Chris Stussy',
        duration: const Duration(minutes: 2, seconds: 30),
        coverUrl: null,
        playCount: 0,
        position: 5,
        isUnavailable: true,
      ),
      PlaylistTrack(
        id: 'al-tr-006',
        title: 'Darkness',
        artistName: 'Chris Stussy',
        duration: const Duration(minutes: 3, seconds: 40),
        coverUrl: null,
        playCount: 0,
        position: 6,
        isUnavailable: true,
      ),
    ],
  };

  // ── Suggestion tracks ──────────────────────────────────────────────────────
  final List<PlaylistTrack> _suggestions = [
    PlaylistTrack(
      id: 'sg-001',
      title: 'Birds Of A Feather (Remix)',
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
      title: 'Wine Pon You - Doja Cat (sped up)',
      artistName: 'Doja Cat',
      duration: const Duration(minutes: 3, seconds: 22),
      coverUrl: null,
      playCount: 7000000,
      position: 0,
      isLiked: true,
    ),
    PlaylistTrack(
      id: 'sg-005',
      title: "We Can't Be Friends",
      artistName: 'Ariana Grande',
      duration: const Duration(minutes: 3, seconds: 44),
      coverUrl: null,
      playCount: 23200,
      position: 0,
    ),
  ];

  // ════════════════════════════════════════════════════════════════════════════
  // READ
  // ════════════════════════════════════════════════════════════════════════════

  /// All playlists — used by Library playlists screen.
  List<PlaylistEntity> getMyPlaylists() => List.from(_playlists);

  /// Only type == album — used by Library albums section.
  List<PlaylistEntity> getAlbums() =>
      _playlists.where((p) => p.type == PlaylistType.album).toList();

  /// Only type == station — used by Library stations section.
  List<PlaylistEntity> getStations() =>
      _playlists.where((p) => p.type == PlaylistType.station).toList();

  List<PlaylistTrack> getTracksFor(String playlistId) =>
      List.from(_playlistTracks[playlistId] ?? []);

  List<PlaylistTrack> getSuggestions() => List.from(_suggestions);

  PlaylistEntity? getById(String id) {
    try {
      return _playlists.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // WRITE — playlist CRUD
  // ════════════════════════════════════════════════════════════════════════════

  PlaylistEntity create({required String name, required bool isPublic}) {
    final newPlaylist = PlaylistEntity(
      id: 'pl-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      ownerName: 'Hana',
      ownerId: 'user-001',
      isPublic: isPublic,
      type: PlaylistType.playlist,
      trackCount: 0,
      totalDuration: Duration.zero,
      coverUrl: null,
      createdAt: DateTime.now(),
    );
    _playlists.insert(0, newPlaylist);
    _playlistTracks[newPlaylist.id] = [];
    // ignore: avoid_print
    print('[MockDB] Created playlist: ${newPlaylist.name} (${newPlaylist.id})');
    return newPlaylist;
  }

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

  void updateCoverImage({
    required String playlistId,
    required String localPath,
  }) {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return;
    _playlists[index] = _playlists[index].copyWith(coverUrl: localPath);
  }

  void delete(String playlistId) {
    _playlists.removeWhere((p) => p.id == playlistId);
    _playlistTracks.remove(playlistId);
    // ignore: avoid_print
    print('[MockDB] Deleted playlist $playlistId');
  }

  // ════════════════════════════════════════════════════════════════════════════
  // CONVERT — this is what "Convert to Album / Station" in the edit sheet does
  // ════════════════════════════════════════════════════════════════════════════

  /// Converts a playlist to an album.
  /// Called when user taps "Convert to Album" in the Edit sheet.
  /// The playlist keeps all its tracks — only the type and releaseYear change.
  PlaylistEntity convertToAlbum(String playlistId) {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return _playlists.first;

    final updated = _playlists[index].copyWith(
      type: PlaylistType.album,
      releaseYear: DateTime.now().year.toString(),
    );
    _playlists[index] = updated;
    // ignore: avoid_print
    print('[MockDB] Converted $playlistId to album');
    return updated;
  }

  /// Converts a playlist to a station.
  /// Called when user taps "Convert to Station" in the Edit sheet.
  /// seedArtistName defaults to the owner's name.
  PlaylistEntity convertToStation(String playlistId) {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return _playlists.first;

    final updated = _playlists[index].copyWith(
      type: PlaylistType.station,
      seedArtistName: _playlists[index].ownerName,
    );
    _playlists[index] = updated;
    // ignore: avoid_print
    print('[MockDB] Converted $playlistId to station');
    return updated;
  }

  /// Converts an album or station back to a regular playlist.
  PlaylistEntity convertToPlaylist(String playlistId) {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return _playlists.first;

    final updated = _playlists[index].copyWith(type: PlaylistType.playlist);
    _playlists[index] = updated;
    // ignore: avoid_print
    print('[MockDB] Converted $playlistId to playlist');
    return updated;
  }

  // ════════════════════════════════════════════════════════════════════════════
  // TRACK MANAGEMENT
  // ════════════════════════════════════════════════════════════════════════════

  void addTrack({required String playlistId, required PlaylistTrack track}) {
    final tracks = _playlistTracks[playlistId] ?? [];
    if (tracks.any((t) => t.id == track.id)) return;
    tracks.add(track.copyWith(position: tracks.length + 1));
    _playlistTracks[playlistId] = tracks;
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      _playlists[index] = _playlists[index].copyWith(
        trackCount: tracks.length,
        totalDuration: _recalcDuration(tracks),
      );
    }
    _suggestions.removeWhere((s) => s.id == track.id);
    // ignore: avoid_print
    print('[MockDB] Added track ${track.title} to $playlistId');
  }

  void removeTrack({required String playlistId, required String trackId}) {
    final tracks = _playlistTracks[playlistId] ?? [];
    tracks.removeWhere((t) => t.id == trackId);
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

  // ════════════════════════════════════════════════════════════════════════════
  // STATION CREATION (from track ··· menu → Start station)
  // ════════════════════════════════════════════════════════════════════════════

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
      seedArtistName: seedTrack.artistName,
    );
    _playlists.insert(0, station);
    final fakeTracks = List.generate(
      48,
      (i) => _suggestions[i % _suggestions.length].copyWith(position: i + 1),
    );
    _playlistTracks[station.id] = fakeTracks;
    // ignore: avoid_print
    print('[MockDB] Created station: ${station.name}');
    return station;
  }
}
