import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class EmailVerificationDialog extends ConsumerWidget {
  const EmailVerificationDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mark_email_unread_outlined,
                color: AppTheme.primaryBrand, size: 48),

            const SizedBox(height: 16),

            Text(
              'Verify your email',
              key: const Key('authentication_verify_email_title_text'),
              style: AppTheme.titleLarge,
            ),

            const SizedBox(height: 12),

            Text(
              'We sent a verification link to your email. Please check your inbox and verify before continuing.',
              key: const Key('authentication_verify_email_description_text'),
              textAlign: TextAlign.center,
              style: AppTheme.bodyMedium,
            ),

            const SizedBox(height: 24),

            // Resend button
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                key: const Key('authentication_resend_email_elevated_button'),
                onPressed: () =>
                    ref.read(authProvider.notifier).sendEmailVerification(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrand,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text('Resend email', style: AppTheme.labelLarge),
              ),
            ),

            const SizedBox(height: 12),

            // Dismiss button
            TextButton(
              key: const Key('authentication_dismiss_text_button'),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Dismiss',
                style:
                    AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
