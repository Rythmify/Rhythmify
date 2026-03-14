import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_button.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

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

  void _onContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      context.push('/create-account/password',
          extra: _emailController.text.trim());
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
                // Title
                Text(
                  'Sign in or create an account',
  style: AppTheme.headlineLarge.copyWith(
    fontWeight: FontWeight.w500,
    fontSize: 28,
  ),),

                const SizedBox(height: 16),

                // Terms text
                RichText(
                  text: TextSpan(
                    style: AppTheme.bodyMedium,
                    children: [
                      const TextSpan(
                        text:
                            'By clicking on any of the "Continue" buttons below, you agree to Rythmify\'s ',
                      ),
                      TextSpan(
                        text: 'Terms of Use',
                        style: AppTheme.bodyMedium
                            .copyWith(color: AppTheme.link),
                      ),
                      const TextSpan(text: ' and acknowledge our '),
                      TextSpan(
                        text: 'Privacy Policy.',
                        style: AppTheme.bodyMedium
                            .copyWith(color: AppTheme.link),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Social buttons
                SocialLoginButton(
                  provider: SocialProvider.facebook,
                  onTap: () =>
                      ref.read(authProvider.notifier).signInWithGoogleAccount(),
                ),
                const SizedBox(height: 12),
                SocialLoginButton(
                  provider: SocialProvider.google,
                  onTap: () =>
                      ref.read(authProvider.notifier).signInWithGoogleAccount(),
                ),
                const SizedBox(height: 12),
                SocialLoginButton(
                  provider: SocialProvider.apple,
                  onTap: () =>
                      ref.read(authProvider.notifier).signInWithAppleAccount(),
                ),

                const SizedBox(height: 28),

                // Divider
                Text('Or with email', style: AppTheme.labelLarge),

                const SizedBox(height: 12),

                // Email field
                AuthTextField(
                  hint: 'Your email address or profile URL',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
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
                    onPressed:
                        authState is AuthLoading ? null : _onContinue,
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
                            color: Colors.white, strokeWidth: 2)
                        : Text('Continue', style: AppTheme.labelLarge),
                  ),
                ),

                const SizedBox(height: 20),

                // Need help
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Need help?',
                    style: AppTheme.bodyMedium
                        .copyWith(color: AppTheme.link),
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