// lib/features/playlist/presentation/widgets/playlist_screen_scaffold.dart
//
// Wraps any root-level playlist screen (PlaylistDetailScreen, MixDetailScreen,
// RelatedTracksScreen) and adds:
//   1. Mini-player bar above the nav bar (when a track is active)
//   2. A bottom nav bar replica so the user can still switch tabs
//
// Why needed: these screens use parentNavigatorKey: _rootNavigatorKey so they
// render ABOVE MainAppScaffold. The scaffold's mini-player and nav bar are
// underneath and invisible. This widget re-adds both locally.

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../player/presentation/providers/player_provider.dart';
import '../../../player/presentation/widgets/mini_player.dart';

// Heights must match MainAppScaffold exactly
const double _navBarHeight = 85.0;
const double _miniPlayerHeight = 65.0;

class PlaylistScreenScaffold extends ConsumerWidget {
  const PlaylistScreenScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasTrack = ref.watch(
      playerStateProvider.select((s) => s.currentTrack != null),
    );

    final bottomPadding = hasTrack
        ? _miniPlayerHeight + _navBarHeight
        : _navBarHeight;

    return Stack(
      children: [
        // ── Screen content — padded so it doesn't go behind player/nav ──
        Positioned.fill(
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              padding: MediaQuery.of(context).padding.copyWith(
                bottom: bottomPadding,
              ),
            ),
            child: child,
          ),
        ),

        // ── Mini-player — sits just above the nav bar ────────────────────
        if (hasTrack)
          Positioned(
            left: 0,
            right: 0,
            bottom: _navBarHeight,
            height: _miniPlayerHeight,
            child: MiniPlayer(
              onTap: () => context.push('/player'),
            ),
          ),

        // ── Nav bar replica ───────────────────────────────────────────────
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: _navBarHeight,
          child: _BottomNavBar(),
        ),
      ],
    );
  }
}

// ── Nav bar replica ───────────────────────────────────────────────────────────
// Mirrors the tabs from MainAppScaffold so the user can navigate away.
// Uses GoRouter context.go() to switch tabs.
class _BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    // Determine active tab from current route
    int activeIndex = 0;
    if (location.startsWith('/feed')) activeIndex = 1;
    else if (location.startsWith('/search')) activeIndex = 2;
    else if (location.startsWith('/library')) activeIndex = 3;
    else if (location.startsWith('/upgrade')) activeIndex = 4;
    // Playlist/mix/station routes don't match any tab — keep home highlighted
    // unless we came from library (not easily detectable, so default to home)

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: _navBarHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                active: activeIndex == 0,
                onTap: () => context.go('/home'),
              ),
              _NavItem(
                icon: Icons.queue_music_outlined,
                activeIcon: Icons.queue_music,
                label: 'Feed',
                active: activeIndex == 1,
                onTap: () => context.go('/feed'),
              ),
              _NavItem(
                icon: Icons.search_outlined,
                activeIcon: Icons.search,
                label: 'Search',
                active: activeIndex == 2,
                onTap: () => context.go('/search'),
              ),
              _NavItem(
                icon: Icons.library_music_outlined,
                activeIcon: Icons.library_music,
                label: 'Library',
                active: activeIndex == 3,
                onTap: () => context.go('/library'),
              ),
              _NavItem(
                icon: Icons.workspace_premium_outlined,
                activeIcon: Icons.workspace_premium,
                label: 'Premium',
                active: activeIndex == 4,
                onTap: () => context.go('/upgrade'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFFFF5500);
    const inactiveColor = Colors.grey;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              active ? activeIcon : icon,
              color: active ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: active ? activeColor : inactiveColor,
                fontSize: 11,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}