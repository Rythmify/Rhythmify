import '../../domain/entities/collection_type.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/playlist_track_item.dart';

/// In-memory mock store for M14 development.
///
/// Mirrors [UploadMockStore] from M13. When [PlaylistRepositoryImpl.useMock]
/// is `true`, all CRUD routes through here instead of the real API.
///
/// All mutations print to the DEBUG CONSOLE so the team can verify state
/// during integration testing without a running backend.
class PlaylistMockStore {
  final List<PlaylistEntity> _playlists = [
    // Seed data so Library/Feed have content to display immediately.
    PlaylistEntity(
      id: 'mock-playlist-001',
      ownerUserId: 'mock-user-001',
      name: 'Gym Mix',
      slug: 'gym-mix',
      isPublic: true,
      collectionType: CollectionType.playlist,
      trackCount: 12,
      likeCount: 34,
      repostCount: 5,
      createdAt: DateTime(2026, 3, 1),
      description: 'High energy workout tracks',
    ),
    PlaylistEntity(
      id: 'mock-album-001',
      ownerUserId: 'mock-user-001',
      name: 'Summer EP',
      slug: 'summer-ep',
      isPublic: true,
      collectionType: CollectionType.album,
      trackCount: 6,
      likeCount: 120,
      repostCount: 15,
      createdAt: DateTime(2026, 2, 15),
      releaseDate: '2026-02-15',
    ),
  ];

  final Map<String, List<PlaylistTrackItem>> _tracks = {};

  // ── Read ──────────────────────────────────────────────────────────────────

  List<PlaylistEntity> getAll() => List.unmodifiable(_playlists);

  PlaylistEntity? getById(String id) {
    try {
      return _playlists.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<PlaylistTrackItem> getTracks(String playlistId) {
    return _tracks[playlistId] ?? [];
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  PlaylistEntity create({
    required String name,
    required bool isPublic,
    required CollectionType type,
  }) {
    final entity = PlaylistEntity(
      id: 'mock-${DateTime.now().millisecondsSinceEpoch}',
      ownerUserId: 'mock-user-001',
      name: name,
      slug: name.toLowerCase().replaceAll(' ', '-'),
      isPublic: isPublic,
      collectionType: type,
      trackCount: 0,
      likeCount: 0,
      repostCount: 0,
      createdAt: DateTime.now(),
    );
    _playlists.insert(0, entity);
    // ignore: avoid_print
    print('[M14 MockStore] Created ${type.name}: $name (id=${entity.id})');
    return entity;
  }

  PlaylistEntity update({
    required String playlistId,
    String? name,
    bool? isPublic,
  }) {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) {
      throw Exception('Playlist $playlistId not found in mock store');
    }
    final updated = _playlists[index].copyWith(
      name: name,
      isPublic: isPublic,
    );
    _playlists[index] = updated;
    // ignore: avoid_print
    print('[M14 MockStore] Updated playlist $playlistId → name=$name');
    return updated;
  }

  void delete(String playlistId) {
    _playlists.removeWhere((p) => p.id == playlistId);
    _tracks.remove(playlistId);
    // ignore: avoid_print
    print('[M14 MockStore] Deleted playlist $playlistId');
  }
}