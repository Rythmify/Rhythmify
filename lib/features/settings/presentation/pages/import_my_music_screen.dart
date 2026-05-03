import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rythmify/features/settings/presentation/widgets/no_switch_tile_widget.dart';

/// Warns the user about permanent account deletion consequences.
/// Shows a confirmation dialog before proceeding with account deletion.
class ImportMyMusicScreen extends StatelessWidget {
  const ImportMyMusicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: const Color(0xFF3A3A3A),
        highlightColor: const Color(0xFF2A2A2A),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Import my music'),
          centerTitle: false,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NoSwitchTileWidget(
              key: Key('Import_From_Another_App_tile'),
              title: 'Import from another app',
              subtitle:
                  'Move your playlists and likes from other apps to Rythmify',
              onTap: () {
                context.push(
                  '/library/settings/import-my-music/music-providers',
                  extra: 'Import music (1/3)',
                );
              },
            ),
            NoSwitchTileWidget(
              key: Key('Manage_imported_likes_tile'),
              title: 'Manage imported likes',
              subtitle: 'Remove imported likes or add them to a playlist',
              onTap: () {
                context.push(
                  '/library/settings/import-my-music/music-providers',
                  extra: 'Manage imported likes',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
