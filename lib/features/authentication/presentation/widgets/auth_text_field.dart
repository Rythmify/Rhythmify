import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

/// A styled text input field used across all authentication screens.
///
/// Supports optional password obscuring with a visibility toggle icon.
/// Applies [AppTheme] styles for consistent appearance throughout the
/// authentication flow.
///
/// Example usage:
/// ```dart
/// AuthTextField(
///   hint: 'Your email address',
///   controller: _emailController,
///   keyboardType: TextInputType.emailAddress,
///   validator: (value) => value?.isEmpty == true ? 'Required' : null,
/// )
/// ```
class AuthTextField extends StatefulWidget {
  /// The placeholder text shown when the field is empty.
  final String hint;

  /// Whether the field should obscure text for password input.
  ///
  /// When `true`, a visibility toggle icon appears in the suffix.
  /// Defaults to `false`.
  final bool isPassword;

  /// The controller managing the text content of this field.
  final TextEditingController controller;

  /// An optional validator function for form validation.
  ///
  /// Return a non-null string to show a validation error.
  /// Return `null` to indicate the input is valid.
  final String? Function(String?)? validator;

  /// The keyboard type to display when this field is focused.
  ///
  /// Defaults to [TextInputType.text].
  final TextInputType keyboardType;

  /// The action button shown on the keyboard.
  ///
  /// Defaults to [TextInputAction.next].
  final TextInputAction textInputAction;

  /// Creates an [AuthTextField].
  const AuthTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.isPassword = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  /// Whether the password text is currently hidden.
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: Key(
          'auth_${widget.hint.toLowerCase().replaceAll(' ', '_')}_text_field'),
      controller: widget.controller,
      obscureText: widget.isPassword && _obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: AppTheme.bodyMedium,
        filled: true,
        fillColor: AppTheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppTheme.primaryBrand,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        // Password visibility toggle
        suffixIcon: widget.isPassword
            ? IconButton(
                key: const Key('auth_password_visibility_icon_button'),
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscureText = !_obscureText),
              )
            : null,
      ),
    );
  }
}
