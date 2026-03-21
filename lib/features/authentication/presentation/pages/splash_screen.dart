import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authProvider, (previous, next) {
      if (next is AuthAuthenticated) {
        context.go('/home');
      } else if (next is AuthUnauthenticated) {
        context.go('/onboarding');
      }
      // AuthLoading — stay on splash
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Logo ─────────────────────────────────────
            const Icon(Icons.cloud, color: AppTheme.primaryBrand, size: 80),
            const SizedBox(height: 24),
            Text(
              'Rythmify',
              style: AppTheme.headlineLarge.copyWith(
                color: AppTheme.primaryBrand,
              ),
            ),
            const SizedBox(height: 48),
            // ── Loading indicator ─────────────────────────
            const CircularProgressIndicator(
              color: AppTheme.primaryBrand,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
