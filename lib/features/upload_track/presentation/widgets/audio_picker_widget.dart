/// features/upload_track/presentation/widgets/audio_picker_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/upload_track_provider.dart';

class AudioPickerWidget extends ConsumerWidget {
  const AudioPickerWidget({super.key});

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(uploadFormProvider).draft;

    if (draft == null) return const SizedBox.shrink();

    // Extract filename from path
    final fileName = draft.localAudioPath.split('/').last;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white12,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Music note icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primaryBrand.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.music_note_rounded,
              color: AppTheme.primaryBrand,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // File name and duration
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: AppTheme.labelLarge,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 3),
                Text(
                  _formatDuration(draft.duration),
                  style: AppTheme.labelSmall,
                ),
              ],
            ),
          ),

          // Check icon — confirms file is selected
          const Icon(
            Icons.check_circle_rounded,
            color: AppTheme.primaryBrand,
            size: 20,
          ),
        ],
      ),
    );
  }
}