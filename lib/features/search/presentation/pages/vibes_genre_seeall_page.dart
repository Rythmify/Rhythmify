import 'package:flutter/material.dart';

class GenreSeeAllPage extends StatelessWidget {
  const GenreSeeAllPage({super.key, required this.title, required this.child});

  final String title;
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
