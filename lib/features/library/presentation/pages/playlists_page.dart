/// Compatibility export module for the Library playlists route.
// lib/features/library/presentation/pages/playlists_page.dart
//
// REPLACED: This used to be your partner's dummy placeholder.
// Now it simply re-exports our real LibraryPlaylistsScreen so the
// router import path stays the same — no router changes needed.
//
// The router does:
//   import '../../features/library/presentation/pages/playlists_page.dart';
//   builder: (context, state) => const LibraryPlaylistsScreen(),
//
// That still works because LibraryPlaylistsScreen is now available
// through this file.

// If your package name is not 'rythmify', change it below to match
// what's in your pubspec.yaml under "name:".
export 'package:rythmify/features/playlist/presentation/screens/library_playlists_screen.dart';
