abstract class Failure {
  final String message;
  const Failure(this.message);
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure() : super('Invalid email or password.');
}

class EmailNotVerifiedFailure extends Failure {
  const EmailNotVerifiedFailure() : super('Please verify your email before signing in.');
}

class EmailAlreadyInUseFailure extends Failure {
  const EmailAlreadyInUseFailure() : super('An account with this email already exists.');
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('No internet connection. Please try again.');
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

class UnknownFailure extends Failure {
  const UnknownFailure() : super('An unexpected error occurred.');
}

class AccountSuspendedFailure extends Failure {
  const AccountSuspendedFailure() : super('Your account has been suspended.');
}

class RefreshTokenInvalidFailure extends Failure {
  const RefreshTokenInvalidFailure() : super('Your session has expired. Please sign in again.');
}

class TooManyRequestsFailure extends Failure {
  const TooManyRequestsFailure() : super('Too many attempts. Please try again later.');
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