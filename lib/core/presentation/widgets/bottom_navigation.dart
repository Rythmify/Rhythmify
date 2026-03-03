import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class BottomNavigation extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const BottomNavigation({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(

      backgroundColor: AppTheme.surface,
      type: BottomNavigationBarType.fixed,
      currentIndex: navigationShell.currentIndex,
      selectedItemColor: AppTheme.primaryBrand,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      onTap: _onTap,
      items: const [

        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.web_stories_outlined),
          activeIcon: Icon(Icons.web_stories),
          label: 'Feed',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.search_outlined),
          activeIcon: Icon(Icons.search),
          label: 'Search',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.library_music_outlined),
          activeIcon: Icon(Icons.library_music),
          label: 'Library',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.diamond_outlined),
          activeIcon: Icon(Icons.diamond),
          label: 'Upgrade',
        ),


      ],
    );
  }
}