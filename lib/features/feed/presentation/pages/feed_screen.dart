import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/feed_tab_bar.dart';
import '../widgets/feed_list.dart';
import '../../../player/presentation/providers/player_provider.dart';

/// The main feed screen, displaying a tabbed view of the Discover
/// and Following feeds.
///
/// Manages a [TabController] shared between [FeedTabBar] and the two
/// [FeedList] instances. Stops any active playback and resets track
/// previews whenever the user switches tabs.
class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen>
    with SingleTickerProviderStateMixin {
  /// Key used to access the Discover [FeedList] state imperatively.
  final _discoverKey = GlobalKey<FeedListState>();

  /// Key used to access the Following [FeedList] state imperatively.
  final _followingKey = GlobalKey<FeedListState>();

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        ref.read(playerStateProvider.notifier).stopPlayback();
        _discoverKey.currentState?.resetPreview();
        _followingKey.currentState?.resetPreview();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Feed content fills the whole screen
            TabBarView(
              controller: _tabController,
              children: [
                FeedList(key: _discoverKey, tab: FeedTab.discover),
                FeedList(key: _followingKey, tab: FeedTab.following),
              ],
            ),
            // TabBar floats on top, centered, constrained width
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Center(child: FeedTabBar(controller: _tabController)),
            ),
          ],
        ),
      ),
    );
  }
}
