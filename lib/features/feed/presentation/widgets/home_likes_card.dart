import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../library/presentation/providers/library_providers.dart';
import '../../../../core/theme/app_theme.dart';

/// A reusable banner widget that replicates a horizontal "Your likes" card.
///
/// Features a vertical gradient background, a diagonal stack of grey-filled
/// hearts with orange strokes, and a text label.
class LikesBannerWidget extends ConsumerWidget {
  final String label;
  final List<Color>? gradientColors;
  final int heartCount;

  const LikesBannerWidget({
    super.key,
    this.label = 'Your likes',
    this.gradientColors,
    this.heartCount = 6,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likesState = ref.watch(likesProvider);

    // Only visible if the user has liked at least one track
    if (likesState.tracks.isEmpty && !likesState.isLoading) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () => context.push('/library/likes'),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 60, // Static and much smaller height
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: const LinearGradient(
              colors: [Color(0xFF501606), Color(0xFF222222)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // Hearts Stack - Diagonal Line from bottom-left to top-right
                Positioned(
                  left: -10, // Partially "eaten" by the left edge
                  bottom: -10, // Partially "eaten" by the bottom edge
                  child: SizedBox(
                    width: 150,
                    height: 100,
                    child: Stack(
                      children: List.generate(heartCount, (index) {
                        return Positioned(
                          left: index * 4.0,
                          bottom: index * 4.0,
                          child: CustomPaint(
                            size: const Size(45, 45),
                            painter: HeartPainter(
                              fillColor: AppTheme.surface,
                              strokeColor: AppTheme.primaryBrand,
                              strokeWidth: 1.5,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                // Text Label
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 70.0,
                    ), // Space for hearts
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5, // Smaller letter spacing
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter to draw a heart with both fill and stroke.
class HeartPainter extends CustomPainter {
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;

  HeartPainter({
    required this.fillColor,
    required this.strokeColor,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;

    path.moveTo(width / 2, height * 0.25);
    path.cubicTo(
      width * 0.2,
      height * -0.1,
      width * -0.25,
      height * 0.45,
      width / 2,
      height * 0.9,
    );
    path.cubicTo(
      width * 1.25,
      height * 0.45,
      width * 0.8,
      height * -0.1,
      width / 2,
      height * 0.25,
    );

    // Draw Fill
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Draw Stroke
    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant HeartPainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
