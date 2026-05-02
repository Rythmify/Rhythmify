import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../domain/entities/google_auth_data.dart';
import '../../data/services/google_oauth_windows.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_button.dart';

/// The sign-in / register entry screen.
///
/// Displays social login buttons (Google, Apple, Facebook, GitHub) and an
/// email input field. The [mode] parameter controls whether the
/// "Continue" button and social buttons lead to login or account creation.
///
/// **Email/Password Flow:**
/// - `mode = 'login'` → "Continue" button navigates to `/login/password`
/// - `mode = 'register'` → "Continue" button navigates to `/create-account/password`
///
/// **Google OAuth Flow:**
/// - `mode = 'login'` → Google button logs in directly to existing account → home
/// - `mode = 'register'` → Google button navigates to `/register` with pre-filled data
class SignInPage extends ConsumerStatefulWidget {
  /// Controls whether this page is in login or register mode.
  ///
  /// Defaults to `'login'`.
  final String mode;

  /// Creates a [SignInPage].
  ///
  /// [mode] must be either `'login'` or `'register'`.
  const SignInPage({super.key, this.mode = 'login'});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Validates the email field and navigates to the next step.
  ///
  /// Routes to `/create-account/password` in register mode,
  /// or `/login/password` in login mode.
  void _onContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      if (widget.mode == 'register') {
        context.push(
          '/create-account/password',
          extra: _emailController.text.trim(),
        );
      } else {
        context.push('/login/password', extra: _emailController.text.trim());
      }
    }
  }

  /// Initiates Google Sign-In flow with mode-dependent behavior.
  ///
  /// **In login mode (`mode = 'login'`):**
  /// 1. Launches Google Sign-In UI
  /// 2. Gets id_token from Google
  /// 3. Calls `signInWithGoogleAccount()` to log in directly
  /// 4. On success, navigates to home
  ///
  /// **In register mode (`mode = 'register'`):**
  /// 1. Launches Google Sign-In UI
  /// 2. Extracts email, displayName, photoUrl, and id_token
  /// 3. Navigates to RegisterPage with [GoogleAuthData] for profile completion
  /// 4. Registration completes the account creation
  ///
  /// If user cancels Google Sign-In (returns null), this method does nothing.
  Future<void> _handleGoogleSignIn() async {
    try {
      String? idToken;
      String? email;
      String? displayName;
      String? photoUrl;

      if (Platform.isWindows) {
        // Windows: Use browser-based OAuth flow
        final oauth = GoogleOAuthWindows(
          clientId:
              '456932364376-vcrpeja1sncvj73m928sp372o56aridp.apps.googleusercontent.com',
        );
        idToken = await oauth.signIn();
        if (idToken == null) {
          // User cancelled
          return;
        }
        // Note: Windows flow doesn't return email/displayName/photoUrl
        // They will be populated by the backend after sign-in
      } else {
        // Mobile platforms: Use native google_sign_in plugin
        final GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: const ['email', 'profile'],
          serverClientId:
              '456932364376-4ga0v16rd7dhemov4navlepcne4u51n8.apps.googleusercontent.com',
        );

        // Sign out first to ensure account picker shows
        await googleSignIn.signOut();

        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          // User cancelled—do nothing
          return;
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        idToken = googleAuth.idToken;
        email = googleUser.email;
        displayName = googleUser.displayName;
        photoUrl = googleUser.photoUrl;
      }

      if (idToken == null || idToken.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Failed to get Google ID token. Device may not support Google Sign-In.',
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return;
      }

      // Mode-dependent behavior
      if (widget.mode == 'login') {
        // Login mode: sign in directly using the notifier
        if (mounted) {
          ref.read(authProvider.notifier).signInWithGoogleAccount();
        }
      } else {
        // Register mode: navigate to registration page with pre-filled data
        if (mounted) {
          context.push(
            '/register',
            extra: GoogleAuthData(
              idToken: idToken,
              email: email ?? '',
              displayName: displayName ?? '',
              photoUrl: photoUrl,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (previous, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      if (next is AuthAuthenticated) {
        context.go('/home');
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sign in or create an account',
                  key: const Key('auth_title_text'),
                  style: AppTheme.headlineLarge.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 16),
                // Terms and privacy notice
                RichText(
                  key: const Key('auth_terms_and_privacy_text'),
                  text: TextSpan(
                    style: AppTheme.bodyMedium,
                    children: [
                      const TextSpan(
                        text:
                            'By clicking on any of the "Continue" buttons below, you agree to Rythmify\'s ',
                      ),
                      TextSpan(
                        text: 'Terms of Use',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.link,
                        ),
                      ),
                      const TextSpan(text: ' and acknowledge our '),
                      TextSpan(
                        text: 'Privacy Policy.',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.link,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                // Social login buttons
                SocialLoginButton(
                  key: const Key('auth_social_facebook_button'),
                  provider: SocialProvider.facebook,
                  onTap: () =>
                      ref.read(authProvider.notifier).signInWithGoogleAccount(),
                ),
                const SizedBox(height: 12),
                SocialLoginButton(
                  key: const Key('auth_social_google_button'),
                  provider: SocialProvider.google,
                  onTap: _handleGoogleSignIn,
                ),
                const SizedBox(height: 12),
                SocialLoginButton(
                  key: const Key('auth_social_github_button'),
                  provider: SocialProvider.github,
                  onTap: () => widget.mode == 'register'
                      ? ref.read(authProvider.notifier).signUpWithGitHub()
                      : ref.read(authProvider.notifier).signInWithGitHub(),
                ),
                const SizedBox(height: 28),
                Text(
                  'Or with email',
                  key: const Key('auth_email_divider_text'),
                  style: AppTheme.labelLarge,
                ),
                const SizedBox(height: 12),
                // Email input
                AuthTextField(
                  key: const Key('auth_email_text_field_container'),
                  hint: 'Your email address or profile URL',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _onContinue(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Continue button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    key: const Key('auth_continue_button'),
                    onPressed: authState is AuthLoading ? null : _onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.surface,
                      foregroundColor: AppTheme.textPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: authState is AuthLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : Text('Continue', style: AppTheme.labelLarge),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  key: const Key('auth_need_help_button'),
                  onTap: () {},
                  child: Text(
                    'Need help?',
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.link),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
