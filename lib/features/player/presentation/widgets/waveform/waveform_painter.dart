import 'package:flutter/material.dart';
import 'dart:math' as math;

class WaveformPainter extends CustomPainter {
  final List<double> amplitudes;
  final Duration duration;
  final Duration activePosition; // Drag position OR playing position
  final Duration actualPosition; // Strictly the playing position
  final double heightMultiplier; // 1.0 = playing, 0.0 = paused (thin line)

  WaveformPainter({
    required this.amplitudes,
    required this.duration,
    required this.activePosition,
    required this.actualPosition,
    required this.heightMultiplier,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (amplitudes.isEmpty || duration.inMilliseconds == 0) return;

    const double barWidth = 2.5;
    const double spacing = 1.5;
    const double totalBarWidth = barWidth + spacing;
    final double totalWaveWidth = amplitudes.length * totalBarWidth;

    // The static center line of the screen
    final double nodeX = size.width / 2;

    // Calculate offsets
    final double activeProgress = activePosition.inMilliseconds / duration.inMilliseconds;
    final double activeOffset = activeProgress * totalWaveWidth;
    
    final double actualProgress = actualPosition.inMilliseconds / duration.inMilliseconds;
    final double actualOffset = actualProgress * totalWaveWidth;

    // The physical screen X coordinate of where the actual audio is playing
    final double playheadX = nodeX - activeOffset + actualOffset;

    final double maxHeight = size.height / 2;
    // When paused, gap collapses to 0. Otherwise it's 2px.
    final double gap = 2.0 * heightMultiplier; 

    for (int i = 0; i < amplitudes.length; i++) {
      // Calculate the X center of the current bar
      final double barX = nodeX + (i * totalBarWidth) - activeOffset;

      // Color logic based on exact coordinate rules
      Color topColor;
      Color bottomColor;

      // Rule: Base coloring (No dragging) or exact matches
      if ((playheadX - nodeX).abs() < 1.0) {
        if (barX <= nodeX) {
          topColor = Colors.orange;
          bottomColor = Colors.orange.withValues(alpha: 0.5);
        } else {
          topColor = Colors.white;
          bottomColor = Colors.white.withValues(alpha: 0.5);
        }
      } 
      // Rule: Sliding Left (View is behind actual play -> playhead is to the right)
      else if (playheadX > nodeX) {
        if (barX <= nodeX) {
          topColor = Colors.orange;
          bottomColor = Colors.orange.withValues(alpha: 0.5);
        } else if (barX > nodeX && barX <= playheadX) {
          topColor = Colors.grey;
          bottomColor = Colors.grey.withValues(alpha: 0.5);
        } else {
          topColor = Colors.white;
          bottomColor = Colors.white.withValues(alpha: 0.5);
        }
      } 
      // Rule: Sliding Right (View is ahead of actual play -> playhead is to the left)
      else {
        if (barX <= playheadX) {
          topColor = Colors.orange;
          bottomColor = Colors.orange.withValues(alpha: 0.5);
        } else if (barX > playheadX && barX <= nodeX) {
          topColor = Colors.grey.shade700;
          bottomColor = Colors.grey.shade700.withValues(alpha: 0.5);
        } else {
          topColor = Colors.white;
          bottomColor = Colors.white.withValues(alpha: 0.5);
        }
      }

      // Height calculations compressing towards a 1px line
      final double baseAmplitude = amplitudes[i];
      // Min height of 1.0 ensures the line never completely disappears
      final double topHeight = math.max(1.0, baseAmplitude * maxHeight * heightMultiplier);
      final double bottomHeight = math.max(1.0, topHeight * 0.6); // Bottom is shorter

      final Paint topPaint = Paint()
        ..color = topColor
        ..style = PaintingStyle.fill;
        
      final Paint bottomPaint = Paint()
        ..color = bottomColor
        ..style = PaintingStyle.fill;

      // Draw Top Rect
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(barX - (barWidth / 2), size.height / 2 - gap / 2 - topHeight, barWidth, topHeight),
          const Radius.circular(0.0),
        ),
        topPaint,
      );

      // Draw Bottom Rect
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(barX - (barWidth / 2), size.height / 2 + gap / 2, barWidth, bottomHeight),
          const Radius.circular(0.0),
        ),
        bottomPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.activePosition != activePosition ||
           oldDelegate.actualPosition != actualPosition ||
           oldDelegate.heightMultiplier != heightMultiplier;
  }
}