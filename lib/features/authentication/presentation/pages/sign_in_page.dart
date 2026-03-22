import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_button.dart';

class SignInPage extends ConsumerStatefulWidget {
  final String mode; 

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

  void _onContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      if (widget.mode == 'register') {
        context.push('/create-account/password',
            extra: _emailController.text.trim());
      } else {
        context.push('/login/password',
            extra: _emailController.text.trim());
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
                SocialLoginButton(
                  key: const Key('auth_social_facebook_button'),
                  provider: SocialProvider.facebook,
                  onTap: () => ref
                      .read(authProvider.notifier)
                      .signInWithGoogleAccount(),
                ),
                const SizedBox(height: 12),
                SocialLoginButton(
                  key: const Key('auth_social_google_button'),
                  provider: SocialProvider.google,
                  onTap: () => ref
                      .read(authProvider.notifier)
                      .signInWithGoogleAccount(),
                ),
                const SizedBox(height: 12),
                SocialLoginButton(
                  key: const Key('auth_social_apple_button'),
                  provider: SocialProvider.apple,
                  onTap: () => ref
                      .read(authProvider.notifier)
                      .signInWithAppleAccount(),
                ),

                const SizedBox(height: 28),
                Text(
                  'Or with email', 
                  key: const Key('auth_email_divider_text'),
                  style: AppTheme.labelLarge
                ),

                const SizedBox(height: 12),
                AuthTextField(
                  key: const Key('auth_email_text_field_container'),
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
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    key: const Key('auth_continue_button'),
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
                GestureDetector(
                  key: const Key('auth_need_help_button'),
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