import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: false,
        actions: [

          IconButton(
            icon: const Icon(Icons.arrow_circle_up),
            onPressed: () {
              
            },
          ),

          IconButton(
            icon: const Icon(Icons.mail_outline),
            onPressed: () {
              
            },
          ),

          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              
            },
          ),
        ],
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