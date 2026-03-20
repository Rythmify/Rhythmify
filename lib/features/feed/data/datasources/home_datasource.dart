import '../../../../core/data/models/track_dto.dart';
import '../../../../core/domain/entities/track.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class HomeDatasource {
  Future<List<Track>> getTrendingTracks(String genre) async {
    final String jsonString = await rootBundle.loadString(
      'assets/mocks/tracks_summary.json',
    );

    final List<dynamic> jsonList = json.decode(jsonString);

    final tracks = jsonList
        .map((json) => TrackDto.fromJson(json))
        .toList();

    // since mock JSON has no genre field yet,
    // we just return all tracks for now
    return tracks;
  }

  Future<List<Track>> getHotTracks() async {
    final String jsonString = await rootBundle.loadString(
      'assets/mocks/tracks_summary.json',
    );

    final List<dynamic> jsonList = json.decode(jsonString);

    return jsonList.map((json) => TrackDto.fromJson(json)).toList();
  }

  Future<List<Map<String, dynamic>>> getMixedPlaylists() async {
    return [
      {
        "mixLabel": "MIX 1",
        "image": "assets/images/track_6.jpg",
        "artists": " artist1",
      },
      {
        "mixLabel": "MIX 2",
        "image": "assets/images/track_6.jpg",
        "artists": " artist2",
      },
      {
        "mixLabel": "MIX 3",
        "image": "assets/images/track_6.jpg",
        "artists": " artist3",
      },
      {
        "mixLabel": "MIX 4",
        "image": "assets/images/track_6.jpg",
        "artists": " artist4",
      },
      {
        "mixLabel": "MIX 5",
        "image": "assets/images/track_6.jpg",
        "artists": " artist5",
      },
      {
        "mixLabel": "MIX 6",
        "image": "assets/images/track_6.jpg",
        "artists": " artist6",
      },
      {
        "mixLabel": "MIX 7",
        "image": "assets/images/track_6.jpg",
        "artists": " artist7",
      },
      {
        "mixLabel": "MIX 8",
        "image": "assets/images/track_6.jpg",
        "artists": " artist8",
      },
    ];
  }

  Future<List<Map<String, dynamic>>> getStationPlaylists() async {
    return [
      {
        "image": "https://picsum.photos/seed/techno2/300/300",
        "artists": " artist1",
      },
      {
        "image": "https://picsum.photos/seed/techno2/300/300",
        "artists": " artist2",
      },
      {
        "image": "https://picsum.photos/seed/techno2/300/300",
        "artists": " artist3",
      },
      {
        "image": "https://picsum.photos/seed/techno2/300/300",
        "artists": " artist4",
      },
      {
        "image": "https://picsum.photos/seed/techno2/300/300",
        "artists": " artist5",
      },
      {
        "image": "https://picsum.photos/seed/techno2/300/300",
        "artists": " artist6",
      },
      {
        "image": "https://picsum.photos/seed/techno2/300/300",
        "artists": " artist7",
      },
      {
        "image": "https://picsum.photos/seed/techno2/300/300",
        "artists": " artist8",
      },
    ];
  }

  Future<List<Map<String, dynamic>>> getMoreOfWhatYouLikePlaylists() async {
    return [
      {
        "image": "https://picsum.photos/seed/techno2/300/300",
        "artists": " artist1",
      },
      {
        "image": "https://picsum.photos/seed/techno2/300/300",
        "artists": " artist2",
      },
      {
        "image": "https://picsum.photos/seed/techno2/300/300",
        "artists": " artist3",
      },
      {
        "image": "https://picsum.photos/seed/techno2/300/300",
        "artists": " artist4",
      },
      {
        "image": "https://picsum.photos/seed/techno2/300/300",
        "artists": " artist5",
      },
      {
        "image": "https://picsum.photos/seed/techno2/300/300",
        "artists": " artist6",
      },
      {
        "image": "https://picsum.photos/seed/techno2/300/300",
        "artists": " artist7",
      },
      {
        "image": "https://picsum.photos/seed/techno2/300/300",
        "artists": " artist8",
      },
    ];
  }
}
