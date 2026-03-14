import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/scaffold/main_app_scaffold.dart';
import '../../features/feed/presentation/pages/home_screen.dart';
import '../../features/feed/presentation/pages/feed_screen.dart';
import '../../features/search/presentation/pages/search_screen.dart';
import '../../features/library/presentation/pages/library_screen.dart';
import '../../features/premium/presentation/pages/upgrade_screen.dart';
import '../../features/messaging/presentation/pages/inbox_screen.dart';
import '../../features/messaging/presentation/pages/chat_screen.dart';
import '../../features/notifications/presentation/pages/notifications_screen.dart';
import '../../features/settings/presentation/pages/settings_screen.dart';
import '../../features/playlist/presentation/pages/playlist_screen.dart';

//added by hana
import 'package:rythmify/features/upload_track/presentation/screens/upload_track_screen.dart';

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



      //added by hana
            // ── ADD THIS ──────────────────────────────────────────────────
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey, // uses root navigator
        path: '/upload-track',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const UploadTrackScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Slides up from bottom — exactly like SoundCloud
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1), // starts from bottom
                end: Offset.zero,          // ends at normal position
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        ),
      ),

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
                routes: [
                  GoRoute(
                    path: 'inbox', 
                    builder: (context, state) => const InboxScreen(),
                    routes: [
                      GoRoute(
                        path: 'chat/:chatId', //change this to be 
                        builder: (context, state) => const ChatScreen(), //change this to be dynamic
                        //{
                          // final chatId = state.pathParameters['chatId'];
                          // return ChatScreen(chatId: chatId);
                        //},
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'notifications',
                    builder: (context, state) => const NotificationsScreen(),
                  ),
                ],
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
                routes: [
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) => const SettingsScreen(),
                  ),

                  //// this is dumy to be removed later
                  GoRoute(
                    path: 'playlist',
                    builder: (context, state) => const PlaylistScreen(),
                  ),
                ],
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