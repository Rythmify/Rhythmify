// lib/features/profile/presentation/widgets/blocked_user_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/profile_provider.dart';

/// Displayed on the profile page when the authenticated user has
/// blocked the target account.
///
/// Shows a minimal screen with no identifying information about the
/// blocked user — only a generic icon, a message, and an unblock option.
///
/// The [userId] is required so the unblock action can target the correct
/// account via `DELETE /users/{userId}/block`.
class BlockedUserScreen extends ConsumerWidget {
  /// The UUID of the blocked user.
  final String userId;

  /// Creates a [BlockedUserScreen] for the given [userId].
  const BlockedUserScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppTheme.appBarItems,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.block_rounded,
                  size: 40,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 24),

              // Headline 
              Text(
                'You blocked this account',
                style: AppTheme.titleMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Sub-message 
              Text(
                'You won\'t see their content and they can\'t see yours.',
                style: AppTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 36),

              //  Unblock button
              OutlinedButton(
                onPressed: () => _confirmUnblock(context, ref),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textPrimary,
                  side: BorderSide(color: AppTheme.surface),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text('Unblock', style: AppTheme.labelLarge),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows a confirmation dialog before unblocking the user.
  ///
  /// On confirmation, dispatches the unblock action through the provider
  /// and refreshes the profile page to show the real account info.
  Future<void> _confirmUnblock(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text('Unblock this account?', style: AppTheme.titleMedium),
        content: Text(
          'They will be able to see your profile and content again.',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: AppTheme.labelLarge.copyWith(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Unblock',
              style: AppTheme.labelLarge.copyWith(color: AppTheme.primaryBrand),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref
          .read(publicProfileProvider(userId).notifier)
          .unblockUser(userId);
      // Reload the profile to show the real content
      await ref
          .read(publicProfileProvider(userId).notifier)
          .loadProfile(userId: userId);
      await ref
          .read(publicProfileProvider(userId).notifier)
          .loadPreviews(userId);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
