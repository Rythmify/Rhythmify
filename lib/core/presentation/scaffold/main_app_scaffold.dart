import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/bottom_navigation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/notifications/presentation/providers/notifications_provider.dart';
import '../../../../features/player/presentation/widgets/mini_player.dart';
import '../../../../features/player/presentation/pages/full_player_page.dart';
import '../../../../features/player/presentation/providers/player_provider.dart';
import '../../../features/feed/presentation/providers/feed_providers.dart';

class MainAppScaffold extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainAppScaffold({super.key, required this.navigationShell});

  @override
  ConsumerState<MainAppScaffold> createState() => _MainAppScaffoldState();
}

class _MainAppScaffoldState extends ConsumerState<MainAppScaffold> {
  final DraggableScrollableController _draggableController =
      DraggableScrollableController();

  // Heights in logical pixels
  static const double _navBarHeight = 70.0;
  static const double _miniPlayerHeight = 80.0;

  double get _minSize {
    if (!context.mounted) return 0.08;
    final screenHeight = MediaQuery.of(context).size.height;
    return screenHeight > 0
        ? (_navBarHeight + _miniPlayerHeight) / screenHeight
        : 0.15;
  }

  static const double _maxSize = 1.0;

  void _expandPlayer() {
    if (!_draggableController.isAttached) return;

    // Small delay to let queueStateProvider sync with playerStateProvider
    Future.delayed(const Duration(milliseconds: 80), () {
      if (!_draggableController.isAttached) return;
      _draggableController.animateTo(
        _maxSize,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void _collapsePlayer() {
    if (_draggableController.isAttached) {
      _draggableController.animateTo(
        _minSize,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        playerSheetNotifier.value = _expandPlayer;
        playerCollapseNotifier.value = _collapsePlayer;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(notificationSocketProvider);
    // ONLY watch the track ID to decide if we show the player sheet. 
    // Do NOT watch the whole state which changes every millisecond with the position.
    final hasTrack = ref.watch(playerStateProvider.select((s) => s.currentTrack != null));

    final screenHeight = MediaQuery.of(context).size.height;

    // Use string matching directly on the shell's current location if possible,
    // or keep this light.
    final location = GoRouter.of(
      context,
    ).routeInformationProvider.value.uri.path;
    final isChatRoute = location.contains('/chat');
    final isFeedRoute = location == '/feed';
    final isVisible = !isChatRoute;
    final currentMinSize = _minSize;
    final double displacement = isVisible ? 0 : screenHeight;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(child: widget.navigationShell),
          if (hasTrack)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: displacement,
              bottom: -displacement,
              left: 0,
              right: 0,
              child: DraggableScrollableSheet(
                key: const Key('main_player_draggable_sheet'),
                controller: _draggableController,
                initialChildSize: currentMinSize,
                minChildSize: currentMinSize,
                maxChildSize: _maxSize,
                snap: true,
                builder: (context, scrollController) {
                  return AnimatedBuilder(
                    animation: _draggableController,
                    builder: (context, _) {
                      final extent = _draggableController.isAttached
                          ? _draggableController.size
                          : currentMinSize;
                      final isCollapsed = extent <= currentMinSize + 0.01;

                      return IgnorePointer(
                        ignoring: isFeedRoute && isCollapsed,
                        child: Container(
                          color: Colors.transparent,
                          child: SingleChildScrollView(
                            controller: scrollController,
                            physics: const ClampingScrollPhysics(),
                            child: SizedBox(
                              height: screenHeight,
                              child: AnimatedBuilder(
                                animation: _draggableController,
                                builder: (context, child) {
                                  final extent = _draggableController.isAttached
                                      ? _draggableController.size
                                      : currentMinSize;
                                  final t =
                                      ((extent - currentMinSize) /
                                              (_maxSize - currentMinSize))
                                          .clamp(0.0, 1.0);

                                  return Stack(
                                    children: [
                                      // Full Player
                                      Opacity(
                                        opacity: t,
                                        child: Container(
                                          color: Colors.black,
                                          child: IgnorePointer(
                                            ignoring: t < 0.5,
                                            child: FullPlayerPage(
                                              key: const Key(
                                                'main_full_player_page',
                                              ),
                                              onCollapse: _collapsePlayer,
                                            ),
                                          ),
                                        ),
                                      ),

                                      if (t < 0.5 && !isFeedRoute)
                                        Positioned(
                                          top: 0,
                                          left: 0,
                                          right: 0,
                                          child: Opacity(
                                            opacity: (1 - t * 5).clamp(
                                              0.0,
                                              1.0,
                                            ),
                                            child: MiniPlayer(
                                              key: const Key(
                                                'main_mini_player_widget',
                                              ),
                                              onTap: _expandPlayer,
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedBuilder(
              animation: _draggableController,
              builder: (context, child) {
                double t = 0.0;
                if (_draggableController.isAttached) {
                  t =
                      ((_draggableController.size - currentMinSize) /
                              (_maxSize - currentMinSize))
                          .clamp(0.0, 1.0);
                }

                return IgnorePointer(
                  ignoring: t > 0.2, // Disable clicks as it slides away
                  child: Transform.translate(
                    offset: Offset(0, _navBarHeight * t),
                    child: Opacity(
                      opacity: (1 - t).clamp(0.0, 1.0),
                      child: child,
                    ),
                  ),
                );
              },
              child: BottomNavigation(
                key: const Key('main_bottom_navigation_bar'),
                navigationShell: widget.navigationShell,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
