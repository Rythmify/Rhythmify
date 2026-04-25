import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';

/// Displays the primary visual and textual metadata for a track.
///
/// This widget renders the track's cover art alongside its title, artist name,
/// play count, total duration, and release date in a structured layout.
///
/// Expects a [track] entity containing the necessary metadata.

class TrackInfoHeader extends StatelessWidget {
  final dynamic track;

  const TrackInfoHeader({super.key, required this.track});

  void _showFullScreenArtwork(BuildContext context) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (context) => Material(
        color: const Color(0xFF1E1E1E), // Deep grey background
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Hero(
                    tag: 'track_artwork_${track.id}',
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(17),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: track.artworkUrl.toString().startsWith('http')
                              ? Image.network(
                                  track.artworkUrl,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  track.artworkUrl,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 15,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 22),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => _showFullScreenArtwork(context),
            child: Hero(
              tag: 'track_artwork_${track.id}',
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.7),
                    width: 0.6,
                  ),
                  borderRadius: BorderRadius.circular(9),
                  color: Colors.grey.withValues(alpha: 0.4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: track.artworkUrl.toString().startsWith('http')
                      ? Image.network(
                          track.artworkUrl,
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 110,
                                height: 110,
                                color: AppTheme.perfectGrey,
                                child: const Icon(
                                  Icons.music_note,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                        )
                      : Image.asset(
                          track.artworkUrl,
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 110,
                                height: 110,
                                color: AppTheme.perfectGrey,
                                child: const Icon(
                                  Icons.error,
                                  color: Colors.red,
                                ),
                              ),
                        ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.title,
                  style: AppTheme.trackTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 2),
                Text(
                  track.artist,
                  style: AppTheme.artistTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),

                Row(
                  children: [
                    const Icon(
                      Icons.play_arrow,
                      size: 19,
                      color: AppTheme.semiWhite,
                    ),

                    const SizedBox(width: 3),
                    Text(
                      Formatters.formatCount(track.playCount),
                      style: AppTheme.labelSmall.copyWith(
                        fontSize: 12,
                        color: AppTheme.semiWhite,
                      ),
                    ),

                    const SizedBox(width: 5),
                    const Text(
                      "•",
                      style: TextStyle(color: AppTheme.semiWhite),
                    ),

                    const SizedBox(width: 5),
                    Text(
                      Formatters.formatDuration(track.duration),
                      style: AppTheme.labelSmall.copyWith(
                        fontSize: 12,
                        color: AppTheme.semiWhite,
                      ),
                    ),

                    const SizedBox(width: 5),
                    const Text(
                      "•",
                      style: TextStyle(color: AppTheme.semiWhite),
                    ),

                    const SizedBox(width: 5),
                    Text(
                      Formatters.formatDate(
                        track.releaseDate != null
                            ? DateTime.tryParse(track.releaseDate!) ??
                                  track.createdAt
                            : track.createdAt,
                      ),
                      style: AppTheme.labelSmall.copyWith(
                        fontSize: 12,
                        color: AppTheme.semiWhite,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
