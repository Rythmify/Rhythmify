import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rythmify/features/messaging/data/repositories/mock_conversations.dart';
import 'package:rythmify/features/messaging/presentation/pages/likes_playlists_screen.dart';
import '../presentation/scaffold/main_app_scaffold.dart';

//  Auth imports
import '../../features/authentication/presentation/pages/onboarding_page.dart';
import '../../features/authentication/presentation/pages/sign_in_page.dart';
import '../../features/authentication/presentation/pages/create_account_password_page.dart';
import '../../features/authentication/presentation/pages/create_account_profile_page.dart';
import '../../features/authentication/presentation/pages/login_password_page.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';
import '../../features/authentication/presentation/providers/auth_state.dart';
import '../../features/authentication/presentation/pages/splash_screen.dart';

//  Profile imports
import '../../features/profile/presentation/pages/public_profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/likes_page.dart';

//  Feed imports
import '../../features/feed/presentation/pages/home_screen.dart';
import '../../features/feed/presentation/pages/feed_screen.dart';

//  Track imports
import '../../features/track/presentation/pages/behind_the_track.dart';
import '../../core/domain/entities/track.dart';

//  Player imports
import '../../features/player/presentation/pages/full_player_page.dart';

//  Comments imports
import '../../features/comments/presentation/pages/comments_screen.dart';

//  Messaging imports
import '../../features/messaging/domain/entities/conversation.dart';
import '../../features/messaging/presentation/pages/inbox_screen.dart';
import '../../features/messaging/presentation/pages/chat_screen.dart';
import '../../features/messaging/presentation/pages/search_screen.dart'
    as messaging;

//  Track_upload imports
import 'package:rythmify/features/track_upload/presentation/screens/upload_track_screen.dart';

// ── PLAYLIST imports (M14) ──────────────────────────────────────────────────
import '../../features/playlist/presentation/screens/library_playlists_screen.dart';
import '../../features/playlist/presentation/screens/playlist_detail_screen.dart';

//  Settings imports
import '../../features/settings/presentation/pages/settings_screen.dart';

//  Library imports
import '../../features/library/presentation/pages/library_screen.dart';
import '../../features/library/presentation/pages/following_page.dart';
import '../../features/library/presentation/pages/uploads_page.dart';
import '../../features/library/presentation/pages/stations_page.dart';
import '../../features/library/presentation/pages/albums_page.dart'; // NEW
import '../../features/library/presentation/pages/history_page.dart';
import '../../features/library/presentation/pages/insights_page.dart';

//  Search imports
import '../../features/search/presentation/pages/search_screen.dart';

//  Notifications imports
import '../../features/notifications/presentation/pages/notifications_screen.dart';

//  Premium imports
import '../../features/premium/presentation/pages/upgrade_screen.dart';

// ────────────────────────────────────────────────────────────────────────────

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeTabKey = GlobalKey<NavigatorState>(debugLabel: 'homeTab');
final _feedTabKey = GlobalKey<NavigatorState>(debugLabel: 'feedTab');
final _searchTabKey = GlobalKey<NavigatorState>(debugLabel: 'searchTab');
final _libraryTabKey = GlobalKey<NavigatorState>(debugLabel: 'libraryTab');
final _upgradeTabKey = GlobalKey<NavigatorState>(debugLabel: 'upgradeTab');

