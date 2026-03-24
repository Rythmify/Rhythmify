import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/onboarding_art.jpg',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.fitWidth,
            alignment: Alignment.topCenter,
          ),
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Stack(
              children: [
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
