import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import 'package:flutter/material.dart';
import '../providers/auth_state.dart';

/// The splash screen displayed when the app first launches.
///
/// Listens to [authProvider] and automatically navigates the user to
/// the appropriate screen:
/// - [AuthAuthenticated] → `/home`
/// - [AuthUnauthenticated] → `/onboarding`
///
/// Includes a 5-second safety timeout to prevent being stuck on the
/// splash screen if the auth check hangs.
class SplashScreen extends ConsumerStatefulWidget {
  /// Creates a [SplashScreen].
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
  with SingleTickerProviderStateMixin {
    late AnimationController _controller;
    late Animation<double> _fade;
    late Animation<double> _scale;

  bool _isMinimumTimeElapsed = false;

  @override
  void initState() { super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scale = Tween<double>(begin: 0.85, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Start the mandatory 1800ms branding timer
    Future.delayed(const Duration(milliseconds: 1800), ()
    {
      if (mounted) {
        _isMinimumTimeElapsed = true;
        _attemptNavigation();
      }
    });

    // Safety timeout [5 seconds max wait]
    Future.delayed(const Duration(seconds: 5), ()
    {
      if (mounted) {
        final authState = ref.read(authProvider);
        if (authState is AuthLoading) {
          context.go('/onboarding'); 
        }
      }
    });
  }

  /// Checks if both the timer is done AND the auth state is ready.
  void _attemptNavigation()
  {
    // Don't navigate if the 1.8 seconds haven't passed yet
    if (!_isMinimumTimeElapsed) return;

    final authState = ref.read(authProvider);

    if (authState is AuthAuthenticated) {
      context.go('/home');
    } else if (authState is AuthUnauthenticated) {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context)
  {
    ref.listen(authProvider, (previous, next) {
      _attemptNavigation();
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scale.value,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.semiWhite
                            .withValues(alpha: 0.1 * _fade.value),
                        blurRadius: 30 * _fade.value,
                        spreadRadius: 16 * _fade.value,
                      ),
                    ],
                  ),
                  child: child,
                ),
              );
            },
            child: SvgPicture.asset(
              'assets/icons/logo.svg',
              width: 180,
              colorFilter: const ColorFilter.mode(
                AppTheme.semiWhite,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}