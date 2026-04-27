// lib/features/playlist/data/local/local_saved_store.dart
//
// Persists liked mixes, liked stations, and liked track radios to shared_preferences.
//
// Key structure:
//   saved_mixes        → JSON list of SavedMix objects
//   saved_stations     → JSON list of SavedStation objects
//   saved_track_radios → JSON list of SavedTrackRadio objects

library;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// ── SavedMix ──────────────────────────────────────────────────────────────────
class SavedMix {
  const SavedMix({
    required this.mixId,
    required this.title,
    required this.ownerName,
    required this.coverUrl,
    required this.trackCount,
    required this.savedAt,
  });

  final String mixId;
  final String title;
  final String ownerName;
  final String? coverUrl;
  final int trackCount;
  final DateTime savedAt;

  Map<String, dynamic> toJson() => {
    'mixId': mixId,
    'title': title,
    'ownerName': ownerName,
    'coverUrl': coverUrl,
    'trackCount': trackCount,
    'savedAt': savedAt.toIso8601String(),
  };

  factory SavedMix.fromJson(Map<String, dynamic> j) => SavedMix(
    mixId: j['mixId'] as String,
    title: j['title'] as String,
    ownerName: j['ownerName'] as String,
    coverUrl: j['coverUrl'] as String?,
    trackCount: (j['trackCount'] as num?)?.toInt() ?? 0,
    savedAt: DateTime.tryParse(j['savedAt'] as String? ?? '') ?? DateTime.now(),
  );
}

// ── SavedStation ──────────────────────────────────────────────────────────────
class SavedStation {
  const SavedStation({
    required this.artistId,
    required this.artistName,
    required this.stationName,
    required this.coverUrl,
    required this.trackCount,
    required this.savedAt,
  });

  final String artistId;
  final String artistName;
  final String stationName;
  final String? coverUrl;
  final int trackCount;
  final DateTime savedAt;

  Map<String, dynamic> toJson() => {
    'artistId': artistId,
    'artistName': artistName,
    'stationName': stationName,
    'coverUrl': coverUrl,
    'trackCount': trackCount,
    'savedAt': savedAt.toIso8601String(),
  };

  factory SavedStation.fromJson(Map<String, dynamic> j) => SavedStation(
    artistId: j['artistId'] as String,
    artistName: j['artistName'] as String,
    stationName: j['stationName'] as String,
    coverUrl: j['coverUrl'] as String?,
    trackCount: (j['trackCount'] as num?)?.toInt() ?? 0,
    savedAt: DateTime.tryParse(j['savedAt'] as String? ?? '') ?? DateTime.now(),
  );
}

// ── SavedTrackRadio ───────────────────────────────────────────────────────────
// Stores the mapping returned by POST /tracks/:track_id/like-radio.
// trackId  = the seed track (used to call DELETE /tracks/:id/like-radio)
// playlistId = the playlist created on the backend (used to open the radio
//              via GET /playlists/:playlist_id/tracks or /radio-tracks)
class SavedTrackRadio {
  const SavedTrackRadio({
    required this.trackId,
    required this.playlistId,
    required this.title,
    required this.coverUrl,
    required this.trackCount,
    required this.savedAt,
  });

  final String trackId;
  final String playlistId;
  final String title;
  final String? coverUrl;
  final int trackCount;
  final DateTime savedAt;

  Map<String, dynamic> toJson() => {
    'trackId': trackId,
    'playlistId': playlistId,
    'title': title,
    'coverUrl': coverUrl,
    'trackCount': trackCount,
    'savedAt': savedAt.toIso8601String(),
  };

  factory SavedTrackRadio.fromJson(Map<String, dynamic> j) => SavedTrackRadio(
    trackId: j['trackId'] as String,
    playlistId: j['playlistId'] as String,
    title: j['title'] as String,
    coverUrl: j['coverUrl'] as String?,
    trackCount: (j['trackCount'] as num?)?.toInt() ?? 0,
    savedAt: DateTime.tryParse(j['savedAt'] as String? ?? '') ?? DateTime.now(),
  );
}

// ── Store ─────────────────────────────────────────────────────────────────────
class LocalSavedStore {
  LocalSavedStore._();
  static final LocalSavedStore instance = LocalSavedStore._();

  static const _mixKey = 'saved_mixes';
  static const _stationKey = 'saved_stations';
  static const _trackRadioKey = 'saved_track_radios';

  // ── MIXES ──────────────────────────────────────────────────────────────────

  Future<List<SavedMix>> getMixes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_mixKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => SavedMix.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> isMixSaved(String mixId) async {
    final mixes = await getMixes();
    return mixes.any((m) => m.mixId == mixId);
  }

  Future<void> saveMix(SavedMix mix) async {
    final mixes = await getMixes();
    mixes.removeWhere((m) => m.mixId == mix.mixId);
    mixes.insert(0, mix);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _mixKey,
      jsonEncode(mixes.map((m) => m.toJson()).toList()),
    );
  }

  Future<void> removeMix(String mixId) async {
    final mixes = await getMixes();
    mixes.removeWhere((m) => m.mixId == mixId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _mixKey,
      jsonEncode(mixes.map((m) => m.toJson()).toList()),
    );
  }

  // ── STATIONS ───────────────────────────────────────────────────────────────

  Future<List<SavedStation>> getStations() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_stationKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => SavedStation.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> isStationSaved(String artistId) async {
    final stations = await getStations();
    return stations.any((s) => s.artistId == artistId);
  }

  Future<void> saveStation(SavedStation station) async {
    final stations = await getStations();
    stations.removeWhere((s) => s.artistId == station.artistId);
    stations.insert(0, station);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _stationKey,
      jsonEncode(stations.map((s) => s.toJson()).toList()),
    );
  }

  Future<void> removeStation(String artistId) async {
    final stations = await getStations();
    stations.removeWhere((s) => s.artistId == artistId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _stationKey,
      jsonEncode(stations.map((s) => s.toJson()).toList()),
    );
  }

  // ── TRACK RADIOS ───────────────────────────────────────────────────────────

  Future<List<SavedTrackRadio>> getTrackRadios() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_trackRadioKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => SavedTrackRadio.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> isTrackRadioSaved(String trackId) async {
    final radios = await getTrackRadios();
    return radios.any((r) => r.trackId == trackId);
  }

  /// Returns the backend playlistId for a saved track radio, or null if not saved.
  Future<String?> trackRadioPlaylistId(String trackId) async {
    final radios = await getTrackRadios();
    try {
      return radios.firstWhere((r) => r.trackId == trackId).playlistId;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveTrackRadio(SavedTrackRadio radio) async {
    final radios = await getTrackRadios();
    radios.removeWhere((r) => r.trackId == radio.trackId);
    radios.insert(0, radio);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _trackRadioKey,
      jsonEncode(radios.map((r) => r.toJson()).toList()),
    );
  }

  Future<void> removeTrackRadio(String trackId) async {
    final radios = await getTrackRadios();
    radios.removeWhere((r) => r.trackId == trackId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _trackRadioKey,
      jsonEncode(radios.map((r) => r.toJson()).toList()),
    );
  }
}
