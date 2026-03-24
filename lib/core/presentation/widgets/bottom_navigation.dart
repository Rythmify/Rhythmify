import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_theme.dart';

class BottomNavigation extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const BottomNavigation({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  String _iconPath(String name) => 'assets/icons/$name.svg';

  Widget _inactiveIcon(String assetName) {
    return SvgPicture.asset(
      _iconPath(assetName),
      width: 24,
      height: 24,
      colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
    );
  }

  Widget _activeIcon(String assetName) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        // Slight icon scale animation
        return Transform.scale(scale: 0.8 + (value * 0.2), child: child);
      },

      child: SvgPicture.asset(
        _iconPath(assetName),
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context),
      child: BottomNavigationBar(
        key: const Key('main_bottom_nav_bar'),
        backgroundColor: AppTheme.surface,
        type: BottomNavigationBarType.fixed,
        currentIndex: navigationShell.currentIndex,
        selectedItemColor: Colors.white,
        showSelectedLabels: true,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedFontSize: 11.0,
        selectedLabelStyle: AppTheme.labelSmall,
        unselectedFontSize: 11.0,
        unselectedLabelStyle: AppTheme.labelSmall,
        onTap: _onTap,

        items: [
          BottomNavigationBarItem(
            icon: _inactiveIcon('home_outlined'),
            activeIcon: _activeIcon('home'),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: _inactiveIcon('feed_outlined'),
            activeIcon: _activeIcon('feed'),
            label: 'Feed',
          ),

          BottomNavigationBarItem(
            icon: _inactiveIcon('search_outlined'),
            activeIcon: _activeIcon('search'),
            label: 'Search',
          ),

          BottomNavigationBarItem(
            icon: _inactiveIcon('library_outlined'),
            activeIcon: _activeIcon('library'),
            label: 'Library',
          ),

          BottomNavigationBarItem(
            icon: _inactiveIcon('logo'),
            activeIcon: _activeIcon('logo'),
            label: 'Upgrade',
          ),
        ],
      ),
    );
  }
}
