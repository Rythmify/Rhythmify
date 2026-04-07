import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/core/theme/app_theme.dart';
import 'package:rythmify/features/messaging/domain/entities/shared_embed.dart';
import 'package:rythmify/features/messaging/presentation/providers/get_liked_embed_provider.dart';
import 'package:rythmify/features/messaging/presentation/widgets/likes_playlist_tapbar_widget.dart';
import 'package:rythmify/features/messaging/presentation/widgets/shared_embed_tile_widget.dart';
import 'package:go_router/go_router.dart';

class LikesPlaylistsScreen extends ConsumerStatefulWidget{
  const LikesPlaylistsScreen({super.key});

  @override
  ConsumerState<LikesPlaylistsScreen> createState() => _LikesPlaylistsScreenState();
}

class _LikesPlaylistsScreenState extends ConsumerState<LikesPlaylistsScreen> 
with SingleTickerProviderStateMixin{
  late TabController _controller;
  //final List<String> _selectedTracksIds=[];
  //final List<String> _selectedPlaylistsAlbumsIds=[];
  final List<SharedEmbed> _selectedEmbeds=[];


  @override
  void initState() {
    super.initState();
    _controller=TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tracksAsync = ref.watch(getLikedEmbedsProvider('track'));
    final playlistsAlbumsAsync = ref.watch(getLikedEmbedsProvider('playlist')).
        whenData((playlists)=>[
          ...playlists,... ref.watch(getLikedEmbedsProvider('album')).value??[]
        ]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add track or playlist'),
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
              onPressed: () => context.pop(_selectedEmbeds),
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
              children: [
                tracksAsync.when( //Tracks Tab
                  data: (tracks) => ListView.builder(
                    itemCount: tracks.length,
                    itemBuilder: (context, index) {
                      final track = tracks[index];
                      return SharedEmbedTileWidget(
                        key: Key('likes_playlists_track_${track.embedId}_tile'),
                        embed: track,
                        isSelected: _selectedEmbeds.any((e)=>e.embedId==track.embedId),
                        onTap: () {
                          setState(() {
                            if (_selectedEmbeds.any((e)=>e.embedId==track.embedId)) {
                              _selectedEmbeds.removeWhere((e)=>e.embedId==track.embedId);
                            } else {
                              _selectedEmbeds.add(track);
                            }
                          });
                        },
                       );
                    },
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text('Error: $e')),
                ),

              playlistsAlbumsAsync.when( //Playlists Tab, Note: this tab has both liked/created playlists/albums
                  data: (embeds) => ListView.builder(
                    itemCount: embeds.length,
                    itemBuilder: (context, index) {
                      final embed = embeds[index];
                      return SharedEmbedTileWidget(
                        key: Key('likes_playlists_embed_${embed.embedId}_tile'),
                        embed: embed,
                        isSelected: _selectedEmbeds.any((e)=>e.embedId==embed.embedId),
                        onTap: () {
                          setState(() {
                            if (_selectedEmbeds.any((e)=>e.embedId==embed.embedId)) {
                              _selectedEmbeds.removeWhere((e)=>e.embedId==embed.embedId);
                            } else {
                              _selectedEmbeds.add(embed);
                            }
                          });
                        },
                       );
                    },
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text('Error: $e')),
                ),
              ]
            ),
          )
        ],
      )
    );
  }
}
