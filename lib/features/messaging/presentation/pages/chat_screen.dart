import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
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