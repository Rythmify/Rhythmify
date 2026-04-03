import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'package:audio_service/audio_service.dart';
import 'features/player/data/datasources/audio_handler.dart';
import 'features/player/presentation/providers/player_dependency_providers.dart';

// import'core/network/api_client.dart';

late AudioHandler globalAudioHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Initialize Firebase ───────────────────────────────
  await Firebase.initializeApp();

  globalAudioHandler = await AudioService.init(
    builder: () => RythmifyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.rythmify.channel.audio',
      androidNotificationChannelName: 'Rythmify Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
  //added by hana to test upload module 
  // TEMPORARY — hardcoded test token from Postman
  // Remove when M1 authentication is properly integrated
  // await apiClient.saveToken(
  //   'YOUR_TOKEN_FROM_POSTMAN_HERE',
  // );

  runApp(
    ProviderScope(
      overrides: [
        audioHandlerProvider.overrideWithValue(
          globalAudioHandler as RythmifyAudioHandler,
        ),
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
