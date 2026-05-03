import 'dart:convert';
import 'package:flutter/services.dart';

/// [TrackLocalDataSource] defines the interface for local track data operations.
///
/// This data source is primarily used for mocking and offline capabilities,
/// fetching data from local JSON assets or simulated local storage.
abstract class TrackLocalDataSource {
  /// Fetches summary track data from a local JSON mock.
  Future<List<dynamic>> getSummaryTracks();

  /// Fetches full track data from a local JSON mock.
  Future<List<dynamic>> getFullTracks();

  /// Simulates fetching waveform peak data for a track.
  Future<Map<String, dynamic>> getWaveform(String id);

  /// Simulates fetching tag data.
  Future<Map<String, dynamic>> getTags();
}

/// [TrackLocalDataSourceImpl] is the implementation of [TrackLocalDataSource].
///
/// It uses the [rootBundle] to load mock data from assets.
class TrackLocalDataSourceImpl implements TrackLocalDataSource {
  static const String _summaryJsonPath = 'assets/mocks/tracks_summary.json';

  @override
  Future<List<dynamic>> getSummaryTracks() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final jsonString = await rootBundle.loadString(_summaryJsonPath);
    return jsonDecode(jsonString) as List<dynamic>;
  }

  @override
  Future<List<dynamic>> getFullTracks() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final jsonString = await rootBundle.loadString(_summaryJsonPath);
    return jsonDecode(jsonString) as List<dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getWaveform(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      "data": {
        "track_id": id,
        "peaks": [0, 0.12, 0.45, 0.78, 1, 0.63, 0.29, 0.05, 0.4, 0.8, 0.3, 0.1],
      },
    };
  }

  @override
  Future<Map<String, dynamic>> getTags() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return {
      "data": {
        "items": [
          {"id": "aaa11111-bbbb-cccc-dddd-eeeeeeeeeeee", "name": "chill"},
          {"id": "bbb22222-cccc-dddd-eeee-ffffffffffff", "name": "electronic"},
        ],
      },
      "message": "Tags fetched successfully.",
    };
  }
}
