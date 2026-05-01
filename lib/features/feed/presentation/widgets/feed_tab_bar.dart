import 'package:flutter/material.dart';

/// A styled tab bar for switching between the Discover and Following feeds.
///
/// Renders as a pill-shaped [TabBar] with a frosted highlight indicator,
/// constrained to a fixed width so it floats centered over the feed content.
class FeedTabBar extends StatelessWidget {
  final TabController controller;

  const FeedTabBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('feed_tab_bar_sizedbox'),
      width: 250,
      height: 45,
      child: TabBar(
        key: const Key('feed_tab_bar'),
        controller: controller,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        tabs: const [
          Tab(key: Key('feed_tab_discover'), text: 'Discover'),
          Tab(key: Key('feed_tab_following'), text: 'Following'),
        ],
      ),
    );
  }
}
