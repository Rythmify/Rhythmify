/// Account creation step for collecting display name and initial profile data.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';
import '../widgets/auth_text_field.dart';

class CreateAccountProfilePage extends ConsumerStatefulWidget {
  final String email;
  final String password;

  const CreateAccountProfilePage({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  ConsumerState<CreateAccountProfilePage> createState() =>
      _CreateAccountProfilePageState();
}

class _CreateAccountProfilePageState
    extends ConsumerState<CreateAccountProfilePage> {
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
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  // ── Format date as YYYY-MM-DD ─────────────────────────────
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

  void _onContinue() {
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

      // ── Age validation — must be 13 or older ─────────────────
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be at least 13 years old to register'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      if (dob.isAfter(today)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Date of birth cannot be in the future'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      ref
          .read(authProvider.notifier)
          .signUpWithEmailAndPassword(
            email: widget.email,
            password: widget.password,
            displayName: _displayNameController.text.trim(),
            gender: _selectedGender!.toLowerCase(),
            dateOfBirth: _formatDate(),
          );
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
      appBar: AppBar(
        title: const Text('Tell us more about you'),
        leading: IconButton(
          key: const Key(
            'authentication_create_account_profile_back_icon_button',
          ),
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
                // Display name
                AuthTextField(
                  key: const Key(
                    'authentication_create_account_profile_display_name_auth_text_field',
                  ),
                  hint: 'Display name',
                  controller: _displayNameController,
                  textInputAction: TextInputAction.done,
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
                        key: const Key(
                          'authentication_create_account_profile_month_dropdown_button',
                        ),
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
                        key: const Key(
                          'authentication_create_account_profile_day_dropdown_button',
                        ),
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
                        key: const Key(
                          'authentication_create_account_profile_year_dropdown_button',
                        ),
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
                  key: const Key(
                    'authentication_create_account_profile_gender_dropdown_button',
                  ),
                  hint: 'Gender (required)',
                  value: _selectedGender,
                  items: _genders,
                  onChanged: (val) => setState(() => _selectedGender = val),
                ),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    key: const Key(
                      'authentication_create_account_profile_continue_elevated_button',
                    ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

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
