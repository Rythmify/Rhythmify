import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rythmify/features/track_upload/presentation/providers/upload_track_provider.dart';
import 'package:rythmify/features/track_upload/presentation/widgets/upload_button_widget.dart';


/// Widget: AudioPickerWidget
///
/// Displays selected audio file information and artwork picker.
///
/// Responsibilities:
/// - Show audio file name and duration
/// - Allow user to pick cover image
/// - Display upload progress button
///
/// Notes:
/// - Interacts with UploadFormProvider to update artwork

class AudioPickerWidget extends ConsumerWidget {
  const AudioPickerWidget({super.key});

  String _formatDuration(Duration duration) {
    final m = duration.inMinutes;
    final s = duration.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _pickImage(BuildContext context, WidgetRef ref) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFF2E2E2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              key: const Key('track_upload_gallery_listtile'),
              leading: const Icon(
                Icons.photo_library_outlined,
                color: Colors.white70,
              ),
              title: const Text(
                'Choose from gallery',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              key: const Key('track_upload_camera_listtile'),
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: Colors.white70,
              ),
              title: const Text(
                'Take a photo',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1000,
      maxHeight: 1000,
    );

    if (picked != null) {
      ref.read(uploadFormProvider.notifier).setArtwork(picked.path);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(uploadFormProvider);
    final draft = state.draft;

    // ← fileName now reads from draft, not state
    final fileName =
        draft?.audioFileName ??
        draft?.localAudioPath.split('/').last ??
        'audio file';

    if (draft == null) return const SizedBox.shrink();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Dashed camera frame ───────────────────────────────────────
        GestureDetector(
          onTap: () => _pickImage(context, ref),
          child: _DashedFrame(artworkPath: draft.localArtworkPath),
        ),

        // ── Audio name + progress button ──────────────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fileName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 4),
              Text(
                _formatDuration(draft.duration),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 10),
              UploadButtonWidget(
                buttonState: _getButtonState(draft.uploadProgress),
                progress: draft.uploadProgress,
                onReplace: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  UploadButtonState _getButtonState(double progress) {
    if (progress >= 1.0) return UploadButtonState.done;
    if (progress > 0.0) return UploadButtonState.uploading;
    return UploadButtonState.uploading;
  }
}

// ── Dashed frame widget ───────────────────────────────────────────────────────

class _DashedFrame extends StatelessWidget {
  final String? artworkPath;

  const _DashedFrame({this.artworkPath});

  @override
  Widget build(BuildContext context) {
    final hasArtwork = artworkPath != null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: CustomPaint(
        painter: _DashedBorderPainter(),
        child: SizedBox(
          width: 90,
          height: 90,
          child: hasArtwork
              ? Image.file(File(artworkPath!), fit: BoxFit.cover)
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white54,
                      size: 28,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Custom painter for dashed border ─────────────────────────────────────────

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white38
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    const radius = 4.0;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(radius),
    );

    final path = Path()..addRRect(rect);
    final metrics = path.computeMetrics().first;
    final total = metrics.length;
    double distance = 0;

    while (distance < total) {
      final end = (distance + dashWidth).clamp(0.0, total);
      canvas.drawPath(metrics.extractPath(distance, end), paint);
      distance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
