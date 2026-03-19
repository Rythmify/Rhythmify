import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/core/theme/app_theme.dart';
import 'package:rythmify/features/track_upload/presentation/providers/upload_track_provider.dart';

class CoverImagePickerWidget extends ConsumerWidget {
  final VoidCallback onTap;

  const CoverImagePickerWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(uploadFormProvider).draft;
    final hasArtwork = draft?.localArtworkPath != null;

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
          image: hasArtwork
              ? DecorationImage(
                  image: FileImage(File(draft!.localArtworkPath!)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: hasArtwork
            ? null
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_rounded,
                    color: AppTheme.primaryBrand,
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add\nartwork',
                    textAlign: TextAlign.center,
                    style: AppTheme.labelSmall.copyWith(
                      color: AppTheme.primaryBrand,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}