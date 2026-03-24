import '../../../../core/data/models/track_dto.dart';
import '../../../../core/domain/entities/track.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

/// Data source responsible for fetching home screen data.
///
/// This class acts as a **local/mock data provider** for:
/// - Trending tracks
/// - Hot tracks
/// - Mixed playlists
/// - Station playlists
/// - Personalized recommendations
///
/// Currently, data is loaded from local JSON assets or hardcoded lists.
/// In the future, this can be replaced with API calls.
class HomeDatasource {
  /// Fetches trending tracks for a given [genre].
  ///
  /// Since the current mock JSON does not include genre filtering,
  /// this method returns all available tracks.
  ///
  /// Returns a list of [Track] objects parsed from local JSON.
  Future<List<Track>> getTrendingTracks(String genre) async {
    final String jsonString = await rootBundle.loadString(
      'assets/mocks/tracks_summary.json',
    );

    final List<dynamic> jsonList = json.decode(jsonString);

    final tracks = jsonList.map((json) => TrackDto.fromJson(json)).toList();

    // TODO: Filter tracks by genre when backend supports it
    return tracks;
  }

  /// Fetches tracks for the "Hot For You" section.
  ///
  /// Currently returns all tracks from the mock JSON file.
  ///
  /// Returns a [Track] object.
  Future<List<Track>> getHotTracks() async {
    final String jsonString = await rootBundle.loadString(
      'assets/mocks/tracks_summary.json',
    );

    final List<dynamic> jsonList = json.decode(jsonString);

    return jsonList.map((json) => TrackDto.fromJson(json)).toList();
  }

  /// Fetches "Mixed For You" playlists.
  ///
  /// Each playlist contains:
  /// - `mixLabel`: Label displayed on the card (e.g., MIX 1)
  /// - `image`: Path to playlist artwork
  /// - `artists`: Artists included in the mix
  ///
  /// Returns a list of maps representing playlist metadata.
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

  /// Fetches "Discover with Stations" playlists.
  ///
  /// Each station contains:
  /// - `image`: Artwork representing the station
  /// - `artists`: Artist(s) the station is based on
  ///
  /// Returns a list of maps used to render station cards.
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

  /// Fetches "More of What You Like" playlists.
  ///
  /// Each playlist contains:
  /// - `image`: Artwork for the playlist
  /// - `artists`: Artists featured in the playlist
  ///
  /// Returns a list of maps used to render recommendation cards.
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
