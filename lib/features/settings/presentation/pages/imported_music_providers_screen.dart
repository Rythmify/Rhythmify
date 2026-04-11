import 'package:flutter/material.dart';

/// Displays a grid of supported music provider logos.
/// The [appBarTitle] changes based on which import flow was selected.
/// Supports: Spotify, Apple Music, Deezer, Tidal, Amazon Music, Resso.
class ImportedMusicProvidersScreen extends StatelessWidget {
  final String appBarTitle;
  const ImportedMusicProvidersScreen({super.key, required this.appBarTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle), centerTitle: false),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select a provider',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.4,
                children: [
                  _buildCard(
                    context: context,
                    key: Key('spotify'),
                    imgPath: 'assets/images/spotify.jpeg',
                  ),
                  _buildCard(
                    context: context,
                    key: Key('apple_music'),
                    imgPath: 'assets/images/apple_music.jpeg',
                  ),
                  _buildCard(
                    context: context,
                    key: Key('deezer'),
                    imgPath: 'assets/images/deezer.jpeg',
                  ),
                  _buildCard(
                    context: context,
                    key: Key('tidal'),
                    imgPath: 'assets/images/tidal.jpeg',
                  ),
                  _buildCard(
                    context: context,
                    key: Key('amazon_music'),
                    imgPath: 'assets/images/amazon_music.jpeg',
                  ),
                  _buildCard(
                    context: context,
                    key: Key('resso'),
                    imgPath: 'assets/images/resso.jpeg',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required Key key,
    required String imgPath,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(splashFactory: InkRipple.splashFactory),
      child: InkWell(
        key: key,
        onTap: () {},
        splashColor: Colors.white.withValues(alpha: 0.2),
        highlightColor: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(5),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            image: DecorationImage(
              image: AssetImage(imgPath),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
