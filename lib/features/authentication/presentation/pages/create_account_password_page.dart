import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';
import '../widgets/auth_text_field.dart';

/// The password creation screen for new user registration.
///
/// Receives the user's [email] from [SignInPage] and prompts them
/// to create a password that meets the platform's security requirements:
/// - Minimum 8 characters
/// - At least one uppercase letter
/// - At least one lowercase letter
/// - At least one number
///
/// On valid input, navigates to `/create-account/profile` passing
/// both email and password.
class CreateAccountPasswordPage extends ConsumerStatefulWidget {
  /// The email address entered on the previous [SignInPage].
  final String email;

  /// Creates a [CreateAccountPasswordPage] with the given [email].
  const CreateAccountPasswordPage({super.key, required this.email});

  @override
  ConsumerState<CreateAccountPasswordPage> createState() =>
      _CreateAccountPasswordPageState();
}

class _CreateAccountPasswordPageState
    extends ConsumerState<CreateAccountPasswordPage> {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  /// Validates the password and navigates to the profile creation step.
  ///
  /// Password requirements:
  /// - At least 8 characters
  /// - Contains uppercase letter
  /// - Contains lowercase letter
  /// - Contains a digit
  void _onContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      context.push(
        '/create-account/profile',
        extra: {'email': widget.email, 'password': _passwordController.text},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Create an account'),
        leading: IconButton(
          key: const Key('authentication_back_icon_button'),
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your email address', style: AppTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(widget.email, style: AppTheme.bodyLarge),
                const SizedBox(height: 24),
                AuthTextField(
                  key: const Key('authentication_password_text_field'),
                  hint: 'Choose a password (min. 8 characters)',
                  controller: _passwordController,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    if (!value.contains(RegExp(r'[A-Z]'))) {
                      return 'Password must contain an uppercase letter';
                    }
                    if (!value.contains(RegExp(r'[a-z]'))) {
                      return 'Password must contain a lowercase letter';
                    }
                    if (!value.contains(RegExp(r'[0-9]'))) {
                      return 'Password must contain a number';
                    }
                    return null;
                  },
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    if (!value.contains(RegExp(r'[A-Z]'))) {
                      return 'Password must contain an uppercase letter';
                    }
                    if (!value.contains(RegExp(r'[a-z]'))) {
                      return 'Password must contain a lowercase letter';
                    }
                    if (!value.contains(RegExp(r'[0-9]'))) {
                      return 'Password must contain a number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 50),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    key: const Key(
                        'authentication_continue_elevated_button'),
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
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : Text('Continue', style: AppTheme.labelLarge),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  key: const Key('authentication_help_gesture_detector'),
                  onTap: () {},
                  child: Text(
                    'Need help?',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.primaryBrand,
                    ),
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
