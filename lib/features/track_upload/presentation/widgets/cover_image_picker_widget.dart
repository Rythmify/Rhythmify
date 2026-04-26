import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/core/theme/app_theme.dart';
import 'package:rythmify/features/track_upload/presentation/providers/upload_track_provider.dart';

/// Widget: CoverImagePickerWidget
///
/// Displays and allows selection of track artwork.
///
/// Responsibilities:
/// - Show selected artwork preview
/// - Trigger image picker when tapped
///
/// Notes:
/// - Reads artwork path from UploadFormProvider

class CoverImagePickerWidget extends ConsumerWidget {
  final VoidCallback onTap;

  const CoverImagePickerWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(uploadFormProvider).draft;
    final hasLocalArtwork = draft?.localArtworkPath != null;
    final hasRemoteArtwork = draft?.remoteArtworkUrl != null;

    DecorationImage? decorationImage;
    if (hasLocalArtwork) {
      decorationImage = DecorationImage(
        image: FileImage(File(draft!.localArtworkPath!)),
        fit: BoxFit.cover,
      );
    } else if (hasRemoteArtwork) {
      decorationImage = DecorationImage(
        image: NetworkImage(draft!.remoteArtworkUrl!),
        fit: BoxFit.cover,
      );
    }

    return GestureDetector(
      key: const Key('track_upload_cover_image_picker_gesture_detector'),
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white12),
          image: decorationImage,
        ),
        child: (hasLocalArtwork || hasRemoteArtwork)
            ? null
            : const Icon(
                Icons.camera_alt_outlined,
                color: Colors.white38,
                size: 28,
              ),
      ),
    );
  }
}
