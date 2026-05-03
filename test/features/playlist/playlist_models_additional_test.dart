import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/playlist/data/models/station_model.dart';
import 'package:rythmify/features/playlist/domain/entities/collection_type.dart';
import 'package:rythmify/features/playlist/domain/entities/playlist_entity.dart';

void main() {
  group('StationModel', () {
    test('maps a complete station response into a station playlist entity', () {
      final station = StationModel.fromJson({
        'id': 'station-1',
        'name': 'Artist Radio',
        'cover_image': 'cover.jpg',
        'track_count': 18,
        'seed_artist': {'user_id': 'artist-1', 'display_name': 'Artist Name'},
      });

      expect(station.id, 'station-1');
      expect(station.name, 'Artist Radio');
      expect(station.type, PlaylistType.station);
      expect(station.isPublic, isTrue);
      expect(station.ownerId, 'artist-1');
      expect(station.ownerName, 'Artist Name');
      expect(station.seedArtistName, 'Artist Name');
      expect(station.description, "Radio station based on Artist Name's music");
      expect(station.coverUrl, 'cover.jpg');
      expect(station.trackCount, 18);
    });

    test('uses defensive defaults for missing seed artist fields', () {
      final station = StationModel.fromJson({
        'id': 'station-2',
        'name': 'Unknown Radio',
      });

      expect(station.ownerId, '');
      expect(station.ownerName, 'Unknown Artist');
      expect(station.trackCount, 0);
      expect(station.coverUrl, isNull);
      expect(station.seedArtistName, 'Unknown Artist');
    });

    test('maps station lists without losing order', () {
      final stations = StationModel.fromJsonList([
        {
          'id': 'station-1',
          'name': 'One Radio',
          'seed_artist': {'display_name': 'One'},
        },
        {
          'id': 'station-2',
          'name': 'Two Radio',
          'seed_artist': {'display_name': 'Two'},
        },
      ]);

      expect(stations.map((s) => s.id), ['station-1', 'station-2']);
    });
  });

  group('CollectionType mapping', () {
    test('groups every album-like backend subtype as album', () {
      expect(collectionTypeFromSubtype('album'), CollectionType.album);
      expect(collectionTypeFromSubtype('ep'), CollectionType.album);
      expect(collectionTypeFromSubtype('single'), CollectionType.album);
      expect(collectionTypeFromSubtype('compilation'), CollectionType.album);
    });

    test('falls back unknown and null subtypes to playlist', () {
      expect(collectionTypeFromSubtype('playlist'), CollectionType.playlist);
      expect(collectionTypeFromSubtype('secret'), CollectionType.playlist);
      expect(collectionTypeFromSubtype(null), CollectionType.playlist);
    });

    test('serializes collection types to supported backend subtypes', () {
      expect(subtypeFromCollectionType(CollectionType.album), 'album');
      expect(subtypeFromCollectionType(CollectionType.playlist), 'playlist');
      expect(subtypeFromCollectionType(CollectionType.station), 'playlist');
    });

    test('provides user-facing labels for every collection type', () {
      expect(labelForCollectionType(CollectionType.playlist), 'Playlist');
      expect(labelForCollectionType(CollectionType.album), 'Album');
      expect(labelForCollectionType(CollectionType.station), 'Station');
    });
  });
}
