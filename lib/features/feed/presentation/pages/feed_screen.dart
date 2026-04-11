import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        centerTitle: false,

      ),
      body: const Center(
        child: Text(
          'This is a dummy page',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}