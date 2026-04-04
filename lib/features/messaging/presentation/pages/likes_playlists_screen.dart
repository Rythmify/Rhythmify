import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/core/theme/app_theme.dart';
import 'package:rythmify/features/messaging/presentation/widgets/likes_playlist_tapbar_widget.dart';

class LikesPlaylistsScreen extends ConsumerStatefulWidget{
  const LikesPlaylistsScreen({super.key});

  @override
  ConsumerState<LikesPlaylistsScreen> createState() => _LikesPlaylistsScreenState();
}

class _LikesPlaylistsScreenState extends ConsumerState<LikesPlaylistsScreen> 
with SingleTickerProviderStateMixin{
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller=TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add track or playlis'),
        titleSpacing: 0,
        titleTextStyle: const TextStyle(
          color: AppTheme.appBarItems,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          overflow: TextOverflow.ellipsis
        ),
        centerTitle: false,
        actions: [
          IconButton(
            key: const Key('likes_playlists_app_bar_close_button'),
            onPressed: (){},
            icon: Icon(
              Icons.cast,
              color:AppTheme.appBarItems
            )
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              key: const Key('likes_playlists_done_button'),
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                elevation: 0,
                side: const BorderSide(color: AppTheme.appBarItems, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap
              ),
              child: Text(
                'Done',
                style: TextStyle(fontSize: 13)
              ),
            ),
            )
        ],
      ),
      
      body:Column(
        children:[
          LikesPlaylistTapbarWidget(controller: _controller),
          Expanded(
            child: TabBarView(
              controller: _controller,
              children: const [
                Center(child: Text('Likes',style: TextStyle(color: Colors.white))),
                Center(child: Text('Playlists',style: TextStyle(color: Colors.white))),
              ]
            ),
          )
        ],
      )
    );
  }
}
