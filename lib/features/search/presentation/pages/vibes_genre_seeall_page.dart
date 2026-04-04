import 'package:flutter/material.dart';

class GenreSeeAllPage extends StatelessWidget {
  const GenreSeeAllPage({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: child,
    );
  }
}
