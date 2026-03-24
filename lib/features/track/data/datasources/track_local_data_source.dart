import 'dart:convert';
import 'package:flutter/services.dart';

/// This file is faking the internet fetching for apis json results
/// and then hands it to the repository

abstract class TrackLocalDataSource {
  Future<List<dynamic>> getSummaryTracks();

  Future<List<dynamic>> getFullTracks();

  Future<Map<String, dynamic>> getWaveform(String id);

  Future<Map<String, dynamic>> getTags();
}

class TrackLocalDataSourceImpl implements TrackLocalDataSource {
  static const String _summaryJsonPath = 'assets/mocks/tracks_summary.json';
  //static const String _fullJsonPath = 'assets/mocks/tracks_full.json';

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
    // Simulating API response provided by user
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
    // Simulating API response provided by user
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
