// Copyright (c) 2026
// SPDX-License-Identifier: MIT

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rythmify/features/feed/presentation/pages/home_screen.dart';
import 'package:rythmify/features/feed/data/datasources/home_datasource.dart';
import 'package:rythmify/features/feed/presentation/providers/home_providers.dart';
import 'package:rythmify/features/player/domain/entities/player_state.dart';
import 'package:rythmify/features/player/domain/repositories/audio_repository.dart';
import 'package:rythmify/features/player/presentation/providers/player_dependency_providers.dart';
import 'package:rythmify/core/domain/entities/track.dart';

class _FakeAudioRepository implements AudioRepository {
  int loadQueueCallCount = 0;
  int playCallCount = 0;
  int pauseCallCount = 0;

  _FakeAudioRepository();

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
  Future<void> loadQueue(List<Track> tracks, {int initialIndex = 0}) async {
    loadQueueCallCount++;
  }

  @override
  Future<void> play() async {
    playCallCount++;
  }

  @override
  Future<void> pause() async {
    pauseCallCount++;
  }

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

class _ErrorTrendingHomeDatasource extends _FakeHomeDatasource {
  _ErrorTrendingHomeDatasource({
    required super.hotTracks,
    required super.mixedPlaylists,
    required super.stationPlaylists,
    required super.moreOfWhatYouLike,
  }) : super(
          trendingTracks: [],
        );

  @override
  Future<List<Track>> getTrendingTracks(String genre) async {
    throw Exception('Failed to load trending tracks');
  }
}

class _ErrorHotHomeDatasource extends _FakeHomeDatasource {
  _ErrorHotHomeDatasource({
    required super.trendingTracks,
    required super.mixedPlaylists,
    required super.stationPlaylists,
    required super.moreOfWhatYouLike,
  }) : super(
          hotTracks: [],
        );

  @override
  Future<List<Track>> getHotTracks() async {
    throw Exception('Failed to load hot tracks');
  }
}

class _ErrorStationsHomeDatasource extends _FakeHomeDatasource {
  _ErrorStationsHomeDatasource({
    required super.trendingTracks,
    required super.hotTracks,
    required super.mixedPlaylists,
    required super.moreOfWhatYouLike,
  }) : super(
          stationPlaylists: [],
        );

  @override
  Future<List<Map<String, dynamic>>> getStationPlaylists() async {
    throw Exception('Failed to load station playlists');
  }
}

class _LoadingHomeDatasource extends HomeDatasource {
  final Future<List<Track>> trendingTracksFuture;
  final Future<List<Track>> hotTracksFuture;
  final Future<List<Map<String, dynamic>>> mixedPlaylistsFuture;
  final Future<List<Map<String, dynamic>>> stationPlaylistsFuture;
  final Future<List<Map<String, dynamic>>> moreOfWhatYouLikeFuture;

  _LoadingHomeDatasource({
    required this.trendingTracksFuture,
    required this.hotTracksFuture,
    required this.mixedPlaylistsFuture,
    required this.stationPlaylistsFuture,
    required this.moreOfWhatYouLikeFuture,
  });

  @override
  Future<List<Track>> getTrendingTracks(String genre) async {
    return trendingTracksFuture;
  }

  @override
  Future<List<Track>> getHotTracks() async {
    return hotTracksFuture;
  }

  @override
  Future<List<Map<String, dynamic>>> getMixedPlaylists() async {
    return mixedPlaylistsFuture;
  }

  @override
  Future<List<Map<String, dynamic>>> getStationPlaylists() async {
    return stationPlaylistsFuture;
  }

  @override
  Future<List<Map<String, dynamic>>> getMoreOfWhatYouLikePlaylists() async {
    return moreOfWhatYouLikeFuture;
  }
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

