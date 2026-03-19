// Copyright (c) 2026
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rythmify/features/feed/presentation/pages/home_screen.dart';
import 'package:rythmify/features/feed/data/datasources/home_datasource.dart';
import 'package:rythmify/features/feed/domain/repositories/home_repository.dart';
import 'package:rythmify/features/feed/presentation/providers/home_providers.dart';
import 'package:rythmify/features/player/domain/entities/player_state.dart';
import 'package:rythmify/features/player/domain/repositories/audio_repository.dart';
import 'package:rythmify/features/player/presentation/providers/player_dependency_providers.dart';
import 'package:rythmify/core/domain/entities/track.dart';

class _FakeAudioRepository implements AudioRepository {
  const _FakeAudioRepository();

  @override
  Stream<AppPlayerState> get playerStateStream =>
      Stream.value(const AppPlayerState());

  @override
  Stream<List<Track>> get queueStream => Stream.value(const []);

  @override
  AppPlayerState get currentState => const AppPlayerState();

  @override
  List<Track> get currentQueue => const [];

  @override
  Future<void> init() async {}

  @override
  Future<void> loadQueue(List<Track> tracks, {int initialIndex = 0}) async {}

  @override
  Future<void> play() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<void> skipToNext() async {}

  @override
  Future<void> skipToPrevious() async {}

  @override
  Future<void> setShuffleMode(bool enabled) async {}

  @override
  Future<void> setLoopMode(String mode) async {}

  @override
  Future<void> updateTrackInfo(String id, Track updatedTrack) async {}
}

Track _makeTestTrack({
  String id = 'track_1',
  String title = 'Test Track',
  String artist = 'Test Artist',
  int playCount = 1200,
}) {
  return Track(
    id: id,
    userId: 'user_1',
    title: title,
    artist: artist,
    audioUrl: 'https://example.com/test.mp3',
    duration: const Duration(seconds: 100),
    createdAt: DateTime.utc(2020, 1, 1),
    coverImage: 'assets/images/track_1.jpg',
    playCount: playCount,
  );
}

class _FakeHomeDatasource extends HomeDatasource {
  final List<Track> trendingTracks;
  final List<Track> hotTracks;
  final List<Map<String, dynamic>> mixedPlaylists;
  final List<Map<String, dynamic>> stationPlaylists;
  final List<Map<String, dynamic>> moreOfWhatYouLike;

  _FakeHomeDatasource({
    required this.trendingTracks,
    required this.hotTracks,
    required this.mixedPlaylists,
    required this.stationPlaylists,
    required this.moreOfWhatYouLike,
  });

  @override
  Future<List<Track>> getTrendingTracks(String genre) async => trendingTracks;

  @override
  Future<List<Track>> getHotTracks() async => hotTracks;

  @override
  Future<List<Map<String, dynamic>>> getMixedPlaylists() async =>
      mixedPlaylists;

  @override
  Future<List<Map<String, dynamic>>> getStationPlaylists() async =>
      stationPlaylists;

  @override
  Future<List<Map<String, dynamic>>> getMoreOfWhatYouLikePlaylists() async =>
      moreOfWhatYouLike;
}

// Shared sample track across tests.
final _testTrack = _makeTestTrack();

void main() {
  late GoRouter router;

  setUp(() {
    router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/home/inbox',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Inbox'))),
        ),
        GoRoute(
          path: '/home/notifications',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Notifications'))),
        ),
        GoRoute(
          path: '/upload-track',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Upload'))),
        ),
      ],
    );
  });

  Widget buildTestApp() {
    final fakeDatasource = _FakeHomeDatasource(
      trendingTracks: [_testTrack],
      hotTracks: [_testTrack],
      mixedPlaylists: const [
        {'mixLabel': 'MIX 1', 'artists': 'artist1', 'image': ''},
      ],
      stationPlaylists: const [
        {'artists': 'station1', 'image': ''},
      ],
      moreOfWhatYouLike: const [
        {'artists': 'artist1', 'image': ''},
      ],
    );

    return ProviderScope(
      overrides: [
        // Avoid loading assets in tests.
        testAllTracksProvider.overrideWithValue(const AsyncValue.data([])),

        // Provide deterministic home feed data.
        datasourceProvider.overrideWithValue(fakeDatasource),

        audioRepositoryProvider.overrideWithValue(const _FakeAudioRepository()),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('renders home screen UI elements', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home_scaffold')), findsOneWidget);
    expect(find.byKey(const Key('home_app_bar')), findsOneWidget);
    expect(find.byKey(const Key('home_upload_button')), findsOneWidget);
    expect(find.byKey(const Key('home_inbox_button')), findsOneWidget);
    expect(find.byKey(const Key('home_notifications_button')), findsOneWidget);
    expect(find.byKey(const Key('home_scroll_view')), findsOneWidget);

    // Verify basic UI is present.
    expect(find.byKey(const Key('trending_by_genre_section')), findsOneWidget);
    expect(find.byKey(const Key('hot_for_you_section')), findsOneWidget);

    // Verify one of the genre tabs and the track card is present.
    expect(find.byKey(const Key('genre_tab_bar')), findsOneWidget);
    expect(find.byKey(const Key('genre_tab_Reggae')), findsOneWidget);
    expect(find.byKey(Key('trending_track_${_testTrack.id}')), findsOneWidget);

    // Verify the Hot For You card is shown and formatted properly.
    expect(find.byKey(Key('hot_track_card_${_testTrack.id}')), findsOneWidget);
    expect(find.byKey(Key('hot_play_button_${_testTrack.id}')), findsOneWidget);
    expect(find.text('1.2K people liked your track'), findsOneWidget);

    // Scroll until the mixed playlists section becomes visible.
    await tester.dragUntilVisible(
      find.byKey(const Key('mixed_for_you_section')),
      find.byKey(const Key('home_scroll_view')),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('mixed_for_you_section')), findsOneWidget);

    // Scroll until the stations section becomes visible.
    await tester.dragUntilVisible(
      find.byKey(const Key('discover_stations_section')),
      find.byKey(const Key('home_scroll_view')),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('discover_stations_section')), findsOneWidget);

    // Scroll until the "More of What You Like" section becomes visible.
    await tester.dragUntilVisible(
      find.byKey(const Key('more_of_what_you_like_section')),
      find.byKey(const Key('home_scroll_view')),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('more_of_what_you_like_section')),
      findsOneWidget,
    );

    // Ensure the mixed playlists section renders.
    // expect(find.byKey(const Key('mixed_for_you_section')), findsOneWidget);

    // Ensure the stations section renders.
    expect(find.byKey(const Key('discover_stations_section')), findsOneWidget);

    // Ensure the more recommendations section renders.
    expect(
      find.byKey(const Key('more_of_what_you_like_section')),
      findsOneWidget,
    );

    // Ensure navigation targets exist.
    expect(find.byKey(const Key('station_card_station1')), findsOneWidget);
  });

  testWidgets('tapping inbox button navigates to /home/inbox', (tester) async {
    await tester.pumpWidget(buildTestApp());

    await tester.tap(find.byKey(const Key('home_inbox_button')));
    await tester.pumpAndSettle();

    expect(find.text('Inbox'), findsOneWidget);
  });

  testWidgets('tapping notifications button navigates to /home/notifications', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp());

    await tester.tap(find.byKey(const Key('home_notifications_button')));
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);
  });
}
