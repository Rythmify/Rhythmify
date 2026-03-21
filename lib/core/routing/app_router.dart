import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../presentation/scaffold/main_app_scaffold.dart';

//  Auth imports
import '../../features/authentication/presentation/pages/onboarding_page.dart';
import '../../features/authentication/presentation/pages/sign_in_page.dart';
import '../../features/authentication/presentation/pages/create_account_password_page.dart';
import '../../features/authentication/presentation/pages/create_account_profile_page.dart';

//  Profile imports
import '../../features/profile/presentation/pages/public_profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/likes_page.dart';
import '../../features/authentication/presentation/pages/login_password_page.dart';

//  Feed imports
import '../../features/feed/presentation/pages/home_screen.dart';
import '../../features/feed/presentation/pages/feed_screen.dart';

//  Track imports
import '../../features/track/presentation/pages/behind_the_track.dart';

//  Player imports
import '../../features/player/presentation/pages/full_player_page.dart';

//  Messaging imports
import '../../features/messaging/presentation/pages/inbox_screen.dart';
import '../../features/messaging/presentation/pages/chat_screen.dart';
import '../../features/messaging/data/repositories/mock_conversations.dart';

//  Track_upload imports
import 'package:rythmify/features/track_upload/presentation/screens/upload_track_screen.dart';

//  Playlist imports
import '../../features/playlist/presentation/pages/playlist_screen.dart';

//  Settings imports
import '../../features/settings/presentation/pages/settings_screen.dart';

//  Library imports
import '../../features/library/presentation/pages/library_screen.dart';

//  Search imports
import '../../features/search/presentation/pages/search_screen.dart';

//  Notifications imports
import '../../features/notifications/presentation/pages/notifications_screen.dart';

//  Premium imports
import '../../features/premium/presentation/pages/upgrade_screen.dart';

///----------------------------------------------------------------------------------------------///

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
      //  Profile routes  
    // ── Auth routes ──────────────────────────────────────────
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/sign-in',
      builder: (context, state) {
        final mode = state.extra as String? ?? 'login';
        return SignInPage(mode: mode);
      },
    ),
    GoRoute(
      path: '/login/password',
      builder: (context, state) {
        final email = state.extra as String;
        return LoginPasswordPage(email: email);
      },
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

    // ── Profile routes ───────────────────────────────────────
    // CRITICAL: /profile/edit MUST be before /profile/:userId
    GoRoute(
      path: '/profile/edit',
      builder: (context, state) => const EditProfilePage(),
    ),
    GoRoute(
      path: '/profile/:userId',
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        return PublicProfilePage(userId: userId);
      },
    ),
    GoRoute(
      path: '/profile/:userId/likes',
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        return LikesPage(userId: userId);
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
                        path: 'chat/:chatId',
///mock datasources     // builder: (context, state) {
                        //   final chatId = state.pathParameters['chatId']!;
                        //   final conv = mockConversations.firstWhere(
                        //     (c) => c.conversationId == chatId,
                        //   );

                        //   return ChatScreen(conv: conv);
                        // },
                        builder:(context,state){
                          final conv= state.extra as Conversation;
                          return ChatScreen(conv: conv);
                        }
                      ),
                      GoRoute(
                        path: 'search',
                        builder:(context, state) => const messaging.SearchScreen(),
                      )
                    ],
                  ),
                  GoRoute(
                    path: 'notifications',
                    builder: (context, state) => const NotificationsScreen(),
                  ),
                  GoRoute(
                    path: 'behind-the-track/:trackId',
                    builder: (context, state) {
                      final trackId = state.pathParameters['trackId']!;
                      return BehindTheTrackPage(trackId: trackId);
                    },
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
                routes: [
                  GoRoute(
                    path: 'behind-the-track/:trackId',
                    name: 'behindTheTrack', // <-- Add this exact name!
                    builder: (context, state) {
                      final trackId = state.pathParameters['trackId']!;
                      return BehindTheTrackPage(trackId: trackId);
                    },
                  )
                ],
              ),
            ],
          ),

          StatefulShellBranch(
            navigatorKey: _searchTabKey,
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const SearchScreen(),
                routes: [
                  GoRoute(
                    path: 'behind-the-track/:trackId',
                    builder: (context, state) {
                      final trackId = state.pathParameters['trackId']!;
                      return BehindTheTrackPage(trackId: trackId);
                    },
                  ),
                ],
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

                  GoRoute(
                    path: 'behind-the-track/:trackId',
                    builder: (context, state) {
                      final trackId = state.pathParameters['trackId']!;
                      return BehindTheTrackPage(trackId: trackId);
                    },
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
                routes: [
                  GoRoute(
                    path: 'behind-the-track/:trackId',
                    builder: (context, state) {
                      final trackId = state.pathParameters['trackId']!;
                      return BehindTheTrackPage(trackId: trackId);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      
      GoRoute(
        path: '/player',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FullPlayerPage(),
      ),
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
    ],
  );
});