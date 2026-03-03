import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/scaffold/main_app_scaffold.dart';
import '../../features/feed/presentation/pages/home_screen.dart';
import '../../features/feed/presentation/pages/feed_screen.dart';
import '../../features/search/presentation/pages/search_screen.dart';
import '../../features/library/presentation/pages/library_screen.dart';
import '../../features/premium/presentation/pages/upgrade_screen.dart';

// Keys to track the state of each tab
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeTabKey = GlobalKey<NavigatorState>(debugLabel: 'homeTab');
final _feedTabKey = GlobalKey<NavigatorState>(debugLabel: 'feedTab');
final _searchTabKey = GlobalKey<NavigatorState>(debugLabel: 'searchTab');
final _libraryTabKey = GlobalKey<NavigatorState>(debugLabel: 'libraryTab');
final _upgradeTabKey = GlobalKey<NavigatorState>(debugLabel: 'upgradeTab');

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    
    routes: [

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainAppScaffold(navigationShell: navigationShell);
        },
        branches: [

          StatefulShellBranch(
            navigatorKey: _homeTabKey,
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          
          StatefulShellBranch(
            navigatorKey: _feedTabKey,
            routes: [
              GoRoute(
                path: '/feed',
                builder: (context, state) => const FeedScreen(),
              ),
            ],
          ),

          StatefulShellBranch(
            navigatorKey: _searchTabKey,
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),

          StatefulShellBranch(
            navigatorKey: _libraryTabKey,
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) => const LibraryScreen(),
              ),
            ],
          ),

          StatefulShellBranch(
            navigatorKey: _upgradeTabKey,
            routes: [
              GoRoute(
                path: '/upgrade',
                builder: (context, state) => const UpgradeScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});