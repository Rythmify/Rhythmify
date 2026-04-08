import 'package:flutter/material.dart';
import 'package:rythmify/features/settings/presentation/widgets/reusable_tile_widget.dart';

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
          children: [
            ReusableTileWidget(
              key: Key('Import_From_Another_App_tile'),
              title: 'Import from another app',
              subtitle:
                  'Move your playlists and likes from other apps to Rythmify',
              switchExists: false,
              onTap: () {},
            ),
            const SizedBox(height: 20),
            ReusableTileWidget(
              key: Key('Manage_imported_likes_tile'),
              title: 'Manage imported likes',
              subtitle: 'Remove imported likes or add them to a playlist',
              switchExists: false,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
