import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../features/premium/presentation/providers/premium_provider.dart';

class AdState {
  final int trackCount;
  final bool showAd;

  const AdState({required this.trackCount, required this.showAd});

  AdState copyWith({int? trackCount, bool? showAd}) {
    return AdState(
      trackCount: trackCount ?? this.trackCount,
      showAd: showAd ?? this.showAd,
    );
  }
}

class AdNotifier extends Notifier<AdState> {
  static const _kTrackCountKey = 'ad_track_count';
  static const _kAdThreshold = 5;

  @override
  AdState build() {
    _loadPersistedCount();
    return const AdState(trackCount: 0, showAd: false);
  }

  Future<void> _loadPersistedCount() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCount = prefs.getInt(_kTrackCountKey) ?? 0;
    state = state.copyWith(trackCount: savedCount);
  }

  Future<void> incrementTrackCount() async {
    debugPrint(
      '[AdNotifier] incrementTrackCount called. Current count: ${state.trackCount}',
    );

    // 1. Wait for premium initialization to finish to avoid race conditions
    final isInitialized = await _waitForPremiumInitialization();
    debugPrint('[AdNotifier] Premium provider initialized: $isInitialized');

    // 2. Only increment if not premium
    final isPremium = ref.read(isPremiumProvider);
    debugPrint('[AdNotifier] Premium status check: $isPremium');

    if (isPremium) {
      // If we just found out they are premium, clear any pending counts
      if (state.trackCount > 0 || state.showAd) {
        debugPrint('[AdNotifier] User is premium, clearing ad state.');
        state = state.copyWith(trackCount: 0, showAd: false);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_kTrackCountKey, 0);
      }
      return;
    }

    final newCount = state.trackCount + 1;

    if (newCount >= _kAdThreshold) {
      debugPrint('[AdNotifier] Threshold reached, showing Ad.');
      state = state.copyWith(trackCount: 0, showAd: true);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kTrackCountKey, 0);
    } else {
      debugPrint('[AdNotifier] Incrementing count to: $newCount');
      state = state.copyWith(trackCount: newCount);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kTrackCountKey, newCount);
    }
  }

  Future<bool> _waitForPremiumInitialization() async {
    // If already initialized, return immediately
    if (ref.read(premiumProvider).isInitialized) {
      debugPrint('[AdNotifier] Premium provider already initialized.');
      return true;
    }

    debugPrint('[AdNotifier] Waiting for Premium provider to initialize...');
    // Add a timeout just in case the network fails or takes too long
    final stopwatch = Stopwatch()..start();
    while (!ref.read(premiumProvider).isInitialized) {
      if (stopwatch.elapsedMilliseconds > 3000) {
        debugPrint('[AdNotifier] Timeout waiting for Premium provider.');
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
    debugPrint(
      '[AdNotifier] Premium provider initialized after ${stopwatch.elapsedMilliseconds}ms.',
    );
    return true;
  }

  void dismissAd() {
    debugPrint('[AdNotifier] Dismissing Ad.');
    state = state.copyWith(showAd: false);
  }
}

final adProvider = NotifierProvider<AdNotifier, AdState>(AdNotifier.new);
