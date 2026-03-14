import '../../../../core/data/models/track_summary_dto.dart';
import '../../../../core/domain/entities/track_summary.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class HomeDatasource {
  Future<List<TrackSummary>> getTrendingTracks(String genre) async {
    final String jsonString = await rootBundle.loadString(
      'assets/mocks/tracks_summary.json',
    );

    final List<dynamic> jsonList = json.decode(jsonString);

    final tracks = jsonList
        .map((json) => TrackSummaryDto.fromJson(json))
        .toList();

    // since mock JSON has no genre field yet,
    // we just return all tracks for now
    return tracks;
  }

  Future<List<TrackSummary>> getHotTracks() async {
    final String jsonString = await rootBundle.loadString(
      'assets/mocks/tracks_summary.json',
    );

    final List<dynamic> jsonList = json.decode(jsonString);

    return jsonList.map((json) => TrackSummaryDto.fromJson(json)).toList();
  }
}
