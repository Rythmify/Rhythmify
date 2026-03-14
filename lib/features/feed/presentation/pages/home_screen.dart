import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rythmify/features/upload_track/presentation/providers/upload_track_provider.dart';

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
              // Initialize fake draft for Chrome testing.
              // Replace with pick_audio_usecase when on real device.
              ref.read(uploadFormProvider.notifier).initDraft(
                artistId:       'dev_user_001',
                localAudioPath: '/fake/path/summer_vibes.mp3',
                duration:       const Duration(minutes: 3, seconds: 32),
                fileName:       'summer_vibes.mp3',
              );
              GoRouter.of(context).push('/upload-track');
            },
          ),

          IconButton(
            icon: const Icon(Icons.mail_outline),
            onPressed: () {
              context.push('/home/inbox');
            },
          ),

          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              context.push('/home/notifications');
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