import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/feed_tab_bar.dart';
import '../widgets/feed_list.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
              children: const [
                FeedList(tab: FeedTab.discover),
                FeedList(tab: FeedTab.following),
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
