import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../authentication/presentation/providers/auth_state.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final currentUserEmail = authState is AuthAuthenticated
        ? authState.user.email
        : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        centerTitle: false,
        actions: [
          // ── GET PRO button ─────────────────────────────────────────
          TextButton(
            key: const Key('library_get_pro_text_button'),
            onPressed: () {},
            child: Text(
              'GET PRO',
              style: AppTheme.labelLarge.copyWith(
                color: AppTheme.primaryBrand,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          // ── Cast button ────────────────────────────────────────────
          IconButton(
            key: const Key('library_cast_icon_button'),
            icon: const Icon(Icons.cast),
            onPressed: () {},
          ),

          // ── Settings button ────────────────────────────────────────
          IconButton(
            key: const Key('library_settings_icon_button'),
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/library/settings'),
          ),

          // ── Profile avatar button ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              key: const Key('library_profile_avatar_gesture_detector'),
              onTap: () => context.push('/profile/me'),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.surface,
                child: const Icon(
                  Icons.person,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Library items ──────────────────────────────────────────
            _libraryItem(
              context,
              label: 'Your likes',
              onTap: () => context.push('/profile/me/likes'),
            ),
            _libraryItem(
              context,
              label: 'Playlists',
              onTap: () => context.push('/library/playlist'),
            ),
            _libraryItem(context, label: 'Albums', onTap: () {}),
            _libraryItem(context, label: 'Following', onTap: () {}),
            _libraryItem(context, label: 'Stations', onTap: () {}),
            _libraryItem(context, label: 'Your insights', onTap: () {}),

            const SizedBox(height: 16),

            // ── Logged in as ───────────────────────────────────────────
            if (currentUserEmail.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Logged in as $currentUserEmail',
                  style: AppTheme.labelSmall,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _libraryItem(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          key: Key('library_${label.toLowerCase().replaceAll(' ', '_')}_item_gesture_detector'),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Expanded(child: Text(label, style: AppTheme.titleMedium)),
                const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
              ],
            ),
          ),
        ),
        const Divider(color: AppTheme.surface, height: 1),
      ],
    );
  }
}
