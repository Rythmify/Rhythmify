import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chrome_cast/flutter_chrome_cast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'package:audio_service/audio_service.dart';
import 'features/player/data/datasources/audio_handler.dart';
import 'features/player/presentation/providers/player_dependency_providers.dart';
import 'core/widget/widget_sync_provider.dart';
import 'core/widget/likes_widget_sync_provider.dart';

late AudioHandler globalAudioHandler;

Future<void> _initGoogleCast() async {
  if (!Platform.isAndroid && !Platform.isIOS) return;

  const appId = GoogleCastDiscoveryCriteria.kDefaultApplicationId;
  GoogleCastOptions? options;

  if (Platform.isIOS) {
    options = IOSGoogleCastOptions(
      GoogleCastDiscoveryCriteriaInitialize.initWithApplicationID(appId),
      stopCastingOnAppTerminated: false,
    );
  } else {
    options = GoogleCastOptionsAndroid(
      appId: appId,
      stopCastingOnAppTerminated: false,
    );
  }

  await GoogleCastContext.instance.setSharedInstanceWithOptions(options);
}

Future<void> _initFirebaseIfSupported() async {
  if (kIsWeb) return;

  if (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}

Future<void> _initAudioServiceIfSupported() async {
  // audio_service does NOT support Windows or web.
  // Only initialize it on Android and iOS where it's properly supported.
  if (kIsWeb ||
      (defaultTargetPlatform != TargetPlatform.android &&
          defaultTargetPlatform != TargetPlatform.iOS)) {
    // Use direct handler instance on unsupported platforms
    globalAudioHandler = RythmifyAudioHandler();
    return;
  }

  globalAudioHandler = await AudioService.init(
    builder: () => RythmifyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.rythmify.channel.audio',
      androidNotificationChannelName: 'Rythmify Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Initialize Local Storage ──────────────────────────
  await Hive.initFlutter();

  // ── Initialize Firebase ───────────────────────────────
  await _initFirebaseIfSupported();
  await _initGoogleCast();

  // ── Initialize Audio Service (Android/iOS only) ───────
  await _initAudioServiceIfSupported();

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
    // Keep widget sync notifiers alive for the entire app lifetime
    ref.watch(widgetSyncProvider);
    ref.watch(likesWidgetSyncProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Rythmify',
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
