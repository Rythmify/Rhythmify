import 'package:flutter/material.dart';

/// A generic full-screen page for displaying an expanded "See All" list.
///
/// Wraps any [child] widget in a [Scaffold] with an app bar showing
/// [title] and a back button. Used across search result sections to
/// avoid duplicating scaffold boilerplate.
class SearchSeeAllPage extends StatelessWidget {
  const SearchSeeAllPage({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: child,
    );
  }
}
