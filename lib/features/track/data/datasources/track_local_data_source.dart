import 'dart:convert';
import 'package:flutter/services.dart';

/// This file is faking the internet fetching for apis json results
/// and then hands it to the repository

abstract class TrackLocalDataSource {

  Future<List<dynamic>> getSummaryTracks();

  Future<List<dynamic>> getFullTracks();

}

class TrackLocalDataSourceImpl implements TrackLocalDataSource {
  static const String _summaryJsonPath = 'assets/mocks/tracks_summary.json';
  static const String _fullJsonPath = 'assets/mocks/tracks_full.json';

  @override
  Future<List<dynamic>> getSummaryTracks() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final jsonString = await rootBundle.loadString(_summaryJsonPath);
    return jsonDecode(jsonString) as List<dynamic>;
  }

  @override
  Future<List<dynamic>> getFullTracks() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final jsonString = await rootBundle.loadString(_fullJsonPath);
    return jsonDecode(jsonString) as List<dynamic>;
  }
}