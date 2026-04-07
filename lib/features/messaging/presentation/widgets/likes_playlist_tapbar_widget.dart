import 'package:flutter/material.dart';

/// A styled [TabBar] widget with two tabs — Likes and Playlists.
///
/// Uses a white underline indicator and custom label styles.
/// Overrides the default theme to use [InkRipple] splash effect
/// and prevent orange color bleeding from the app theme.
///
/// Requires a [TabController] managed by the parent [LikesPlaylistsScreen].
class LikesPlaylistTapbarWidget extends StatefulWidget {
  final TabController controller;
  const LikesPlaylistTapbarWidget({super.key, required this.controller});

  @override
  State<StatefulWidget> createState() => _LikesPlaylistTapbarState();
}

class _LikesPlaylistTapbarState extends State<LikesPlaylistTapbarWidget> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      //To remove the default no splash effect from the tabbar, and make it ripple
      data: Theme.of(context).copyWith(
        splashFactory: InkRipple.splashFactory,
        splashColor: const Color(0xFF2F2F2F),
        highlightColor: Colors.transparent,
        colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: Colors.white, // this stops the orange from bleeding in
        ),
      ),
      child: TabBar(
        //To control the tabbar
        controller: widget.controller,

        //To make a white underline below the selected tab
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: Colors.white, width: 2),
          insets: EdgeInsets.zero,
        ),
        indicatorSize: TabBarIndicatorSize.tab,

        //Theme
        labelColor: Colors.white,
        labelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        unselectedLabelColor: Colors.grey,
        unselectedLabelStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        dividerColor: Colors.white12,

        tabs: const [
          Tab(text: 'Likes'),
          Tab(text: 'Playlists'),
        ],
      ),
    );
  }
}
