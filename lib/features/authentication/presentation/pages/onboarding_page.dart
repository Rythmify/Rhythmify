import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // ── Top artwork section ──────────────────────
          Expanded(
            child: Image.asset(
              'assets/images/onboarding_art.jpg',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          /// Bottom panel
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 5, 24, 40),
              decoration: const BoxDecoration(
                color: Color(0xFF5A86D6),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Logo
                  const Icon(
                    Icons.cloud,
                    color: Colors.black,
                    size: 70,
                  ),

                  const SizedBox(height: 1),

                  /// Title
                        // Tagline
                  Text(
                    'Where artists & fans connect.',
                    textAlign: TextAlign.center,
                    style:
                        AppTheme.headlineLarge.copyWith(color: Colors.black).copyWith(fontSize: 25, fontWeight: FontWeight.w300),
                  ),

                  const SizedBox(height: 32),

                  /// Create account
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => context.push('/sign-in'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      child: const Text(
                        "Create an account",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// Login button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => context.push('/sign-in'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.6),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      child: const Text(
                        "Log in",
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
          ),
        ],
      ),
    );
  }
}