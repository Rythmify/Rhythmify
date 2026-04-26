import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import '../providers/home_providers.dart';
import 'shimmers/station_card_shimmer.dart';

class DiscoverWithStationsSection extends ConsumerWidget {
  const DiscoverWithStationsSection({super.key});

  static const _ringColors = [
    Color(0xFF1A7AD4),
    Color(0xFFD41A4A),
    Color(0xFF1AD47A),
    Color(0xFF9B1AD4),
    Color(0xFFD4781A),
    Color(0xFF1AD4D4),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncStations = ref.watch(discoverStationsProvider);

    return Column(
      key: const Key('discover_stations_section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 16),
          child: Text("Discover with Stations", style: AppTheme.homeTitle),
        ),
        asyncStations.when(
          loading: () => SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) => const StationCardShimmer(),
            ),
          ),
          error: (e, _) => Text(
            "Error: $e",
            key: const Key('discover_with_stations_error_text'),
          ),
          data: (items) {
            return SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final station = items[index];
                  return StationCard(
                    key: Key('discover_with_stations_item_${station.id}'),
                    id: station.id,
                    artistName: station.artistName,
                    artistId: station.artistId,
                    centerImage: station.images.center,
                    leftImage: station.images.left,
                    rightImage: station.images.right,
                    stationName: station.name,
                    ringColor: _ringColors[index % _ringColors.length],
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class StationCard extends StatelessWidget {
  final String id;
  final String artistName;
  final String stationName;
  final String? centerImage;
  final String? leftImage;
  final String? rightImage;
  final Color ringColor;
  final String artistId;

  const StationCard({
    super.key,
    required this.id,
    required this.artistName,
    required this.stationName,
    required this.artistId,
    this.centerImage,
    this.leftImage,
    this.rightImage,
    this.ringColor = const Color(0xFFD4A017),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        '/home/station/$artistId',
        extra: {
          'artistName': artistName,
          'stationName': stationName,
          'coverUrl': centerImage ?? leftImage ?? '',
        },
      ),
      child: SizedBox(
        width: 160,
        child: Column(
          key: Key('station_card_container_$artistName'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.5),
                    width: 0.8,
                  ),
                ),
                child: SizedBox(
                  height: 155,
                  width: 160,
                  child: Stack(
                    key: Key('station_image_$artistName'),
                    children: [
                      // Vinyl record background
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _VinylPainter(ringColor: ringColor),
                        ),
                      ),

                      // Left small avatar
                      if (leftImage != null)
                        Positioned(
                          left: 6,
                          top: 10,
                          child: _CircleAvatar(
                            imageUrl: leftImage!,
                            size: 50,
                            borderColor: const Color.fromARGB(255, 202, 196, 182),
                            borderWidth: 2,
                          ),
                        ),

                      // Right small avatar
                      if (rightImage != null)
                        Positioned(
                          right: 6,
                          top: 60,
                          child: _CircleAvatar(
                            imageUrl: rightImage!,
                            size: 50,
                            borderColor: const Color.fromARGB(255, 202, 196, 182),
                            borderWidth: 2,
                          ),
                        ),

                      // Center large badge
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 30,
                        child: Center(
                          child: _CenterArtistBadge(
                            imageUrl: centerImage,
                            artistName: artistName,
                            size: 82,
                            borderColor: ringColor,
                          ),
                        ),
                      ),

                      // Bottom gradient label
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.78),
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "STATION",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.italic,
                                  letterSpacing: 1.4,
                                ),
                              ),
                              Text(
                                artistName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              key: Key('station_artists_$artistName'),
              stationName,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Vinyl record background painter ─────────────────────────────────────────

class _VinylPainter extends CustomPainter {
  final Color ringColor;

  const _VinylPainter({required this.ringColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.75;

    // Dark base
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color.fromARGB(255, 29, 29, 29),
    );

    // Concentric rings
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const ringCount = 10;
    for (int i = 1; i <= ringCount; i++) {
      final t = i / ringCount;
      final radius = maxRadius * t;
      final color = i.isEven
          ? ringColor.withValues(alpha: 0.55)
          : ringColor.withValues(alpha: 0.35);
      ringPaint.color = color;
      canvas.drawCircle(center, radius, ringPaint);
    }

    // Subtle center hole
    canvas.drawCircle(center, 6, Paint()..color = const Color(0xFF2A1F00));
    canvas.drawCircle(
      center,
      6,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = ringColor.withValues(alpha: 0.6),
    );
  }

  @override
  bool shouldRepaint(covariant _VinylPainter old) => old.ringColor != ringColor;
}

// ── Small circle avatar ──────────────────────────────────────────────────────

class _CircleAvatar extends StatelessWidget {
  final String imageUrl;
  final double size;
  final Color borderColor;
  final double borderWidth;

  const _CircleAvatar({
    required this.imageUrl,
    required this.size,
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: borderWidth),
        color: Colors.grey[900],
        image: imageUrl.startsWith('http')
            ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
            : null,
      ),
    );
  }
}

// ── Center artist badge ──────────────────────────────────────────────────────

class _CenterArtistBadge extends StatelessWidget {
  final String? imageUrl;
  final String artistName;
  final double size;
  final Color borderColor;

  const _CenterArtistBadge({
    required this.imageUrl,
    required this.artistName,
    required this.size,
    this.borderColor = const Color(0xFFD4A017),
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.startsWith('http');

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2.5),
        color: const Color(0xFF1A3A6B),
        image: hasImage
            ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: ClipOval(
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (!hasImage)
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(
                  artistName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFD4A017),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    height: 1.1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
