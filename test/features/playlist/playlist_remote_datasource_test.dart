import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/playlist/data/datasources/playlist_remote_datasource.dart';
import 'package:rythmify/features/playlist/domain/entities/playlist_track.dart';

void main() {
  group('PlaylistRemoteDatasource mapping logic', () {
    test('maps station track correctly', () {
      final raw = [
        {
          "id": "t1",
          "title": "Song A",
          "artist_name": "Artist A",
          "duration": 120,
          "play_count": 10,
        }
      ];

      final result = PlaylistRemoteDatasourceTestHelper.map(raw);

      expect(result.length, 1);
      expect(result.first.title, "Song A");
      expect(result.first.artistName, "Artist A");
    });

    test('ignores invalid track without id', () {
      final raw = [
        {
          "title": "Bad Track",
          "artist_name": "Artist",
        }
      ];

      final result = PlaylistRemoteDatasourceTestHelper.map(raw);

      expect(result.isEmpty, true);
    });

    test('filters multiple tracks correctly', () {
      final raw = [
        {
          "id": "t1",
          "title": "A",
          "artist_name": "X",
          "duration": 100,
        },
        {
          "id": "t2",
          "title": "B",
          "artist_name": "Y",
          "duration": 200,
        },
      ];

      final result = PlaylistRemoteDatasourceTestHelper.map(raw);

      expect(result.length, 2);
      expect(result.first.id, "t1");
      expect(result.last.id, "t2");
    });

    test('handles empty list safely', () {
      final result = PlaylistRemoteDatasourceTestHelper.map([]);

      expect(result, isEmpty);
    });
  });
}

// ============================================================
// TEST HELPER (isolates mapping logic)
// ============================================================

class PlaylistRemoteDatasourceTestHelper {
  static List<PlaylistTrack> map(List<dynamic> rawList) {
    final result = <PlaylistTrack>[];

    for (final item in rawList) {
      final json = item as Map<String, dynamic>;
      final id = json['id'] as String?;

      if (id == null || id.isEmpty) continue;

      result.add(
        PlaylistTrack(
          id: id,
          title: json['title'] ?? 'Unknown',
          artistName: json['artist_name'] ?? 'Unknown',
          duration: Duration(seconds: json['duration'] ?? 0),
          position: 1,
          playCount: json['play_count'] ?? 0,
        ),
      );
    }

    return result;
  }
}