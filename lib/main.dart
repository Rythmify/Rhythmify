import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'package:audio_service/audio_service.dart';
import 'features/player/data/datasources/audio_handler.dart';
import 'features/player/presentation/providers/player_dependency_providers.dart';

late AudioHandler globalAudioHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  globalAudioHandler = await AudioService.init(
    builder: () => RythmifyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.rythmify.channel.audio',
      androidNotificationChannelName: 'Rythmify Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        audioHandlerProvider.overrideWithValue(globalAudioHandler as RythmifyAudioHandler),
      ],
      child: const RythmifyApp(),
    ),
  );
}

class RythmifyApp extends ConsumerWidget {
  const RythmifyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Rythmify',
      theme: AppTheme.darkTheme, 
      routerConfig: router,
    );
  }
}