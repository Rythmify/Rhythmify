import 'package:flutter/material.dart';

/// A generic "See All" page used across genre tabs (tracks, playlists, albums, artists).
/// Wraps any [child] widget in a titled scaffold — keeping tab widgets reusable
/// without each needing to define their own full-page layout.
class GenreSeeAllPage extends StatelessWidget {
  const GenreSeeAllPage({super.key, required this.title, required this.child});

  /// The page title shown in the app bar (e.g. `'All Playlists'`).
  final String title;

  /// The scrollable content to display (e.g. a full track list or playlist grid).
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('genre_see_all_page'),
      appBar: AppBar(title: Text(title)),
      body: child,
    );
  }
}
