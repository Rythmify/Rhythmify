import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../domain/entities/google_auth_data.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';
import '../widgets/auth_text_field.dart';

/// Combined registration page supporting both email/password and Google OAuth flows.
///
/// When [googleData] is null:
/// - Shows traditional email/password registration form
/// - Requires password, confirm password, display name, gender, and date of birth
///
/// When [googleData] is provided (Google OAuth flow):
/// - Shows a "Continue with Google" banner with the user's avatar
/// - Email is pre-filled and read-only
/// - Display name is pre-filled
/// - Password fields are hidden
/// - Only requires gender and date of birth to complete registration
class RegisterPage extends ConsumerStatefulWidget {
  /// Google OAuth credentials if user signed in via Google; null for email/password registration.
  final GoogleAuthData? googleData;

  /// Creates a [RegisterPage].
  const RegisterPage({super.key, this.googleData});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedMonth;
  String? _selectedDay;
  String? _selectedYear;
  String? _selectedGender;

  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  final List<String> _genders = ['Male', 'Female'];

  @override
  void initState() {
    super.initState();
    // Pre-fill with Google data if available
    if (widget.googleData != null) {
      _emailController.text = widget.googleData!.email;
      _displayNameController.text = widget.googleData!.displayName ?? '';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  /// Formats date as YYYY-MM-DD for the backend.
  String _formatDate() {
    if (_selectedYear == null ||
        _selectedMonth == null ||
        _selectedDay == null) {
      return '2000-01-01';
    }
    final monthIndex = (_months.indexOf(_selectedMonth!) + 1)
        .toString()
        .padLeft(2, '0');
    final day = _selectedDay!.padLeft(2, '0');
    return '$_selectedYear-$monthIndex-$day';
  }

  /// Submits the registration form.
  ///
  /// For email/password flow: calls `POST /auth/register` then navigates to onboarding.
  /// For Google OAuth flow: calls `POST /auth/google` with id_token, then to onboarding if new user.
  void _onRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your gender')),
        );
        return;
      }
      if (_selectedYear == null ||
          _selectedMonth == null ||
          _selectedDay == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your date of birth')),
        );
        return;
      }

      // Age validation — must be 13 or older
      final dob = DateTime(
        int.parse(_selectedYear!),
        _months.indexOf(_selectedMonth!) + 1,
        int.parse(_selectedDay!),
      );
      final today = DateTime.now();
      final age =
          today.year -
          dob.year -
          ((today.month < dob.month ||
                  (today.month == dob.month && today.day < dob.day))
              ? 1
              : 0);

      if (age < 13) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You must be at least 13 years old to register'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return;
      }

      if (dob.isAfter(today)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Date of birth cannot be in the future'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return;
      }

      // Handle Google OAuth registration vs. email/password registration
      if (widget.googleData != null) {
        // Google OAuth flow: call POST /auth/google with id_token
        ref
            .read(authProvider.notifier)
            .signUpWithGoogle(
              idToken: widget.googleData!.idToken,
              gender: _selectedGender!.toLowerCase(),
              dateOfBirth: _formatDate(),
            );
      } else {
        // Email/password flow: call signUpWithEmailAndPassword
        ref
            .read(authProvider.notifier)
            .signUpWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              displayName: _displayNameController.text.trim(),
              gender: _selectedGender!.toLowerCase(),
              dateOfBirth: _formatDate(),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isGoogleFlow = widget.googleData != null;

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
      if (next is AuthEmailVerificationRequired) {
        context.go('/verify-email', extra: next.email);
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(isGoogleFlow ? 'Complete your profile' : 'Create account'),
        leading: IconButton(
          key: const Key('register_back_button'),
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Google OAuth banner
                if (isGoogleFlow)
                  Container(
                    key: const Key('register_google_banner'),
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: AppTheme.surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.surface, width: 1),
                    ),
                    child: Row(
                      children: [
                        // Google avatar
                        if (widget.googleData!.photoUrl != null)
                          Container(
                            key: const Key('register_google_avatar'),
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(
                                  widget.googleData!.photoUrl!,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        else
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.surface,
                            ),
                            child: Icon(
                              Icons.person,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Signing up with Google',
                                style: AppTheme.labelLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.googleData!.email,
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  // Email field (email/password flow only)
                  AuthTextField(
                    key: const Key('register_email_field'),
                    hint: 'Email address',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
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
                  const SizedBox(height: 12),
                  // Password field (email/password flow only)
                  AuthTextField(
                    key: const Key('register_password_field'),
                    hint: 'Password',
                    controller: _passwordController,
                    isPassword: true,
                    textInputAction: TextInputAction.next,
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
                  const SizedBox(height: 12),
                  // Confirm password field (email/password flow only)
                  AuthTextField(
                    key: const Key('register_confirm_password_field'),
                    hint: 'Confirm password',
                    controller: _confirmPasswordController,
                    isPassword: true,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                ],
                // Email field (pre-filled and read-only for Google flow)
                if (isGoogleFlow)
                  TextFormField(
                    key: const Key('register_google_email_field'),
                    controller: _emailController,
                    readOnly: true,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Email address',
                      hintStyle: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppTheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                if (isGoogleFlow) const SizedBox(height: 12),
                // Display name
                AuthTextField(
                  key: const Key('register_display_name_field'),
                  hint: 'Display name',
                  controller: _displayNameController,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a display name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Your display name can be anything you like.',
                  style: AppTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                // Date of birth
                Text('Date of birth (required)', style: AppTheme.labelLarge),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildDropdown(
                        key: const Key('register_month_dropdown'),
                        hint: 'Month',
                        value: _selectedMonth,
                        items: _months,
                        onChanged: (val) =>
                            setState(() => _selectedMonth = val),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: _buildDropdown(
                        key: const Key('register_day_dropdown'),
                        hint: 'Day',
                        value: _selectedDay,
                        items: List.generate(31, (i) => '${i + 1}'),
                        onChanged: (val) => setState(() => _selectedDay = val),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: _buildDropdown(
                        key: const Key('register_year_dropdown'),
                        hint: 'Year',
                        value: _selectedYear,
                        items: List.generate(
                          100,
                          (i) => '${DateTime.now().year - i}',
                        ),
                        onChanged: (val) => setState(() => _selectedYear = val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Your date of birth is used to verify your age.',
                  style: AppTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                // Gender
                _buildDropdown(
                  key: const Key('register_gender_dropdown'),
                  hint: 'Gender (required)',
                  value: _selectedGender,
                  items: _genders,
                  onChanged: (val) => setState(() => _selectedGender = val),
                ),
                const SizedBox(height: 32),
                // Register button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    key: const Key('register_submit_button'),
                    onPressed: authState is AuthLoading ? null : _onRegister,
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
                        : Text(
                            isGoogleFlow
                                ? 'Complete Registration'
                                : 'Create Account',
                            style: AppTheme.labelLarge,
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

  /// Builds a styled dropdown button.
  Widget _buildDropdown({
    Key? key,
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          key: key,
          value: value,
          hint: Text(hint, style: AppTheme.bodyMedium),
          isExpanded: true,
          dropdownColor: AppTheme.surface,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppTheme.textSecondary,
          ),
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
