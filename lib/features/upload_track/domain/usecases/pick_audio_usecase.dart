
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/error/failures.dart';

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
        type: FileType.audio,
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

      // Auto-detect duration using just_audio
      Duration duration = Duration.zero;
      try {
        final player = AudioPlayer();
        final detected = await player.setFilePath(picked.path!);
        duration = detected ?? Duration.zero;
        await player.dispose();
      } catch (_) {
        // Duration detection failed — not fatal
        // UseCase will catch duration = zero during upload validation
      }

      return Right(PickedAudio(
        file:      file,
        fileName:  picked.name,
        localPath: picked.path!,
        duration:  duration,
      ));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}