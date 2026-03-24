import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
      backgroundColor: AppTheme.background,
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Stack(
              children: [
                // Blob PNG background
                Positioned.fill(
                  child: Transform.scale(
                    scale: 1.5,
                    child: Transform.translate(
                      offset: const Offset(0, 10),
                      child: Image.asset(
                        'assets/images/onboarding_blob.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                // Content: logo, tagline, buttons
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 1, 24, 60),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.translate(
                        offset: const Offset(0, -20),
                        child: const Icon(
                          Icons.cloud,
                          color: Colors.black,
                          size: 60,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Where artists & fans connect.',
                        textAlign: TextAlign.center,
                        style: AppTheme.headlineLarge
                            .copyWith(color: Colors.black)
                            .copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w200,
                            ),
                      ),
                      const SizedBox(height: 44.5),
                      // Create account button
                      SizedBox(
                        width: 265,
                        height: 40,
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
                          child: const Text(
                            'Create an account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Log in button
                      SizedBox(
                        width: 265,
                        height: 40,
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
                          child: const Text(
                            'Log in',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
        ],
      ),
    );
  }
}