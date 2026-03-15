import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

class UnsavedChangesDialog extends StatelessWidget {
  const UnsavedChangesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure?',
              style: AppTheme.titleLarge,
            ),

            const SizedBox(height: 12),

            Text(
              'You have unsaved changes that will be lost',
              style: AppTheme.bodyMedium,
            ),

            const SizedBox(height: 24),

            // ── Discard Changes ──────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: TextButton(
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
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'CONTINUE EDITING',
                  style: AppTheme.labelLarge.copyWith(
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}