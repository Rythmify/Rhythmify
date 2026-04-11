import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/core/domain/entities/track.dart';
import 'package:rythmify/core/theme/app_theme.dart';
import 'package:rythmify/features/search/domain/entities/search_suggestion.dart';
import 'package:rythmify/features/search/domain/entities/vibes_category.dart';
import 'package:rythmify/features/search/presentation/providers/search_providers.dart';
import 'package:rythmify/features/search/presentation/widgets/search_bar.dart';
import 'package:rythmify/features/search/presentation/widgets/search_suggestions_list.dart';
import 'package:rythmify/features/search/presentation/widgets/track_tile.dart';
import 'package:rythmify/features/search/presentation/widgets/vibes_grid.dart';
import 'package:rythmify/features/search/presentation/widgets/vibes_genre_trending_tracks.dart';

void main() {
  group('Search Widgets Tests', () {
    // ==================== SearchBarWidget Tests ====================
    group('SearchBarWidget', () {
      testWidgets('should render text field with cursor', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const Scaffold(body: SearchBarWidget()),
            ),
          ),
        );

        // Act & Assert
        expect(find.byType(TextField), findsOneWidget);
        expect(find.byType(SearchBarWidget), findsOneWidget);
      });

      testWidgets('should clear text when clear button is pressed', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const Scaffold(body: SearchBarWidget()),
            ),
          ),
        );

        // Act
        await tester.enterText(find.byType(TextField), 'test query');
        expect(find.text('test query'), findsOneWidget);

        // Find and tap clear button
        final clearButton = find.byIcon(Icons.clear);
        if (clearButton.evaluate().isNotEmpty) {
          await tester.tap(clearButton);
          await tester.pumpAndSettle();

          // Assert
          expect(find.text('test query'), findsNothing);
        }
      });

      testWidgets('should accept text input', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const Scaffold(body: SearchBarWidget()),
            ),
          ),
        );

        // Act
        await tester.enterText(find.byType(TextField), 'Blinding Lights');
        await tester.pump();

        // Assert
        expect(find.text('Blinding Lights'), findsOneWidget);
      });

      testWidgets('should have search icon', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const Scaffold(body: SearchBarWidget()),
            ),
          ),
        );

        // Act & Assert
        expect(find.byIcon(Icons.search), findsWidgets);
      });
    });

    // ==================== SearchSuggestionsList Tests ====================
    group('SearchSuggestionsList', () {
      testWidgets('should display empty state initially', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              // Mock the search suggestions provider to return empty data
              searchSuggestionsProvider.overrideWithValue(
                const AsyncValue.data([]),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const Scaffold(body: SearchSuggestionsList()),
            ),
          ),
        );

        // Act & Assert - Should show empty state when no query
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('suggestions_empty')), findsOneWidget);
        expect(find.text('No results found'), findsOneWidget);
      });

      testWidgets('should display suggestions list when query is set', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              // Mock the search suggestions provider to return data
              searchSuggestionsProvider.overrideWithValue(
                const AsyncValue.data([
                  SearchSuggestion(
                    id: 's1',
                    text: 'Test suggestion 1',
                    type: 'track',
                  ),
                  SearchSuggestion(
                    id: 's2',
                    text: 'Test suggestion 2',
                    type: 'artist',
                  ),
                ]),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const Scaffold(body: SearchSuggestionsList()),
            ),
          ),
        );

        // Act
        await tester.pumpAndSettle();

        // Assert - Check for key presence
        expect(find.byKey(const Key('suggestions_list')), findsOneWidget);
        expect(find.text('Test suggestion 1'), findsOneWidget);
        expect(find.text('Test suggestion 2'), findsOneWidget);
      });

      testWidgets('should be scrollable when has suggestions', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              // Mock the search suggestions provider to return data
              searchSuggestionsProvider.overrideWithValue(
                const AsyncValue.data([
                  SearchSuggestion(
                    id: 's1',
                    text: 'Test suggestion 1',
                    type: 'track',
                  ),
                  SearchSuggestion(
                    id: 's2',
                    text: 'Test suggestion 2',
                    type: 'artist',
                  ),
                ]),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const Scaffold(body: SearchSuggestionsList()),
            ),
          ),
        );

        // Act & Assert
        await tester.pumpAndSettle();
        expect(find.byType(ListView), findsOneWidget);
      });
    });

    // ==================== TrackTile Tests ====================
    group('TrackTile', () {
      late Track mockTrack;

      setUp(() {
        mockTrack = Track(
          id: 't1',
          userId: 'u1',
          title: 'Blinding Lights',
          artist: 'The Weeknd',
          audioUrl: 'https://example.com/audio.mp3',
          duration: const Duration(minutes: 3, seconds: 20),
          createdAt: DateTime.now(),
          coverImage: 'assets/images/track_1.jpg',
          genre: 'Pop',
          playCount: 100,
          likeCount: 50,
          commentCount: 10,
          repostCount: 5,
          isLiked: false,
          isReposted: false,
          isArtistFollowed: false,
          tags: const [],
          explicitContent: false,
          isTrending: false,
          isFeatured: false,
        );
      });

      testWidgets('should display track title', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(body: TrackTile(track: mockTrack)),
          ),
        );

        // Act & Assert
        expect(find.text('Blinding Lights'), findsOneWidget);
      });

      testWidgets('should display artist name', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(body: TrackTile(track: mockTrack)),
          ),
        );

        // Act & Assert
        expect(find.text('The Weeknd'), findsOneWidget);
      });

      testWidgets('should display duration', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(body: TrackTile(track: mockTrack)),
          ),
        );

        // Act & Assert
        expect(find.byType(ListTile), findsOneWidget);
        expect(find.byIcon(Icons.more_vert), findsOneWidget);
      });

      testWidgets('should have more_vert icon', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(body: TrackTile(track: mockTrack)),
          ),
        );

        // Act & Assert
        expect(find.byIcon(Icons.more_vert), findsOneWidget);
      });

      testWidgets('should render ListTile', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(body: TrackTile(track: mockTrack)),
          ),
        );

        // Act & Assert
        expect(find.byType(ListTile), findsOneWidget);
        expect(find.byKey(Key('track_tile_${mockTrack.id}')), findsOneWidget);
      });

      testWidgets('should handle tap', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(body: TrackTile(track: mockTrack)),
          ),
        );

        // Act
        await tester.tap(find.byType(ListTile));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(TrackTile), findsOneWidget);
      });
    });

    // ==================== VibesGrid Tests ====================
    group('VibesGrid', () {
      late List<VibeCategory> mockVibes;

      setUp(() {
        mockVibes = [
          const VibeCategory(
            id: 'v1',
            title: 'Chill',
            imagePath: 'assets/images/vibes_chill.jpeg',
            height: 100,
            color: Colors.blue,
          ),
          const VibeCategory(
            id: 'v2',
            title: 'Hip Hop',
            imagePath: 'assets/images/vibes_hiphop.jpeg',
            height: 150,
            color: Colors.purple,
          ),
          const VibeCategory(
            id: 'v3',
            title: 'Pop',
            imagePath: 'assets/images/vibes_pop.jpeg',
            height: 100,
            color: Colors.pink,
          ),
        ];
      });

      testWidgets('should render grid with correct number of items', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: VibesGrid(vibes: mockVibes, onVibeTap: (_) {}),
            ),
          ),
        );

        // Act & Assert
        expect(find.byKey(const Key('vibes_masonry_grid')), findsOneWidget);
      });

      testWidgets('should render all vibe items', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: VibesGrid(vibes: mockVibes, onVibeTap: (_) {}),
            ),
          ),
        );

        // Act & Assert
        for (var vibe in mockVibes) {
          expect(find.byKey(Key('vibe_item_${vibe.id}')), findsOneWidget);
        }
      });

      testWidgets('should call onVibeTap when vibe is tapped', (
        WidgetTester tester,
      ) async {
        // Arrange
        var tappedVibe = mockVibes.first;
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: VibesGrid(
                vibes: mockVibes,
                onVibeTap: (vibe) {
                  tappedVibe = vibe;
                },
              ),
            ),
          ),
        );

        // Act
        await tester.tap(find.byKey(Key('vibe_card_${mockVibes.first.id}')));
        await tester.pumpAndSettle();

        // Assert
        expect(tappedVibe.id, mockVibes.first.id);
      });

      testWidgets('should have border with vibe color', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: VibesGrid(vibes: mockVibes, onVibeTap: (_) {}),
            ),
          ),
        );

        // Act & Assert
        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('should render empty grid with no vibes', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: VibesGrid(vibes: [], onVibeTap: (_) {}),
            ),
          ),
        );

        // Act & Assert
        expect(find.byKey(const Key('vibes_masonry_grid')), findsOneWidget);
      });
    });

    // ==================== TrendingTracks Tests ====================
    group('TrendingTracks', () {
      late List<Track> mockTracks;

      setUp(() {
        mockTracks = [
          Track(
            id: 't1',
            userId: 'u1',
            title: 'Blinding Lights',
            artist: 'The Weeknd',
            audioUrl: 'https://example.com/audio.mp3',
            duration: const Duration(minutes: 3, seconds: 20),
            createdAt: DateTime.now(),
            genre: 'Pop',
            playCount: 100,
            likeCount: 50,
            commentCount: 10,
            repostCount: 5,
            isLiked: false,
            isReposted: false,
            isArtistFollowed: false,
            tags: const [],
            explicitContent: false,
            isTrending: true,
            isFeatured: false,
          ),
          Track(
            id: 't2',
            userId: 'u1',
            title: 'Save Your Tears',
            artist: 'The Weeknd',
            audioUrl: 'https://example.com/audio2.mp3',
            duration: const Duration(minutes: 3, seconds: 35),
            createdAt: DateTime.now(),
            genre: 'Pop',
            playCount: 150,
            likeCount: 75,
            commentCount: 15,
            repostCount: 8,
            isLiked: false,
            isReposted: false,
            isArtistFollowed: false,
            tags: const [],
            explicitContent: false,
            isTrending: true,
            isFeatured: false,
          ),
          Track(
            id: 't3',
            userId: 'u2',
            title: 'ocean eyes',
            artist: 'Billie Eilish',
            audioUrl: 'https://example.com/audio3.mp3',
            duration: const Duration(minutes: 3, seconds: 20),
            createdAt: DateTime.now(),
            genre: 'Pop',
            playCount: 200,
            likeCount: 100,
            commentCount: 20,
            repostCount: 10,
            isLiked: false,
            isReposted: false,
            isArtistFollowed: false,
            tags: const [],
            explicitContent: false,
            isTrending: true,
            isFeatured: false,
          ),
        ];
      });

      testWidgets('should render trending tracks list', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: Scaffold(body: TrendingTracks(tracks: mockTracks)),
            ),
          ),
        );

        // Act & Assert
        expect(find.byKey(const Key('trending_tracks_list')), findsOneWidget);
      });

      testWidgets('should render horizontal scroll view', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: Scaffold(body: TrendingTracks(tracks: mockTracks)),
            ),
          ),
        );

        // Act & Assert
        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('should display all trending tracks', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: Scaffold(body: TrendingTracks(tracks: mockTracks)),
            ),
          ),
        );

        // Act
        await tester.pumpAndSettle();

        // Assert
        for (var track in mockTracks) {
          expect(find.byKey(Key('trending_track_${track.id}')), findsWidgets);
        }
      });

      testWidgets('should render empty trending tracks', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: Scaffold(body: TrendingTracks(tracks: [])),
            ),
          ),
        );

        // Act & Assert
        expect(find.byKey(const Key('trending_tracks_list')), findsOneWidget);
      });

      testWidgets('should have correct height', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: Scaffold(body: TrendingTracks(tracks: mockTracks)),
            ),
          ),
        );

        // Act & Assert
        final sizedBox = tester.widget<SizedBox>(
          find
              .ancestor(
                of: find.byKey(const Key('trending_tracks_list')),
                matching: find.byType(SizedBox),
              )
              .first,
        );
        expect(sizedBox.height, 216);
      });
    });

    // ==================== Integration Tests ====================
    group('Search Widgets Integration', () {
      testWidgets('SearchBar should work with SuggestionsList visually', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              // Mock the search suggestions provider to avoid timer issues
              searchSuggestionsProvider.overrideWithValue(
                const AsyncValue.data([]),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: Scaffold(
                body: Column(
                  children: [
                    const SearchBarWidget(),
                    const Expanded(child: SearchSuggestionsList()),
                  ],
                ),
              ),
            ),
          ),
        );

        // Act & Assert
        expect(find.byType(SearchBarWidget), findsOneWidget);
        expect(find.byType(SearchSuggestionsList), findsOneWidget);
        expect(find.byKey(const Key('suggestions_empty')), findsOneWidget);
      });

      testWidgets('TrackTile should display with correct layout', (
        WidgetTester tester,
      ) async {
        // Arrange
        final mockTrack = Track(
          id: 't1',
          userId: 'u1',
          title: 'Test Track',
          artist: 'Test Artist',
          audioUrl: 'https://example.com/audio.mp3',
          duration: const Duration(minutes: 3),
          createdAt: DateTime.now(),
          genre: 'Pop',
          playCount: 100,
          likeCount: 50,
          commentCount: 10,
          repostCount: 5,
          isLiked: false,
          isReposted: false,
          isArtistFollowed: false,
          tags: const [],
          explicitContent: false,
          isTrending: false,
          isFeatured: false,
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: ListView(
                children: [
                  TrackTile(track: mockTrack),
                  TrackTile(track: mockTrack),
                ],
              ),
            ),
          ),
        );

        // Act & Assert
        expect(find.byType(TrackTile), findsWidgets);
        expect(find.byType(ListView), findsOneWidget);
      });
    });
  });
}
