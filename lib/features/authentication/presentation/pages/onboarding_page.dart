import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../core/theme/app_theme.dart';

/// The onboarding screen shown to unauthenticated users.
///
/// Displays the app branding with a layered artwork background and
/// two action buttons:
/// - "Create an account" → navigates to `/sign-in` in register mode
/// - "Log in" → navigates to `/sign-in` in login mode
class OnboardingPage extends StatelessWidget {
  /// Creates an [OnboardingPage].
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background artwork layer 1 — top aligned
          Image.asset(
            'assets/images/onboarding_art.jpg',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.fitWidth,
            alignment: Alignment.topCenter,
          ),
          // Background artwork layer 2 — offset downward for depth effect
          Align(
            alignment: Alignment.bottomCenter,
            child: Transform.translate(
              offset: const Offset(0, 100),
              child: Image.asset(
                'assets/images/onboarding_art.jpg',
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),

          // Foreground: blob background + buttons
          Align( alignment: Alignment.bottomCenter,

            // Animation Sliding from down to up
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 1.0, end: 0.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic, // Gives it a nice, natural deceleration
              builder: (context, value, child) {
                return FractionalTranslation(
                  translation: Offset(0, value),
                  child: child,
                );
              },
              child: Stack(
                children: [
                  // ------ Blob PNG background ------
                  Positioned.fill(
                    child: Transform.scale(
                      scale: 1.7,
                      child: Transform.translate(
                        offset: const Offset(0, 33),
                        child: Image.asset(
                          'assets/images/onboarding_blob.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  // ------ Content: logo, tagline, buttons ------
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 1, 24, 60),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.translate(
                          offset: const Offset(0, 10),
                          child: SvgPicture.asset(
                            'assets/icons/logo.svg',
                            width: 100,
                            height: 100,
                            colorFilter: const ColorFilter.mode(
                              Colors.black,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        Text(
                          'Where artists & fans connect.',
                          textAlign: TextAlign.center,
                          style: AppTheme.headlineLarge
                              .copyWith(color: Colors.black)
                              .copyWith(
                                fontSize: 30,
                                letterSpacing: -1.5,
                                height: 1.15,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 30),

                        // ------ Create account button ------
                        SizedBox(
                          width: 320,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () =>
                                context.push('/sign-in', extra: 'register'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                            child: Text(
                              'Create an account',
                              style: AppTheme.bodyNormal.copyWith(
                                color: Colors.black,
                                fontSize: 16,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // ------ Log in button ------
                        SizedBox(
                          width: 320,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () =>
                                context.push('/sign-in', extra: 'login'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.babyBlue,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                            child: Text(
                              'Log in',
                              style: AppTheme.bodyNormal.copyWith(
                                color: Colors.black,
                                fontSize: 16,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}