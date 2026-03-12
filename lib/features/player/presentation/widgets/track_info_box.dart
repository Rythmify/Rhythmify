import 'package:flutter/material.dart';
import '../../../../core/domain/entities/track_summary.dart'; // Adjust path as needed

class TrackInfoBox extends StatelessWidget {
  final TrackSummary summary;
  final VoidCallback onNavigateBehindTrack;

  const TrackInfoBox({
    super.key,
    required this.summary,
    required this.onNavigateBehindTrack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onNavigateBehindTrack,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${summary.title}\n',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: summary.artist,
                    style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onNavigateBehindTrack,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.bar_chart, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text(
                  'Behind this track',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}