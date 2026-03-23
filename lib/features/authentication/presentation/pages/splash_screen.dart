import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // ── Safety timeout — if stuck for 5 seconds go to onboarding
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        final authState = ref.read(authProvider);
        if (authState is AuthLoading) {
          
          context.go('/onboarding');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      
      if (next is AuthAuthenticated) {
        context.go('/home');
      } else if (next is AuthUnauthenticated) {
        context.go('/onboarding');
      }
    });

    final authState = ref.watch(authProvider);
    

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud,
              color: AppTheme.primaryBrand,
              size: 80,
            ),
            const SizedBox(height: 24),
            Text(
              'Rythmify',
              style: AppTheme.headlineLarge.copyWith(
                color: AppTheme.primaryBrand,
              ),
            ),
            const SizedBox(height: 48),
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