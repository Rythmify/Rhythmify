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

    final currentUserId =
        authState is AuthAuthenticated ? authState.user.id : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        centerTitle: false,
        actions: [
          // ── GET PRO button ─────────────────────────────────────────
          TextButton(
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
            icon: const Icon(Icons.cast),
            onPressed: () {},
          ),

          // ── Settings button ────────────────────────────────────────
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/library/settings'),
          ),

          // ── Profile avatar button ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                if (currentUserId != null) {
                 context.push('/profile/$currentUserId');
                }
              },
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.surface,
                child: Icon(
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Library items ──────────────────────────────────────────
              _libraryItem(
                context,
                label: 'Your likes',
                onTap: () {
                  if (currentUserId != null) {
                    context.push('/profile/$currentUserId/likes');
                  }
                },
              ),
              _libraryItem(
                context,
                label: 'Playlists',
                onTap: () => context.push('/library/playlist'),
              ),
              _libraryItem(
                context,
                label: 'Albums',
                onTap: () {},
              ),
              _libraryItem(
                context,
                label: 'Following',
                onTap: () {},
              ),
              _libraryItem(
                context,
                label: 'Stations',
                onTap: () {},
              ),
              _libraryItem(
                context,
                label: 'Your insights',
                onTap: () {},
              ),

              const SizedBox(height: 32),

              // ── Dev testing — Team Profiles ────────────────────────────
              Text('Team Profiles (Dev)', style: AppTheme.labelLarge),
              const SizedBox(height: 8),

              _profileButton(
                context,
                label: 'Bassel Alaa',
                subtitle: 'user-002 · Cairo, Egypt',
                onTap: () => context.push('/profile/user-002'),
              ),
              const SizedBox(height: 8),
              _profileButton(
                context,
                label: 'Mohammed Al Abasy',
                subtitle: 'user-003 · Alexandria, Egypt',
                onTap: () => context.push('/profile/user-003'),
              ),
              const SizedBox(height: 8),
              _profileButton(
                context,
                label: 'Rana Elgharabawy',
                subtitle: 'user-004 · Cairo, Palestine',
                onTap: () => context.push('/profile/user-004'),
              ),
              const SizedBox(height: 8),
              _profileButton(
                context,
                label: '~H',
                subtitle: 'user-005 · Cairo, Egypt',
                onTap: () => context.push('/profile/user-005'),
              ),
              const SizedBox(height: 8),
              _profileButton(
                context,
                label: '~sohaila',
                subtitle: 'user-006 · Cairo, Egypt',
                onTap: () => context.push('/profile/user-006'),
              ),
            ],
          ),
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
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(label, style: AppTheme.titleMedium),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
          ),
        ),
        const Divider(
          color: AppTheme.surface,
          height: 1,
        ),
      ],
    );
  }

  Widget _profileButton(
    BuildContext context, {
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
       onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.person_outline,
              color: AppTheme.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTheme.labelLarge),
                  Text(subtitle, style: AppTheme.labelSmall),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}