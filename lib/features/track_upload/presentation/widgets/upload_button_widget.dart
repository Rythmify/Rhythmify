/// Widget: UploadButtonWidget
///
/// Animated button displaying upload progress.
///
/// Responsibilities:
/// - Show upload progress visually
/// - Animate progress changes
/// - Display completion state with replace option
///
/// Notes:
/// - Uses AnimationController for smooth transitions
import 'package:flutter/material.dart';
import 'package:rythmify/features/track_upload/domain/entities/track_draft.dart';

class UploadButtonWidget extends StatelessWidget {
  final UploadStatus status;
  final double progress;
  final VoidCallback? onReplace;

  const UploadButtonWidget({
    super.key,
    required this.status,
    required this.progress,
    this.onReplace,
  });

  @override
  Widget build(BuildContext context) {
    // ── STATE: Done → show Replace button ────────────────────────────
    if (status == UploadStatus.success) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Replace button
          GestureDetector(
            onTap: onReplace,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white38),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Replace',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Green circle with checkmark
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFF1DB954),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      );
    }

    // ── STATE: Uploading or Processing ───────────────────────────────
    final isProcessing = status == UploadStatus.uploading && progress >= 1.0;
    final label = isProcessing
        ? 'PREPARING TO PROCESS'
        : 'UPLOADING ${(progress * 100).toInt()}%';

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 36,
        child: Stack(
          children: [
            // Grey background
            Container(color: const Color(0xFF2A2A2A)),

            // Green fill growing left to right
            FractionallySizedBox(
              widthFactor: isProcessing ? 1.0 : progress.clamp(0.0, 1.0),
              child: Container(color: const Color(0xFF1DB954)),
            ),

            // Label on top
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (isProcessing) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onReplace,
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
