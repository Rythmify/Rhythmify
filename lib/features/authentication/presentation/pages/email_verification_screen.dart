import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';

/// Email verification required screen.
///
/// Shown immediately after registration. Blocks access to the app
/// until the user verifies their email address.
///
/// Features:
/// - Shows user's email address
/// - "Resend Email" button with cooldown
/// - "Check Verification" button to refresh status
/// - Cannot navigate away (blocks back button)
class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  bool _isResending = false;
  bool _isChecking = false;
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    // Automatically send verification email when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendVerificationEmail();
    });
  }

  Future<void> _sendVerificationEmail() async {
    if (_resendCooldown > 0) return;

    setState(() => _isResending = true);

    await ref.read(authProvider.notifier).sendEmailVerification();

    if (mounted) {
      setState(() {
        _isResending = false;
        _resendCooldown = 60; // 60 second cooldown
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email sent! Check your inbox.'),
          backgroundColor: Colors.green,
        ),
      );

      // Countdown timer
      _startCooldownTimer();
    }
  }

  void _startCooldownTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendCooldown > 0) {
        setState(() => _resendCooldown--);
        _startCooldownTimer();
      }
    });
  }

  Future<void> _checkVerification() async {
    setState(() => _isChecking = true);

    // Refresh auth status from backend
    await ref.read(authProvider.notifier).checkAuthStatus();

    final authState = ref.read(authProvider);

    if (mounted) {
      setState(() => _isChecking = false);

      if (authState is AuthAuthenticated && authState.user.isEmailVerified) {
        // Email verified! Navigate to home
        context.go('/home');
      } else {
        // Still not verified
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email not verified yet. Please check your inbox.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<bool> _onWillPop() async {
    // Block back button - user must verify email first
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please verify your email before continuing'),
        backgroundColor: Colors.orange,
      ),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),

                // Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1DB954).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_outlined,
                    size: 80,
                    color: Color(0xFF1DB954),
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                const Text(
                  'Verify Your Email',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  'We sent a verification email to:',
                  style: AppTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Email
                Text(
                  user?.email ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1DB954),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                Text(
                  'Click the link in the email to verify your account and get access to the app.',
                  style: AppTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // Check Verification Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    key: const Key('email_verification_check_button'),
                    onPressed: _isChecking ? null : _checkVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1DB954),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: _isChecking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle_outline),
                    label: Text(
                      _isChecking ? 'Checking...' : 'I\'ve Verified My Email',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Resend Email Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    key: const Key('email_verification_resend_button'),
                    onPressed: (_isResending || _resendCooldown > 0)
                        ? null
                        : _sendVerificationEmail,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textPrimary,
                      side: const BorderSide(color: AppTheme.textSecondary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: _isResending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.textSecondary,
                            ),
                          )
                        : const Icon(Icons.email_outlined),
                    label: Text(
                      _resendCooldown > 0
                          ? 'Resend in ${_resendCooldown}s'
                          : _isResending
                          ? 'Sending...'
                          : 'Resend Email',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Footer note
                Text(
                  'Check your spam folder if you don\'t see the email',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
