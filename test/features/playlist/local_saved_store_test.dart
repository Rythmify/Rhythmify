import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/playlist/data/local/local_saved_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final savedAt = DateTime.utc(2024, 1, 2, 3, 4, 5);
  final store = LocalSavedStore.instance;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Saved value models', () {
    test('round-trip mix, station, and track-radio JSON', () {
      final mix = SavedMix(
        mixId: 'mix-1',
        title: 'Daily Mix',
        ownerName: 'Rythmify',
        coverUrl: 'cover.jpg',
        trackCount: 12,
        savedAt: savedAt,
      );
      final station = SavedStation(
        artistId: 'artist-1',
        artistName: 'Artist',
        stationName: 'Artist Radio',
        coverUrl: null,
        trackCount: 9,
        savedAt: savedAt,
      );
      final radio = SavedTrackRadio(
        trackId: 'track-1',
        playlistId: 'radio-playlist-1',
        title: 'More like One',
        coverUrl: 'radio.jpg',
        trackCount: 20,
        savedAt: savedAt,
      );

      expect(SavedMix.fromJson(mix.toJson()).toJson(), mix.toJson());
      expect(
        SavedStation.fromJson(station.toJson()).toJson(),
        station.toJson(),
      );
      expect(SavedTrackRadio.fromJson(radio.toJson()).toJson(), radio.toJson());
    });

    test('invalid savedAt falls back to a valid DateTime', () {
      final mix = SavedMix.fromJson({
        'mixId': 'mix-1',
        'title': 'Daily Mix',
        'ownerName': 'Rythmify',
        'coverUrl': null,
        'trackCount': null,
        'savedAt': 'not-a-date',
      });

      expect(mix.trackCount, 0);
      expect(mix.savedAt, isA<DateTime>());
    });
  });

  group('LocalSavedStore mixes', () {
    test(
      'loads empty store, saves, replaces duplicates, and removes',
      () async {
        expect(await store.getMixes(), isEmpty);
        expect(await store.isMixSaved('mix-1'), isFalse);

        await store.saveMix(
          SavedMix(
            mixId: 'mix-1',
            title: 'Daily Mix',
            ownerName: 'System',
            coverUrl: 'old.jpg',
            trackCount: 10,
            savedAt: savedAt,
          ),
        );
        await store.saveMix(
          SavedMix(
            mixId: 'mix-1',
            title: 'Updated Daily Mix',
            ownerName: 'System',
            coverUrl: 'new.jpg',
            trackCount: 15,
            savedAt: savedAt.add(const Duration(days: 1)),
          ),
        );

        final mixes = await store.getMixes();
        expect(mixes, hasLength(1));
        expect(mixes.single.title, 'Updated Daily Mix');
        expect(mixes.single.trackCount, 15);
        expect(await store.isMixSaved('mix-1'), isTrue);

        await store.removeMix('mix-1');
        expect(await store.getMixes(), isEmpty);
        expect(await store.isMixSaved('mix-1'), isFalse);
      },
    );

    test('corrupted mix JSON is treated as an empty store', () async {
      SharedPreferences.setMockInitialValues({'saved_mixes': '{bad json'});

      expect(await store.getMixes(), isEmpty);
    });
  });

  group('LocalSavedStore stations', () {
    test(
      'loads empty store, saves, replaces duplicates, and removes',
      () async {
        expect(await store.getStations(), isEmpty);
        expect(await store.isStationSaved('artist-1'), isFalse);

        await store.saveStation(
          SavedStation(
            artistId: 'artist-1',
            artistName: 'Artist',
            stationName: 'Artist Radio',
            coverUrl: null,
            trackCount: 8,
            savedAt: savedAt,
          ),
        );
        await store.saveStation(
          SavedStation(
            artistId: 'artist-1',
            artistName: 'Artist',
            stationName: 'Artist Updated Radio',
            coverUrl: 'cover.jpg',
            trackCount: 11,
            savedAt: savedAt,
          ),
        );

        final stations = await store.getStations();
        expect(stations, hasLength(1));
        expect(stations.single.stationName, 'Artist Updated Radio');
        expect(stations.single.coverUrl, 'cover.jpg');
        expect(await store.isStationSaved('artist-1'), isTrue);

        await store.removeStation('artist-1');
        expect(await store.getStations(), isEmpty);
        expect(await store.isStationSaved('artist-1'), isFalse);
      },
    );

    test('corrupted station JSON is treated as an empty store', () async {
      SharedPreferences.setMockInitialValues({'saved_stations': '[1]'});

      expect(await store.getStations(), isEmpty);
    });
  });

  group('LocalSavedStore track radios', () {
    test(
      'loads empty store, saves, replaces duplicates, maps playlist id, and removes',
      () async {
        expect(await store.getTrackRadios(), isEmpty);
        expect(await store.isTrackRadioSaved('track-1'), isFalse);
        expect(await store.trackRadioPlaylistId('track-1'), isNull);

        await store.saveTrackRadio(
          SavedTrackRadio(
            trackId: 'track-1',
            playlistId: 'radio-playlist-1',
            title: 'More like One',
            coverUrl: null,
            trackCount: 20,
            savedAt: savedAt,
          ),
        );
        await store.saveTrackRadio(
          SavedTrackRadio(
            trackId: 'track-1',
            playlistId: 'radio-playlist-2',
            title: 'More like One Updated',
            coverUrl: 'cover.jpg',
            trackCount: 21,
            savedAt: savedAt,
          ),
        );

        final radios = await store.getTrackRadios();
        expect(radios, hasLength(1));
        expect(radios.single.playlistId, 'radio-playlist-2');
        expect(await store.isTrackRadioSaved('track-1'), isTrue);
        expect(await store.trackRadioPlaylistId('track-1'), 'radio-playlist-2');

        await store.removeTrackRadio('track-1');
        expect(await store.getTrackRadios(), isEmpty);
        expect(await store.trackRadioPlaylistId('track-1'), isNull);
      },
    );

    test('corrupted track radio JSON is treated as an empty store', () async {
      SharedPreferences.setMockInitialValues({
        'saved_track_radios': jsonEncode([
          {'trackId': 'missing-required-fields'},
        ]),
      });

      expect(await store.getTrackRadios(), isEmpty);
    });
  });
}
