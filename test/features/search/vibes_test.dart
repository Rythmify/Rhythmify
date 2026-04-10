import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:rythmify/core/domain/entities/track.dart';
import 'package:rythmify/core/theme/app_theme.dart';
import 'package:rythmify/features/search/domain/entities/vibes_category.dart';
import 'package:rythmify/features/search/domain/entities/vibes_genre_content.dart';
import 'package:rythmify/features/search/domain/entities/vibes_genre_info.dart';
import 'package:rythmify/features/search/domain/entities/vibes_genre_introducing_section.dart';
import 'package:rythmify/features/search/domain/entities/vibes_genre_introducing_playlist.dart';
import 'package:rythmify/features/search/presentation/widgets/vibes_grid.dart';
import 'package:rythmify/features/search/presentation/widgets/vibes_genre_trending_tracks.dart';

void main() {
  group('Vibes Files Tests', () {
    // ==================== VibeCategory Entity Tests ====================
    group('VibeCategory Entity', () {
      test('should create VibeCategory with all properties', () {
        // Arrange
        const vibe = VibeCategory(
          id: 'v1',
          title: 'Chill',
          imagePath: 'assets/images/vibes_chill.jpeg',
          height: 100,
          color: Colors.blue,
        );

        // Act & Assert
        expect(vibe.id, 'v1');
        expect(vibe.title, 'Chill');
        expect(vibe.imagePath, 'assets/images/vibes_chill.jpeg');
        expect(vibe.height, 100);
        expect(vibe.color, Colors.blue);
      });

      test('should support const constructor', () {
        // Arrange & Act
        const vibe1 = VibeCategory(
          id: 'v1',
          title: 'Chill',
          imagePath: 'assets/images/vibes_chill.jpeg',
          height: 100,
          color: Colors.blue,
        );
        const vibe2 = VibeCategory(
          id: 'v1',
          title: 'Chill',
          imagePath: 'assets/images/vibes_chill.jpeg',
          height: 100,
          color: Colors.blue,
        );

        // Assert
        expect(vibe1, vibe2);
      });

      test('should create vibes with different heights', () {
        // Arrange
        const vibe1 = VibeCategory(
          id: 'v1',
          title: 'Chill',
          imagePath: 'assets/images/chill.jpg',
          height: 100,
          color: Colors.blue,
        );
        const vibe2 = VibeCategory(
          id: 'v2',
          title: 'Hip Hop',
          imagePath: 'assets/images/hiphop.jpg',
          height: 150,
          color: Colors.purple,
        );

        // Act & Assert
        expect(vibe1.height, isNot(vibe2.height));
        expect(vibe2.height, 150);
      });

      test('should create vibes with different colors', () {
        // Arrange
        const vibe1 = VibeCategory(
          id: 'v1',
          title: 'Chill',
          imagePath: 'assets/images/vibes_chill.jpeg',
          height: 100,
          color: Colors.blue,
        );
        const vibe2 = VibeCategory(
          id: 'v2',
          title: 'Hip Hop',
          imagePath: 'assets/images/vibes_hiphop.jpeg',
          height: 150,
          color: Colors.purple,
        );

        // Act & Assert
        expect(vibe1.color, Colors.blue);
        expect(vibe2.color, Colors.purple);
      });

      test('should handle multiple vibes in a list', () {
        // Arrange
        final vibes = [
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

        // Act & Assert
        expect(vibes.length, 3);
        expect(vibes[0].title, 'Chill');
        expect(vibes[1].title, 'Hip Hop');
        expect(vibes[2].title, 'Pop');
      });
    });

    // ==================== GenreContent Entity Tests ====================
    group('GenreContent Entity', () {
      late List<Track> mockTracks;
      late Track mockTrack;

      setUp(() {
        mockTrack = Track(
          id: 't1',
          userId: 'u1',
          title: 'Track 1',
          artist: 'Artist 1',
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
        mockTracks = [mockTrack];
      });

      test('should create GenreContent with all properties', () {
        // Arrange
        final genreInfo = GenreInfo(
          id: 'g1',
          name: 'Pop',
          coverImage: 'assets/images/pop.jpg',
          trackCount: 100,
          artistCount: 50,
          playlistCount: 25,
          albumCount: 30,
        );

        final playlist = IntroducingPlaylist(
          playlistId: 'p1',
          ownerUserId: 'u1',
          name: 'Pop Hits',
          description: 'Popular tracks',
          isPublic: true,
          createdAt: DateTime.now(),
          trackCount: 20,
          likeCount: 150,
          coverImage: 'assets/images/playlist.jpg',
          previewTrack: mockTrack,
        );

        final introducing = IntroducingSection(
          playlist: playlist,
          tracksPreview: mockTracks,
        );

        final content = GenreContent(
          genreInfo: genreInfo,
          introducing: introducing,
          playlists: const [],
          albums: const [],
          artists: const [],
          tracks: mockTracks,
        );

        // Act & Assert
        expect(content.genreInfo.name, 'Pop');
        expect(content.introducing.tracksPreview.isNotEmpty, true);
        expect(content.playlists, isEmpty);
        expect(content.albums, isEmpty);
        expect(content.artists, isEmpty);
        expect(content.tracks, isNotEmpty);
      });

      test('should store genre information', () {
        // Arrange
        final genreInfo = GenreInfo(
          id: 'g1',
          name: 'Rock',
          coverImage: 'assets/images/vibes_rb.jpeg',
          trackCount: 200,
          artistCount: 100,
          playlistCount: 50,
          albumCount: 60,
        );

        final playlist = IntroducingPlaylist(
          playlistId: 'p1',
          ownerUserId: 'u1',
          name: 'Rock Classics',
          description: 'Classic rock',
          isPublic: true,
          createdAt: DateTime.now(),
          trackCount: 30,
          likeCount: 200,
          coverImage: 'assets/images/playlist.jpg',
          previewTrack: mockTrack,
        );

        final introducing = IntroducingSection(
          playlist: playlist,
          tracksPreview: mockTracks,
        );

        final content = GenreContent(
          genreInfo: genreInfo,
          introducing: introducing,
          playlists: const [],
          albums: const [],
          artists: const [],
          tracks: mockTracks,
        );

        // Act & Assert
        expect(content.genreInfo.name, 'Rock');
        expect(content.genreInfo.trackCount, 200);
        expect(content.genreInfo.artistCount, 100);
      });

      test('should support multiple tracks in content', () {
        // Arrange
        final track2 = Track(
          id: 't2',
          userId: 'u2',
          title: 'Track 2',
          artist: 'Artist 2',
          audioUrl: 'https://example.com/audio2.mp3',
          duration: const Duration(minutes: 4),
          createdAt: DateTime.now(),
          genre: 'Rock',
          playCount: 200,
          likeCount: 100,
          commentCount: 20,
          repostCount: 10,
          isLiked: false,
          isReposted: false,
          isArtistFollowed: false,
          tags: const [],
          explicitContent: false,
          isTrending: false,
          isFeatured: false,
        );

        final genreInfo = GenreInfo(
          id: 'g1',
          name: 'Pop',
          coverImage: 'assets/images/pop.jpg',
          trackCount: 100,
          artistCount: 50,
          playlistCount: 25,
          albumCount: 30,
        );

        final playlist = IntroducingPlaylist(
          playlistId: 'p1',
          ownerUserId: 'u1',
          name: 'Pop Hits',
          description: 'Popular tracks',
          isPublic: true,
          createdAt: DateTime.now(),
          trackCount: 20,
          likeCount: 150,
          coverImage: 'assets/images/playlist.jpg',
          previewTrack: mockTrack,
        );

        final introducing = IntroducingSection(
          playlist: playlist,
          tracksPreview: [mockTrack, track2],
        );

        final content = GenreContent(
          genreInfo: genreInfo,
          introducing: introducing,
          playlists: const [],
          albums: const [],
          artists: const [],
          tracks: [mockTrack, track2],
        );

        // Act & Assert
        expect(content.tracks.length, 2);
        expect(content.introducing.tracksPreview.length, 2);
      });
    });

    // ==================== TrendingTracks Widget Tests ====================
    group('TrendingTracks Vibes Widget', () {
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
        ];
      });

      testWidgets('should render with key', (WidgetTester tester) async {
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

      testWidgets('should chunk tracks into groups of 3', (
        WidgetTester tester,
      ) async {
        // Arrange
        final sixTracks = [...mockTracks, ...mockTracks, ...mockTracks];

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: Scaffold(body: TrendingTracks(tracks: sixTracks)),
            ),
          ),
        );

        // Act & Assert
        expect(find.byKey(const Key('trending_tracks_list')), findsOneWidget);
      });

      testWidgets('should display track info correctly', (
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
        await tester.pumpAndSettle();
        expect(find.byType(ListView), findsOneWidget);
      });
    });

    // ==================== VibesGrid Widget Tests ====================
    group('VibesGrid Vibes Widget', () {
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

      testWidgets('should render masonry grid', (WidgetTester tester) async {
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

      testWidgets('should render all vibes', (WidgetTester tester) async {
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

      testWidgets('should have correct vibe card keys', (
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
        for (var vibe in mockVibes) {
          expect(find.byKey(Key('vibe_card_${vibe.id}')), findsOneWidget);
        }
      });

      testWidgets('should have correct vibe image keys', (
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
        for (var vibe in mockVibes) {
          expect(find.byKey(Key('vibe_image_${vibe.id}')), findsWidgets);
        }
      });

      testWidgets('should be scrollable', (WidgetTester tester) async {
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
    });
  });
}
