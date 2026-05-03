import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

/// Confirmation dialog shown when leaving with unsaved profile edits.
class UnsavedChangesDialog extends StatelessWidget {
  const UnsavedChangesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure?',
              key: const Key('profile_unsaved_changes_title_text'),
              style: AppTheme.titleLarge,
            ),

            const SizedBox(height: 12),

            Text(
              'You have unsaved changes that will be lost',
              key: const Key('profile_unsaved_changes_description_text'),
              style: AppTheme.bodyMedium,
            ),

            const SizedBox(height: 24),

            // ── Discard Changes ──────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: TextButton(
                key: const Key('profile_unsaved_changes_discard_button'),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'DISCARD CHANGES',
                  style: AppTheme.labelLarge.copyWith(
                    color: AppTheme.primaryBrand,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),

            // ── Continue Editing ─────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: TextButton(
                key: const Key('profile_unsaved_changes_continue_button'),
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'CONTINUE EDITING',
                  style: AppTheme.labelLarge.copyWith(letterSpacing: 1.2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