final routerProvider = Provider<GoRouter>((ref) {
  ref.listen(authProvider, (a, b) {});

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',

    redirect: (context, state) {
      final authState = ref.read(authProvider);

      final isAuthRoute =
          state.matchedLocation == '/onboarding' ||
          state.matchedLocation == '/sign-in' ||
          state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/create-account');

      if (authState is AuthLoading) return null;

      if (authState is AuthUnauthenticated || authState is AuthInitial) {
        if (!isAuthRoute) return '/onboarding';
        return null;
      }

      if (authState is AuthAuthenticated) {
        if (isAuthRoute) return '/home';
        return null;
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // ── Auth routes ──────────────────────────────────────────────────────
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

      // ── Profile routes ───────────────────────────────────────────────────
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
          // ── Home tab ───────────────────────────────────────────────────
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
                        builder: (context, state) {
                          final chatId = state.pathParameters['chatId']!;
                          final extra = state.extra;

                          if (extra is Conversation) {
                            return ChatScreen(conv: extra);
                          }

                          if (extra is Map<String, dynamic>) {
                            return ChatScreen(
                              conv: extra['conv'] as Conversation?,
                              newParticipantId:
                                  extra['newParticipantId'] as String?,
                              newParticipantName:
                                  extra['newParticipantName'] as String?,
                            );
                          }

                          final conv = mockConversations
                              .cast<Conversation?>()
                              .firstWhere(
                                (c) => c?.conversationId == chatId,
                                orElse: () => null,
                              );

                          return ChatScreen(conv: conv);
                        },
                        routes: [
                          GoRoute(
                            path: 'likes-playlists',
                            builder: (context, state) =>
                                const LikesPlaylistsScreen(),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'search',
                        builder: (context, state) =>
                            const messaging.SearchScreen(),
                      ),
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

          // ── Feed tab ───────────────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _feedTabKey,
            routes: [
              GoRoute(
                path: '/feed',
                builder: (context, state) => const FeedScreen(),
                routes: [
                  GoRoute(
                    path: 'behind-the-track/:trackId',
                    name: 'behindTheTrack',
                    builder: (context, state) {
                      final trackId = state.pathParameters['trackId']!;
                      return BehindTheTrackPage(trackId: trackId);
                    },
                  ),
                ],
              ),
            ],
          ),

          // ── Search tab ─────────────────────────────────────────────────
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

          // ── Library tab ────────────────────────────────────────────────
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
                  GoRoute(
                    path: 'behind-the-track/:trackId',
                    builder: (context, state) {
                      final trackId = state.pathParameters['trackId']!;
                      return BehindTheTrackPage(trackId: trackId);
                    },
                  ),
                  GoRoute(
                    path: 'following',
                    builder: (context, state) => const FollowingPage(),
                  ),

                  // ── Playlists ──────────────────────────────────────────
                  GoRoute(
                    path: 'playlists',
                    builder: (context, state) => const LibraryPlaylistsScreen(),
                  ),
                  GoRoute(
                    path: 'playlists/:playlistId',
                    builder: (context, state) {
                      final playlistId = state.pathParameters['playlistId']!;
                      final isOwner = state.extra as bool? ?? false;
                      return PlaylistDetailScreen(
                        playlistId: playlistId,
                        isOwner: isOwner,
                      );
                    },
                  ),

                  // ── Albums ─────────────────────────────────────────────
                  // AlbumsPage re-exports LibraryAlbumsScreen
                  GoRoute(
                    path: 'albums',
                    builder: (context, state) => const LibraryAlbumsScreen(),
                  ),
                  GoRoute(
                    path: 'albums/:playlistId',
                    builder: (context, state) {
                      final playlistId = state.pathParameters['playlistId']!;
                      final isOwner = state.extra as bool? ?? false;
                      return PlaylistDetailScreen(
                        playlistId: playlistId,
                        isOwner: isOwner,
                      );
                    },
                  ),

                  // ── Stations ───────────────────────────────────────────
                  // StationsPage re-exports LibraryStationsScreen
                  GoRoute(
                    path: 'stations',
                    builder: (context, state) => const LibraryStationsScreen(),
                  ),
                  GoRoute(
                    path: 'stations/:playlistId',
                    builder: (context, state) {
                      final playlistId = state.pathParameters['playlistId']!;
                      final isOwner = state.extra as bool? ?? false;
                      return PlaylistDetailScreen(
                        playlistId: playlistId,
                        isOwner: isOwner,
                      );
                    },
                  ),

                  GoRoute(
                    path: 'uploads',
                    builder: (context, state) => const UploadsPage(),
                  ),
                  GoRoute(
                    path: 'history',
                    builder: (context, state) => const HistoryPage(),
                  ),
                  GoRoute(
                    path: 'insights',
                    builder: (context, state) => const InsightsPage(),
                  ),
                ],
              ),
            ],
          ),

          // ── Upgrade tab ────────────────────────────────────────────────
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
        path: '/comments/:trackId',
        name: 'comments',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final track = state.extra as Track;
          return CommentsScreen(track: track);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/upload-track',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const UploadTrackScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
        ),
      ),
    ],
  );
});
