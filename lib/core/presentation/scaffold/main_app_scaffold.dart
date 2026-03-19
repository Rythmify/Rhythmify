import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/bottom_navigation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/player/presentation/widgets/mini_player.dart';
import '../../../../features/player/presentation/pages/full_player_page.dart';
import '../../../../features/player/presentation/providers/player_provider.dart';

class MainAppScaffold extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainAppScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  ConsumerState<MainAppScaffold> createState() => _MainAppScaffoldState();
}

class _MainAppScaffoldState extends ConsumerState<MainAppScaffold> {
  final DraggableScrollableController _draggableController = DraggableScrollableController();
  
  // Heights in logical pixels
  static const double _navBarHeight = 85.0; // Standard bottom nav height approx
  static const double _miniPlayerHeight = 65.0;

  double get _minSize {
    if (!context.mounted) return 0.08;
    final screenHeight = MediaQuery.of(context).size.height;
    return screenHeight > 0 ? (_navBarHeight + _miniPlayerHeight) / screenHeight : 0.15;
  }
  
  static const double _maxSize = 1.0;

  void _expandPlayer() {
    if (_draggableController.isAttached) {
      _draggableController.animateTo(
        _maxSize,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
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
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerStateProvider);
    final hasTrack = playerState.currentTrack != null;
    final screenHeight = MediaQuery.of(context).size.height;

    // Determine if mini player should be visible based on the current route
    final routerState = GoRouterState.of(context);
    final location = routerState.uri.path;
    final isChatRoute = location.contains('/chat'); // Match '/chat' or '/chat/:id'
    final isVisible = !isChatRoute;
  
    // We use a local variable to capture the minSize during build
    final currentMinSize = _minSize;
    
    // Displacement for the "go down" animation. 
    // We move it by the full screen height to be absolutely sure it's gone.
    final double displacement = isVisible ? 0 : screenHeight;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Main Content (Back to Full Screen)
          Positioned.fill(
            child: widget.navigationShell,
          ),

          // 2. Draggable Player (Behind the Nav Bar)
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
                  return Container(
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
                            final t = ((extent - currentMinSize) / (_maxSize - currentMinSize)).clamp(0.0, 1.0);
                            
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
                                        key: const Key('main_full_player_page'),
                                        onCollapse: _collapsePlayer,
                                      ),
                                    ),
                                  ),
                                ),

                                // Mini Player (Anchored to top of the sheet)
                                if (t < 0.5)
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    child: Opacity(
                                      opacity: (1 - t * 5).clamp(0.0, 1.0),
                                      child: MiniPlayer(
                                        key: const Key('main_mini_player_widget'),
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
                  );
                },
              ),
            ),

          // 3. Bottom Navigation (Floating on top)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedBuilder(
              animation: _draggableController,
              builder: (context, child) {
                double t = 0.0;
                if (_draggableController.isAttached) {
                  t = ((_draggableController.size - currentMinSize) / (_maxSize - currentMinSize)).clamp(0.0, 1.0);
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
                navigationShell: widget.navigationShell
              ),
            ),
          ),
        ],
      ),
    );
  }
}