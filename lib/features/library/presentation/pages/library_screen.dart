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
    final currentUserEmail = authState is AuthAuthenticated ? authState.user.email : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        centerTitle: false,
        actions: [
          TextButton(
            key: const Key('library_get_pro_text_button'),
            onPressed: () => context.push('/upgrade'),
            child: Text(
              'GET PRO',
              style: AppTheme.labelLarge.copyWith(
                color: AppTheme.primaryBrand,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            key: const Key('library_cast_icon_button'),
            icon: const Icon(Icons.cast),
            onPressed: () {},
          ),
          IconButton(
            key: const Key('library_settings_icon_button'),
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/library/settings'),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              key: const Key('library_profile_avatar_gesture_detector'),
              onTap: () => context.push('/profile/me'),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.surface,
                child: Icon(Icons.person, color: AppTheme.textSecondary, size: 20),
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
            _libraryItem(context, label: 'Your likes', icon: Icons.favorite_border, key: const Key('library_likes_item'), onTap: () => context.push('/profile/me/likes')),
            _libraryItem(context, label: 'Recently played', icon: Icons.history, key: const Key('library_history_item'), onTap: () => context.push('/library/history')),
            _libraryItem(context, label: 'Playlists', icon: Icons.queue_music, key: const Key('library_playlists_item'), onTap: () => context.push('/library/playlists')),
            _libraryItem(context, label: 'Albums', icon: Icons.album_outlined, key: const Key('library_albums_item'), onTap: () {}),
            _libraryItem(context, label: 'Following', icon: Icons.people_outline, key: const Key('library_following_item'), onTap: () => context.push('/library/following')),
            _libraryItem(context, label: 'Stations', icon: Icons.radio, key: const Key('library_stations_item'), onTap: () => context.push('/library/stations')),
            _libraryItem(context, label: 'Your uploads', icon: Icons.cloud_upload_outlined, key: const Key('library_uploads_item'), onTap: () => context.push('/library/uploads')),
            _libraryItem(context, label: 'Your insights', icon: Icons.bar_chart, key: const Key('library_insights_item'), onTap: () => context.push('/library/insights')),

            const SizedBox(height: 16),
            if (currentUserEmail.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('Logged in as $currentUserEmail', style: AppTheme.labelSmall),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => ref.read(authProvider.notifier).signOutUser(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('DEV LOGOUT'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _libraryItem(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    Key? key,
  }) {
    return Column(
      children: [
        GestureDetector(
          key: key,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.textSecondary, size: 22),
                const SizedBox(width: 14),
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
