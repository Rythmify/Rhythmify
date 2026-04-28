import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/premium_provider.dart';
import 'upgrade_landing_screen.dart';
import 'cancellation_screen.dart';

/// Gate widget on the Upgrade tab.
///
/// Waits for [PremiumNotifier._init] to complete (both loadPlans +
/// loadMySubscription) before deciding which screen to show.
/// This prevents premium users from seeing the landing screen briefly.
///
/// → Not yet initialized : dark spinner
/// → isPremium = true    : CancellationScreen
/// → isPremium = false   : UpgradeLandingScreen
class UpgradeGateScreen extends ConsumerWidget {
  const UpgradeGateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(premiumProvider);

    if (!state.isInitialized) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF5500),
            strokeWidth: 2,
          ),
        ),
      );
    }

    return state.isPremium
        ? const CancellationScreen()
        : const UpgradeLandingScreen();
  }
}
