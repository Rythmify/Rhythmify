

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
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rythmify/features/track_upload/presentation/providers/upload_track_provider.dart';
import 'package:rythmify/features/track_upload/presentation/widgets/upload_button_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';


class AudioPickerWidget extends ConsumerWidget {
  const AudioPickerWidget({super.key});

  // ── Replace audio ─────────────────────────────────────────────────────────

  Future<void> _replaceAudio(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;
    final picked = result.files.first;
    if (picked.path == null) return;

    Duration duration = Duration.zero;
    try {
      final player = AudioPlayer();
      final detected = await player.setFilePath(picked.path!);
      duration = detected ?? Duration.zero;
      await player.dispose();
    } catch (_) {}

    ref
        .read(uploadFormProvider.notifier)
        .initDraft(
          artistId: 'dev_user_001',
          localAudioPath: picked.path!,
          duration: duration,
          fileName: picked.name,
        );
    ref.read(uploadFormProvider.notifier).startAudioUpload();
  }

  // ── Pick artwork ──────────────────────────────────────────────────────────

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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(uploadFormProvider);
    final draft = state.draft;

    if (draft == null) return const SizedBox.shrink();

    final fileName =
        draft.audioFileName ?? draft.localAudioPath.split('/').last;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Dashed artwork frame ──────────────────────────────────────
        GestureDetector(
          onTap: () => _pickImage(context, ref),
          child: _DashedFrame(artworkPath: draft.localArtworkPath),
        ),
        const SizedBox(width: 14),

        // ── Filename + upload button ──────────────────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // "Filename" grey label
              const Text(
                'Filename',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 4),

              // Actual file name
              Text(
                fileName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 12),

              // Upload progress button
              UploadButtonWidget(
                status: draft.audioStatus, // ← was draft.status
                progress:
                    draft.audioUploadProgress, // ← was draft.uploadProgress
                onReplace: () => _replaceAudio(context, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Dashed frame ──────────────────────────────────────────────────────────────

class _DashedFrame extends StatelessWidget {
  final String? artworkPath;

  const _DashedFrame({this.artworkPath});

  @override
  Widget build(BuildContext context) {
    final hasArtwork = artworkPath != null;

    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: SizedBox(
        width: 90,
        height: 90,
        child: hasArtwork
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.file(File(artworkPath!), fit: BoxFit.cover),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white38,
                    size: 26,
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Dashed border painter ─────────────────────────────────────────────────────

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
    double dist = 0;

    while (dist < total) {
      final end = (dist + dashWidth).clamp(0.0, total);
      canvas.drawPath(metrics.extractPath(dist, end), paint);
      dist += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
