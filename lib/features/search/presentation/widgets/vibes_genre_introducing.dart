import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../domain/entities/vibes_genre_introducing_section.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../player/domain/entities/player_state.dart';
import '../../../track/presentation/widgets/track_card.dart';
import 'package:go_router/go_router.dart';

Widget _buildImage(
  String url, {
  required double width,
  required double height,
  BoxFit fit = BoxFit.cover,
}) {
  if (url.isEmpty) {
    return Container(width: width, height: height, color: Colors.grey[800]);
  }
  if (url.startsWith('http')) {
    return Image.network(url, width: width, height: height, fit: fit);
  }
  return Image.asset(url, width: width, height: height, fit: fit);
}

ImageProvider _imageProvider(String url) {
  if (url.startsWith('http')) return NetworkImage(url);
  if (url.isNotEmpty) return AssetImage(url);
  return const AssetImage('assets/images/placeholder.png');
}

class IntroducingSectionWidget extends ConsumerWidget {
  final IntroducingSection introducing;
  const IntroducingSectionWidget({super.key, required this.introducing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlist = introducing.playlist;
    final tracks = introducing.tracksPreview.take(2).toList();
    final playerState = ref.watch(playerStateProvider);
    final isPlaying =
        tracks.isNotEmpty &&
        playerState.currentTrack?.id == tracks.first.id &&
        playerState.status == PlayerStatus.playing;

    const double topHalfHeight = 170.0;
    const double bottomHalfHeight = 170.0;
    const double coverSize = 110.0;

    return GestureDetector(
      onTap: () => context.push(
        '/library/playlists/${playlist.playlistId}',
        extra: false,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: topHalfHeight + bottomHalfHeight,
          child: Stack(
            children: [
              // ── Top half: blurred cover background ─────────
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: topHalfHeight,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Image(
                          image: _imageProvider(playlist.coverImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Bottom half: dark grey background ───────────
              Positioned(
                top: topHalfHeight,
                left: 0,
                right: 0,
                height: bottomHalfHeight,
                child: Container(color: const Color(0xFF1A1A1A)),
              ),

              // ── Cover art ───────────────────────────────────
              Positioned(
                top: 15,
                left: 16,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(0),
                  child: _buildImage(
                    playlist.coverImage,
                    width: coverSize,
                    height: coverSize,
                  ),
                ),
              ),

              // ── Hero text + buttons ──────────────────────────
              Positioned(
                top: 17,
                left: 16 + coverSize + 16,
                right: 16,
                height: topHalfHeight - 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      playlist.name.isNotEmpty
                          ? playlist.name
                          : 'Featured Playlist',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      playlist.description.isNotEmpty
                          ? playlist.description
                          : 'A curated selection of the best tracks in this genre.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.black.withValues(alpha: 0.55),
                          child: const Icon(
                            Icons.favorite_border,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            final state = ref.read(playerStateProvider);
                            if (tracks.isNotEmpty &&
                                state.currentTrack?.id == tracks.first.id) {
                              ref
                                  .read(playerStateProvider.notifier)
                                  .togglePlayPause();
                            } else {
                              ref
                                  .read(playerStateProvider.notifier)
                                  .loadAndPlayQueue(tracks);
                            }
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white,
                            child: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.black,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Track tiles (bottom half) ────────────────────
              Positioned(
                top: topHalfHeight + 8,
                left: 0,
                right: 0,
                child: Column(
                  children: tracks.map((t) => TrackCard(track: t)).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
