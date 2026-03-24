/// UseCase: PickCoverUseCase
///
/// Handles selecting a cover image from camera or gallery.
///
/// Responsibilities:
/// - Open image picker
/// - Compress and resize image
/// - Validate file existence
///
/// Returns:
/// - File on success
/// - Failure on error or cancellation
///
/// Notes:
/// - Uses image_picker package
/// - Optimizes image size for upload performance
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/failures.dart';

class PickCoverUseCase {
  final ImagePicker _picker = ImagePicker();

  Future<Either<Failure, File>> call(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85, // compress to 85%
        maxWidth: 1000, // max 1000px wide
        maxHeight: 1000, // max 1000px tall
        source: source,
        imageQuality: 85, // compress to 85%
        maxWidth: 1000, // max 1000px wide
        maxHeight: 1000, // max 1000px tall
      );

      // User cancelled
      if (picked == null) {
        return const Left(ValidationFailure('No image selected.'));
      }

      final file = File(picked.path);

      if (!file.existsSync()) {
        return const Left(FileFailure('Could not access the selected image.'));
      }

      return Right(file);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}

