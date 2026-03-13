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

// ── Auth imports (Module 1 - Karim CP-5) ──
import '../../features/authentication/presentation/pages/onboarding_page.dart';
import '../../features/authentication/presentation/pages/sign_in_page.dart';
import '../../features/authentication/presentation/pages/create_account_password_page.dart';
import '../../features/authentication/presentation/pages/create_account_profile_page.dart';

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
    initialLocation: '/onboarding',

    routes: [

      // ── Auth routes (outside the shell, no bottom nav bar) ──
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: '/create-account/password',
        builder: (context, state) {
          final email = state.extra as String;
          return CreateAccountPasswordPage(email: email);
        },
      ),
      GoRoute(
        path: '/create-account/profile',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return CreateAccountProfilePage(
            email: data['email'] as String,
            password: data['password'] as String,
          );
        },
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