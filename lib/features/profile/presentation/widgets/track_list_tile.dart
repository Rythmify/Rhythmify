import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/domain/entities/track.dart';
import '../../../../../core/theme/app_theme.dart';

class TrackListTile extends StatelessWidget {
  final Track track;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;

  const TrackListTile({
    super.key,
    required this.track,
    this.onTap,
    this.onMoreTap,
  });

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // ── Artwork ──────────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: CachedNetworkImage(
                imageUrl: track.artworkUrl!,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(width: 56, height: 56, color: AppTheme.surface),
                errorWidget: (context, url, error) => _placeholder(),
              ),
            ),
            const SizedBox(width: 12),

            // ── Title + meta ─────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: AppTheme.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.artist,
                    style: AppTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.play_arrow,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        _formatCount(track.playCount),
                        style: AppTheme.labelSmall,
                      ),
                      const SizedBox(width: 8),
                      Text('·', style: AppTheme.labelSmall),
                      const SizedBox(width: 8),
                      Text(
                        _formatDuration(track.duration.inSeconds),
                        style: AppTheme.labelSmall,
                      ),
                      const SizedBox(width: 8),
                      Text('·', style: AppTheme.labelSmall),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.favorite,
                        size: 14,
                        color: track.isLiked
                            ? AppTheme.primaryBrand
                            : AppTheme.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── More button ───────────────────────────────────────────
            IconButton(
              onPressed: onMoreTap,
              icon: const Icon(
                Icons.more_vert,
                color: AppTheme.textSecondary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 56,
      height: 56,
      color: AppTheme.surface,
      child: const Icon(
        Icons.music_note,
        color: AppTheme.textSecondary,
        size: 24,
      ),
    );
  }
}
