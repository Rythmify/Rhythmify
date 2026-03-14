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
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  final List<String> _genders = [
    'Male', 'Female', 'Non-binary', 'Prefer not to say'
  ];

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authProvider.notifier).signUpWithEmailAndPassword(
            email: widget.email,
            password: widget.password,
            displayName: _displayNameController.text.trim(),
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
                  'Your display name can be anything you like. Your name or artist name are good choices.',
                  style: AppTheme.bodyMedium,
                ),

                const SizedBox(height: 24),

                // Date of birth
                Text(
                  'Date of birth (required)',
                  style: AppTheme.labelLarge,
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    // Month
                    Expanded(
                      flex: 3,
                      child: _buildDropdown(
                        hint: 'Month',
                        value: _selectedMonth,
                        items: _months,
                        onChanged: (val) =>
                            setState(() => _selectedMonth = val),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Day
                    Expanded(
                      flex: 2,
                      child: _buildDropdown(
                        hint: 'Day',
                        value: _selectedDay,
                        items: List.generate(31, (i) => '${i + 1}'),
                        onChanged: (val) =>
                            setState(() => _selectedDay = val),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Year
                    Expanded(
                      flex: 2,
                      child: _buildDropdown(
                        hint: 'Year',
                        value: _selectedYear,
                        items: List.generate(100,
                            (i) => '${DateTime.now().year - i}'),
                        onChanged: (val) =>
                            setState(() => _selectedYear = val),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  'Your date of birth is used to verify your age and is not shared publicly.',
                  style: AppTheme.bodyMedium,
                ),

                const SizedBox(height: 24),

                // Gender
                _buildDropdown(
                  hint: 'Gender (required)',
                  value: _selectedGender,
                  items: _genders,
                  onChanged: (val) => setState(() => _selectedGender = val),
                ),

                const SizedBox(height: 32),

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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
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
          value: value,
          hint: Text(hint, style: AppTheme.bodyMedium),
          isExpanded: true,
          dropdownColor: AppTheme.surface,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppTheme.textSecondary),
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}