import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rythmify/features/messaging/data/repositories/mock_conversations.dart';
import 'package:rythmify/features/messaging/presentation/pages/likes_playlists_screen.dart';
import 'package:rythmify/features/playlist/presentation/screens/playlist_screen.dart';
import 'package:rythmify/features/settings/presentation/pages/account_screen.dart';
import 'package:rythmify/features/settings/presentation/pages/add_widget_screen.dart';
import 'package:rythmify/features/settings/presentation/pages/app_icon_screen.dart';
import 'package:rythmify/features/settings/presentation/pages/imported_music_providers_screen.dart';
import 'package:rythmify/features/settings/presentation/pages/notification_settings_screen.dart';
import 'package:rythmify/features/settings/presentation/pages/social_settings_screen.dart';
import '../presentation/scaffold/main_app_scaffold.dart';

//  Auth imports
import '../../features/authentication/presentation/pages/onboarding_page.dart';
import '../../features/authentication/presentation/pages/sign_in_page.dart';
import '../../features/authentication/presentation/pages/create_account_password_page.dart';
import '../../features/authentication/presentation/pages/create_account_profile_page.dart';
import '../../features/authentication/presentation/pages/register_page.dart';
import '../../features/authentication/presentation/pages/login_password_page.dart';
import '../../features/authentication/presentation/pages/forgot_password_page.dart';
import '../../features/authentication/presentation/pages/verify_email_page.dart';
import '../../features/authentication/domain/entities/google_auth_data.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';
import '../../features/authentication/presentation/providers/auth_state.dart';
import '../../features/authentication/presentation/pages/splash_screen.dart';

//  Profile imports
import '../../features/profile/presentation/pages/public_profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/likes_page.dart';
import '../../features/profile/presentation/pages/uploaded_tracks_page.dart';
import '../../features/profile/presentation/pages/reposted_tracks_page.dart';
import '../../features/profile/presentation/pages/profile_connections_page.dart';
import '../../features/profile/domain/usecases/get_user_connections_usecase.dart';

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
import '../../features/playlist/presentation/screens/mix_detail_screen.dart';
import '../../features/playlist/presentation/screens/related_tracks_screen.dart';

//  Settings imports
import '../../features/settings/presentation/pages/settings_screen.dart';
import 'package:rythmify/features/settings/presentation/pages/advertising_settings_screen.dart';
import 'package:rythmify/features/settings/presentation/pages/analytics_settings_screen.dart';
import 'package:rythmify/features/settings/presentation/pages/basic_settings_screen.dart';
import 'package:rythmify/features/settings/presentation/pages/communication_settings_screen.dart';
import 'package:rythmify/features/settings/presentation/pages/import_my_music_screen.dart';
import 'package:rythmify/features/settings/presentation/pages/inbox_settings_screen.dart';
import 'package:rythmify/features/settings/presentation/pages/legal_settings_screen.dart';

//  Library imports
import '../../features/library/presentation/pages/library_screen.dart';
import '../../features/library/presentation/pages/following_page.dart';
import '../../features/library/presentation/pages/uploads_page.dart';
import '../../features/library/presentation/pages/stations_page.dart';
import '../../features/library/presentation/pages/albums_page.dart';
import '../../features/library/presentation/pages/history_page.dart';
import '../../features/library/presentation/pages/insights_page.dart';
import '../../features/library/presentation/pages/likes_page.dart';

//  Search imports
import '../../features/search/presentation/pages/search_screen.dart';

//  Notifications imports
import '../../features/notifications/presentation/pages/notifications_screen.dart';

