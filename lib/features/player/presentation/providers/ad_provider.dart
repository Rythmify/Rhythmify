import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../features/premium/presentation/providers/premium_provider.dart';

class AdState {
  final int trackCount;
  final bool showAd;

  const AdState({
    required this.trackCount,
    required this.showAd,
  });

  AdState copyWith({
    int? trackCount,
    bool? showAd,
  }) {
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
    // Only increment if not premium
    final isPremium = ref.read(isPremiumProvider);
    if (isPremium) return;

    final newCount = state.trackCount + 1;
    
    if (newCount >= _kAdThreshold) {
      state = state.copyWith(trackCount: 0, showAd: true);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kTrackCountKey, 0);
    } else {
      state = state.copyWith(trackCount: newCount);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kTrackCountKey, newCount);
    }
  }

  void dismissAd() {
    state = state.copyWith(showAd: false);
  }
}

final adProvider = NotifierProvider<AdNotifier, AdState>(AdNotifier.new);
