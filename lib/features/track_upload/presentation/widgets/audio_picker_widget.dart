import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/track_upload/presentation/providers/upload_track_provider.dart';
import 'package:rythmify/features/track_upload/presentation/widgets/upload_button_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_provider.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_state.dart';

/// Widget: AudioPickerWidget
///
/// Displays selected audio file information and upload progress button.
///
/// Responsibilities:
/// - Show audio file name
/// - Display upload progress button
/// - Allow user to replace the audio file

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

   final authState = ref.read(authProvider);
final displayName = authState is AuthAuthenticated
    ? authState.user.displayName
    : 'Your Name';

ref
    .read(uploadFormProvider.notifier)
    .initDraft(
      artistId:      'dev_user_001',
      artistName:    displayName,
      localAudioPath: picked.path!,
      duration:      duration,
      fileName:      picked.name,
    );
    ref.read(uploadFormProvider.notifier).startAudioUpload();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(uploadFormProvider);
    final draft = state.draft;

    if (draft == null) return const SizedBox.shrink();

    final fileName =
        draft.audioFileName ?? draft.localAudioPath.split('/').last;

    return Column(
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
          status: draft.audioStatus,
          progress: draft.audioUploadProgress,
          onReplace: () => _replaceAudio(context, ref),
        ),
      ],
    );
  }
}