//  Premium imports
import '../../features/premium/presentation/screens/upgrade_screen.dart';
import '../../features/premium/presentation/screens/upgrade_landing_screen.dart';

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
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/verify-email' ||
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

      if (authState is AuthEmailVerificationRequired) {
        if (!isAuthRoute) return '/verify-email';
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
        path: '/forgot-password',
        builder: (context, state) {
          final initialEmail = state.extra as String?;
          return ForgotPasswordPage(initialEmail: initialEmail);
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
      GoRoute(
        path: '/register',
        builder: (context, state) {
          final googleData = state.extra as GoogleAuthData?;
          return RegisterPage(googleData: googleData);
        },
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return VerifyEmailPage(email: email);
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
      GoRoute(
        path: '/profile/:userId/uploads',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return UploadedTracksPage(userId: userId);
        },
      ),
      GoRoute(
        path: '/profile/:userId/reposts',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return RepostedTracksPage(userId: userId);
        },
      ),
      GoRoute(
        path: '/profile/:userId/followers',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return ProfileConnectionsPage(
            userId: userId,
            type: ProfileConnectionsType.followers,
          );
        },
      ),
      GoRoute(
        path: '/profile/:userId/following',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return ProfileConnectionsPage(
            userId: userId,
            type: ProfileConnectionsType.following,
          );
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

                  // ── M14: Playlist/Album/Station/Mix/Related ────────────
                  // These are sub-routes of /home so they render INSIDE the
                  // shell — getting the real mini-player and real nav bar
                  // from MainAppScaffold automatically.
                  //
                  // Call with: context.push('/home/playlist/$id', extra: bool)
                  // Call with: context.push('/home/mix/$id', extra: {...})
                  // Call with: context.push('/home/station/$id', extra: {...})
                  // Call with: context.push('/home/related-tracks/$id', extra: {...})
                  GoRoute(
                    path: 'playlist/:playlistId',
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
                    path: 'mix/:mixId',
                    builder: (context, state) {
                      final mixId = state.pathParameters['mixId']!;
                      final extra = state.extra as Map<String, dynamic>? ?? {};
                      final mixTypeStr = extra['mixType'] as String? ?? 'genre';
                      final mixType = switch (mixTypeStr) {
                        'daily' => MixType.daily,
                        'weekly' => MixType.weekly,
                        _ => MixType.genre,
                      };
                      return MixDetailScreen(
                        mixId: mixId,
                        mixTitle: extra['title'] as String? ?? 'Your Mix',
                        ownerName: extra['ownerName'] as String? ?? 'You',
                        mixType: mixType,
                        coverUrl: extra['coverUrl'] as String?,
                        trackCount: extra['trackCount'] as int?,
                      );
                    },
                  ),

                  GoRoute(
                    path: 'related-tracks/:sourceId',
                    builder: (context, state) {
                      final sourceId = state.pathParameters['sourceId']!;
                      final extra = state.extra as Map<String, dynamic>? ?? {};
                      return RelatedTracksScreen(
                        sourceId: sourceId,
                        source: RelatedTracksSource.track,
                        basedOnName: extra['basedOnName'] as String? ?? '',
                        title: extra['title'] as String? ?? 'Related Tracks',
                        coverUrl: extra['coverUrl'] as String?,
                      );
                    },
                  ),

                  GoRoute(
                    path: 'station/:sourceId',
                    builder: (context, state) {
                      final sourceId = state.pathParameters['sourceId']!;
                      final extra = state.extra as Map<String, dynamic>? ?? {};
                      final artistName = extra['artistName'] as String? ?? '';
                      return RelatedTracksScreen(
                        sourceId: sourceId,
                        source: RelatedTracksSource.station,
                        basedOnName: artistName,
                        title: extra['stationName'] as String? ?? artistName,
                        coverUrl: extra['coverUrl'] as String?,
                      );
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
                    routes: [
                      GoRoute(
                        path: 'import-my-music',
                        builder: (context, state) =>
                            const ImportMyMusicScreen(),
                        routes: [
                          GoRoute(
                            path: 'music-providers',
                            builder: (context, state) =>
                                ImportedMusicProvidersScreen(
                                  appBarTitle: state.extra as String,
                                ),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'account',
                        builder: (context, state) => const AccountScreen(),
                      ),
                      GoRoute(
                        path: 'basic-settings',
                        builder: (context, state) =>
                            const BasicSettingsScreen(),
                        routes: [
                          GoRoute(
                            path: 'app-icons',
                            builder: (context, state) => const AppIconScreen(),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'social-settings',
                        builder: (context, state) =>
                            const SocialSettingsScreen(),
                      ),
                      GoRoute(
                        path: 'inbox-settings',
                        builder: (context, state) =>
                            const InboxSettingsScreen(),
                      ),
                      GoRoute(
                        path: 'notifications',
                        builder: (context, state) =>
                            const NotificationsSettingsScreen(),
                      ),
                      GoRoute(
                        path: 'add-widget',
                        builder: (context, state) => const AddWidgetScreen(),
                      ),
                      GoRoute(
                        path: 'analytics',
                        builder: (context, state) =>
                            const AnalyticsSettingsScreen(),
                      ),
                      GoRoute(
                        path: 'Communications',
                        builder: (context, state) =>
                            const CommunicationSettingsScreen(),
                      ),
                      GoRoute(
                        path: 'Advesrtising',
                        builder: (context, state) =>
                            const AdvertisingSettingsScreen(),
                      ),
                      GoRoute(
                        path: 'Legal',
                        builder: (context, state) =>
                            const LegalSettingsScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'playlist',
                    builder: (context, state) => const PlaylistScreen(),
                  ),
                  GoRoute(
                    path: 'following',
                    builder: (context, state) => const FollowingPage(),
                  ),
                  GoRoute(
                    name: 'library-playlists',
                    path: 'playlists',
                    builder: (context, state) => const LibraryPlaylistsScreen(),
                  ),
                  GoRoute(
                    name: 'library-albums',
                    path: 'albums',
                    builder: (context, state) => const LibraryAlbumsScreen(),
                  ),
                  GoRoute(
                    name: 'library-stations',
                    path: 'stations',
                    builder: (context, state) => const LibraryStationsScreen(),
                  ),
                  GoRoute(
                    name: 'library-detail',
                    path: ':type/:playlistId',
                    pageBuilder: (context, state) {
                      final type = state.pathParameters['type']!;
                      final playlistId = state.pathParameters['playlistId']!;
                      final isOwner = state.extra as bool? ?? false;
                      return MaterialPage(
                        key: ValueKey('library-detail-$type-$playlistId'),
                        child: PlaylistDetailScreen(
                          playlistId: playlistId,
                          isOwner: isOwner,
                        ),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'uploads',
                    builder: (context, state) => const UploadsPage(),
                  ),
                  GoRoute(
                    path: 'likes',
                    builder: (context, state) => const LibraryLikesPage(),
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
                builder: (context, state) => const UpgradeLandingScreen(),
                routes: [
                  GoRoute(
                    path: 'plans',
                    builder: (context, state) => const UpgradeScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // ── Root Level Pages (render ON TOP of nav bar — intentional) ────────
      GoRoute(
        path: '/behind-the-track/:trackId',
        name: 'behindTheTrack',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final trackId = state.pathParameters['trackId']!;
          return BehindTheTrackPage(trackId: trackId);
        },
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