  Widget buildTestApp({
    AudioRepository? audioRepository,
    HomeDatasource? datasource,
  }) {
    final fakeDatasource =
        datasource ??
        _FakeHomeDatasource(
          trendingTracks: [_testTrack],
          hotTracks: [_testTrack],
          mixedPlaylists: const [
            {'mixLabel': 'MIX 1', 'artists': 'artist1', 'image': ''},
          ],
          stationPlaylists: const [],
          moreOfWhatYouLike: const [
            {'artists': 'artist1', 'image': ''},
          ],
        );

    final fakeAudioRepository = audioRepository ?? _FakeAudioRepository();

    return ProviderScope(
      overrides: [
        // Avoid loading assets in tests.
        testAllTracksProvider.overrideWithValue(const AsyncValue.data([])),

        // Provide deterministic home feed data.
        datasourceProvider.overrideWithValue(fakeDatasource),

        audioRepositoryProvider.overrideWithValue(fakeAudioRepository),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('renders home screen UI elements', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home_scaffold')), findsOneWidget);
    expect(find.byKey(const Key('home_app_bar')), findsOneWidget);
    expect(
      find.byKey(const Key('home_upload_track_icon_button')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('home_inbox_icon_button')), findsOneWidget);
    expect(
      find.byKey(const Key('home_notifications_icon_button')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('home_scroll_view')), findsOneWidget);

    // Verify basic UI is present.
    expect(find.byKey(const Key('trending_by_genre_section')), findsOneWidget);
    expect(find.byKey(const Key('hot_for_you_section')), findsOneWidget);

    // Verify one of the genre tabs and the track card is present.
    expect(find.byKey(const Key('genre_tab_bar')), findsOneWidget);
    expect(
      find.byKey(const Key('trending_by_genre_tab_reggae')),
      findsOneWidget,
    );
    expect(find.byKey(Key('item_${_testTrack.id}')), findsOneWidget);

    // Verify the Hot For You card is shown and formatted properly.
    expect(find.byKey(Key('hot_track_card_${_testTrack.id}')), findsOneWidget);
    expect(find.byKey(Key('hot_for_you_play_icon_button')), findsOneWidget);
    expect(find.byKey(Key('hot_for_you_like_count_text')), findsOneWidget);

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
    // (Station cards are only built when there are stations to display.)
  });

  testWidgets('tapping inbox button navigates to /home/inbox', (tester) async {
    await tester.pumpWidget(buildTestApp());

    await tester.tap(find.byKey(const Key('home_inbox_icon_button')));
    await tester.pumpAndSettle();

    expect(find.text('Inbox'), findsOneWidget);
  });

  testWidgets('tapping notifications button navigates to /home/notifications', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp());

    await tester.tap(find.byKey(const Key('home_notifications_icon_button')));
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);
  });

  testWidgets('hot for you play button triggers audio repository calls', (
    tester,
  ) async {
    final fakeAudioRepo = _FakeAudioRepository();

    await tester.pumpWidget(buildTestApp(audioRepository: fakeAudioRepo));
    await tester.pumpAndSettle();

    expect(find.text('1.2K people liked your track'), findsOneWidget);

    await tester.tap(find.byKey(const Key('hot_for_you_play_icon_button')));
    await tester.pumpAndSettle();

    expect(fakeAudioRepo.loadQueueCallCount, 1);
    expect(fakeAudioRepo.playCallCount, 1);
  });

