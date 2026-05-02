import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/errors/failures.dart';

/// UseCase: PickAudioUseCase
///
/// Handles selecting an audio file from the user's device.
///
/// Responsibilities:
/// - Open file picker for audio files
/// - Validate file existence
/// - Extract file metadata (name, path, duration)
///
/// Returns:
/// - PickedAudio object on success
/// - Failure on error or invalid selection
///
/// Notes:
/// - Uses FilePicker for file selection
/// - Uses just_audio to detect duration

/// Result returned when user successfully picks an audio file
class PickedAudio {
  final File file;
  final String fileName;
  final String localPath;
  final Duration duration;

  const PickedAudio({
    required this.file,
    required this.fileName,
    required this.localPath,
    required this.duration,
  });
}

class PickAudioUseCase {
  Future<Either<Failure, PickedAudio>> call() async {
    try {
      // Open OS file browser filtered to audio only
      final result = await FilePicker.platform.pickFiles(
        type: Platform.isWindows ? FileType.custom : FileType.audio,
        allowedExtensions: Platform.isWindows ? ['mp3', 'wav', 'aac', 'm4a', 'flac'] : null,
        allowMultiple: false,
      );

      // User cancelled — not a failure, just null
      if (result == null || result.files.isEmpty) {
        return const Left(ValidationFailure('No file selected.'));
      }

      final picked = result.files.first;

      if (picked.path == null) {
        return const Left(FileFailure('Could not access the selected file.'));
      }

      final file = File(picked.path!);

      // Verify file actually exists on device
      if (!file.existsSync()) {
        return const Left(FileFailure('Selected file no longer exists.'));
      }

      // Auto-detect duration using just_audio with Windows-specific handling
      Duration duration = Duration.zero;
      try {
        final player = AudioPlayer();
        try {
          // Use Uri.file for Windows, standard path for other platforms
          final source = Platform.isWindows
              ? AudioSource.uri(Uri.file(picked.path!))
              : AudioSource.file(picked.path!);
          final detected = await player.setAudioSource(source);
          duration = detected ?? Duration.zero;
        } catch (_) {
          // Fallback: retry with delay for codec initialization
          await Future.delayed(const Duration(milliseconds: 150));
          try {
            final source = Platform.isWindows
                ? AudioSource.uri(Uri.file(picked.path!))
                : AudioSource.file(picked.path!);
            final detected = await player.setAudioSource(source);
            duration = detected ?? Duration.zero;
          } catch (_) {
            // Duration detection failed — not fatal
            // UseCase will catch duration = zero during upload validation
          }
        }
        await player.dispose();
      } catch (_) {
        // Duration detection failed — not fatal
        // UseCase will catch duration = zero during upload validation
      }

      return Right(
        PickedAudio(
          file: file,
          fileName: picked.name,
          localPath: picked.path!,
          duration: duration,
        ),
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
