abstract class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});
}

class FileFailure extends Failure {
  const FileFailure([super.message = 'Could not read the selected file.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'You must be logged in.']);
}

class UploadFailure extends Failure {
  const UploadFailure(super.message);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'An unexpected error occurred.']);
}

// Upload limit reached (403 from server — 20 uploads/hour)
class UploadLimitFailure extends Failure {
  const UploadLimitFailure([
    super.message = 'Upload limit reached. Try again later.'
  ]);
}

// File over 100MB (413 from server)
class FileTooLargeFailure extends Failure {
  const FileTooLargeFailure([
    super.message = 'File is too large. Maximum size is 100MB.'
  ]);
}

// Wrong file format (415 from server)
class UnsupportedFileFailure extends Failure {
  const UnsupportedFileFailure([
    super.message = 'File format not supported. Use MP3, WAV, FLAC or AAC.'
  ]);
}