  testWidgets('shows error when trending tracks fail to load', (tester) async {
    final errorDatasource = _ErrorTrendingHomeDatasource(
      hotTracks: [_testTrack],
      mixedPlaylists: const [
        {'mixLabel': 'MIX 1', 'artists': 'artist1', 'image': ''},
      ],
      stationPlaylists: const [],
      moreOfWhatYouLike: const [
        {'artists': 'artist1', 'image': ''},
      ],
    );

    await tester.pumpWidget(buildTestApp(datasource: errorDatasource));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('trending_by_genre_error_text_reggae')),
      findsOneWidget,
    );
  });

  testWidgets('shows error when hot for you fails to load', (tester) async {
    final errorDatasource = _ErrorHotHomeDatasource(
      trendingTracks: [_testTrack],
      mixedPlaylists: const [
        {'mixLabel': 'MIX 1', 'artists': 'artist1', 'image': ''},
      ],
      stationPlaylists: const [],
      moreOfWhatYouLike: const [
        {'artists': 'artist1', 'image': ''},
      ],
    );

    await tester.pumpWidget(buildTestApp(datasource: errorDatasource));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('hot_for_you_error_text')), findsOneWidget);
  });

  testWidgets('shows error when station playlists fail to load', (
    tester,
  ) async {
    final errorDatasource = _ErrorStationsHomeDatasource(
      trendingTracks: [_testTrack],
      hotTracks: [_testTrack],
      mixedPlaylists: const [
        {'mixLabel': 'MIX 1', 'artists': 'artist1', 'image': ''},
      ],
      moreOfWhatYouLike: const [
        {'artists': 'artist1', 'image': ''},
      ],
    );

    await tester.pumpWidget(buildTestApp(datasource: errorDatasource));
    await tester.pumpAndSettle();

    // Scroll to the stations section (it may be offscreen)
    await tester.dragUntilVisible(
      find.byKey(const Key('discover_stations_section')),
      find.byKey(const Key('home_scroll_view')),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('discover_with_stations_error_text')),
      findsOneWidget,
    );
  });

  testWidgets('renders station cards when station playlists load', (
    tester,
  ) async {
    final datasourceWithStations = _FakeHomeDatasource(
      trendingTracks: [_testTrack],
      hotTracks: [_testTrack],
      mixedPlaylists: const [
        {'mixLabel': 'MIX 1', 'artists': 'artist1', 'image': ''},
      ],
      // Use a local asset so tests don't require network access.
      stationPlaylists: const [
        {'artists': 'station1', 'image': 'assets/images/track_1.jpg'},
      ],
      moreOfWhatYouLike: const [
        {'artists': 'artist1', 'image': ''},
      ],
    );

    await tester.pumpWidget(buildTestApp(datasource: datasourceWithStations));
    await tester.pumpAndSettle();

    // Scroll to the stations section and verify a station card is built.
    await tester.dragUntilVisible(
      find.byKey(const Key('discover_stations_section')),
      find.byKey(const Key('home_scroll_view')),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('station_card_container_station1')),
      findsOneWidget,
    );
  });

  testWidgets('shows loading indicators while data is pending', (tester) async {
    final trendingCompleter = Completer<List<Track>>();
    final hotCompleter = Completer<List<Track>>();
    final mixedCompleter = Completer<List<Map<String, dynamic>>>();
    final stationsCompleter = Completer<List<Map<String, dynamic>>>();
    final moreCompleter = Completer<List<Map<String, dynamic>>>();

    final loadingDatasource = _LoadingHomeDatasource(
      trendingTracksFuture: trendingCompleter.future,
      hotTracksFuture: hotCompleter.future,
      mixedPlaylistsFuture: mixedCompleter.future,
      stationPlaylistsFuture: stationsCompleter.future,
      moreOfWhatYouLikeFuture: moreCompleter.future,
    );

    await tester.pumpWidget(buildTestApp(datasource: loadingDatasource));

    // Initial frame should show loading states.
    await tester.pump();

    expect(find.byKey(const Key('hot_for_you_loading')), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsWidgets);

    // Complete the futures so the test can finish cleanly.
    trendingCompleter.complete([_testTrack]);
    hotCompleter.complete([_testTrack]);
    mixedCompleter.complete(const [
      {'mixLabel': 'MIX 1', 'artists': 'artist1', 'image': ''},
    ]);
    stationsCompleter.complete(const [
      {'artists': 'station1', 'image': 'assets/images/track_1.jpg'},
    ]);
    moreCompleter.complete(const [
      {'artists': 'artist1', 'image': ''},
    ]);

    await tester.pumpAndSettle();
  });

  testWidgets('does not render mixed playlist list when empty', (tester) async {
    final emptyMixedDatasource = _FakeHomeDatasource(
      trendingTracks: [_testTrack],
      hotTracks: [_testTrack],
      mixedPlaylists: const [],
      stationPlaylists: const [],
      moreOfWhatYouLike: const [
        {'artists': 'artist1', 'image': ''},
      ],
    );

    await tester.pumpWidget(buildTestApp(datasource: emptyMixedDatasource));
    await tester.pumpAndSettle();

    // The horizontal list should not render when there are no mixed playlists.
    expect(find.byKey(const Key('mixed_list_view')), findsNothing);
  });

  testWidgets('does not render more-of-what-you-like list when empty', (
    tester,
  ) async {
    final emptyMoreDatasource = _FakeHomeDatasource(
      trendingTracks: [_testTrack],
      hotTracks: [_testTrack],
      mixedPlaylists: const [
        {'mixLabel': 'MIX 1', 'artists': 'artist1', 'image': ''},
      ],
      stationPlaylists: const [],
      moreOfWhatYouLike: const [],
    );

    await tester.pumpWidget(buildTestApp(datasource: emptyMoreDatasource));
    await tester.pumpAndSettle();

    // The horizontal list should not render when there are no 'more of what you like' items.
    expect(find.byKey(const Key('more_list_view')), findsNothing);
  });
}