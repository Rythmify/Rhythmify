import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';
import '../widgets/auth_text_field.dart';

class CreateAccountPasswordPage extends ConsumerStatefulWidget {
  final String email;
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

  void _onContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      context.push('/create-account/profile', extra: {
        'email': widget.email,
        'password': _passwordController.text,
      });
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
                // Email display
                Text('Your email address', style: AppTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(widget.email, style: AppTheme.bodyLarge),

                const SizedBox(height: 24),

                // Password field
                AuthTextField(
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
                    return null;
                  },
                ),

                const SizedBox(height: 24),

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

                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Need help?',
                    style: AppTheme.bodyMedium
                        .copyWith(color: AppTheme.primaryBrand),
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