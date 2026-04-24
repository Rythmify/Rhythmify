/// Base class for all domain-layer failures in Rythmify.
///
/// Every error that bubbles up through the [Either] system is a subclass
/// of [Failure]. The [message] field provides a human-readable description
/// suitable for display in the UI (e.g. inside a SnackBar).
abstract class Failure {
  /// A human-readable description of what went wrong.
  final String message;

  /// Creates a [Failure] with the given [message].
  const Failure(this.message);
}

/// Thrown when the user supplies an incorrect email or password.
///
/// Maps to the `AUTH_INVALID_CREDENTIALS` error code from the backend.
class InvalidCredentialsFailure extends Failure {
  /// Creates an [InvalidCredentialsFailure] with a fixed message.
  const InvalidCredentialsFailure() : super('Invalid email or password.');
}

/// Thrown when the user attempts to sign in before verifying their email.
///
/// Maps to the `AUTH_EMAIL_NOT_VERIFIED` error code from the backend.
class EmailNotVerifiedFailure extends Failure {
  /// Creates an [EmailNotVerifiedFailure] with a fixed message.
  const EmailNotVerifiedFailure()
    : super('Please verify your email before signing in.');
}

/// Thrown when a registration attempt uses an email already in use.
///
/// Maps to the `AUTH_EMAIL_ALREADY_EXISTS` error code from the backend.
class EmailAlreadyInUseFailure extends Failure {
  /// Creates an [EmailAlreadyInUseFailure] with a fixed message.
  const EmailAlreadyInUseFailure()
    : super('An account with this email already exists.');
}

/// Thrown when a network request fails due to no internet connection.
///
/// Detected by catching `SocketException` or `DioException` connection errors.
class NetworkFailure extends Failure {
  /// Creates a [NetworkFailure] with a fixed message.
  const NetworkFailure() : super('No internet connection. Please try again.');
}

/// Thrown when the backend returns an unexpected error.
///
/// The [message] is populated from the backend's error response body
/// when available, or a generic description when not.
class ServerFailure extends Failure {
  /// Creates a [ServerFailure] with the given [message] from the server.
  const ServerFailure(super.message);
}

/// Thrown when an unexpected exception occurs that doesn't fit any category.
class UnknownFailure extends Failure {
  /// Creates an [UnknownFailure] with a fixed message.
  const UnknownFailure() : super('An unexpected error occurred.');
}

/// Thrown when the user's account has been suspended by an administrator.
///
/// Maps to the `AUTH_ACCOUNT_SUSPENDED` error code from the backend.
class AccountSuspendedFailure extends Failure {
  /// Creates an [AccountSuspendedFailure] with a fixed message.
  const AccountSuspendedFailure() : super('Your account has been suspended.');
}

/// Thrown when the JWT refresh token has expired or is invalid.
///
/// Maps to the `AUTH_REFRESH_TOKEN_INVALID` error code. When this occurs
/// the user must sign in again.
class RefreshTokenInvalidFailure extends Failure {
  /// Creates a [RefreshTokenInvalidFailure] with a fixed message.
  const RefreshTokenInvalidFailure()
    : super('Your session has expired. Please sign in again.');
}

/// Thrown when the user or IP has exceeded the allowed request rate.
///
/// Maps to the `RATE_LIMIT_EXCEEDED` error code from the backend.
class TooManyRequestsFailure extends Failure {
  /// Creates a [TooManyRequestsFailure] with a fixed message.
  const TooManyRequestsFailure()
    : super('Too many attempts. Please try again later.');
}

/// Thrown when a file cannot be read from the device.
///
/// Used in upload flows when the selected file no longer exists or
/// cannot be accessed.
class FileFailure extends Failure {
  /// Creates a [FileFailure] with an optional custom [message].
  const FileFailure([super.message = 'Could not read the selected file.']);
}

/// Thrown when user-supplied data fails backend or client-side validation.
///
/// Maps to the `VALIDATION_FAILED` error code. The [message] contains
/// the specific validation error from the backend.
class ValidationFailure extends Failure {
  /// Creates a [ValidationFailure] with the given validation [message].
  const ValidationFailure(super.message);
}

/// Thrown when an operation requires authentication but no token is present.
///
/// Used when a protected endpoint is called without a valid JWT token.
class AuthFailure extends Failure {
  /// Creates an [AuthFailure] with an optional custom [message].
  const AuthFailure([super.message = 'You must be logged in.']);
}

/// Thrown when a file upload operation fails on the backend.
///
/// Different from [FileFailure] which is a local read error — this
/// indicates the server rejected or failed to process the upload.
class UploadFailure extends Failure {
  /// Creates an [UploadFailure] with the given [message].
  const UploadFailure(super.message);
}

/// Thrown when an unexpected exception occurs that has no specific mapping.
///
/// Similar to [UnknownFailure] but used specifically in the upload module.
class UnexpectedFailure extends Failure {
  /// Creates an [UnexpectedFailure] with an optional custom [message].
  const UnexpectedFailure([super.message = 'An unexpected error occurred.']);
}

/// Thrown when the user has reached the maximum upload limit (20/hour).
///
/// Maps to a 403 response from the backend's upload endpoint.
class UploadLimitFailure extends Failure {
  /// Creates an [UploadLimitFailure] with a fixed message.
  const UploadLimitFailure([
    super.message = 'Upload limit reached. Try again later.',
  ]);
}

/// Thrown when the uploaded file exceeds the 100MB size limit.
///
/// Maps to a 413 response from the backend's upload endpoint.
class FileTooLargeFailure extends Failure {
  /// Creates a [FileTooLargeFailure] with a fixed message.
  const FileTooLargeFailure([
    super.message = 'File is too large. Maximum size is 100MB.',
  ]);
}

/// Thrown when a GitHub OAuth authentication fails.
///
/// Can occur when the user cancels the OAuth flow or the browser returns an error.
class GitHubAuthFailure extends Failure {
  /// Creates a [GitHubAuthFailure] with a fixed message.
  const GitHubAuthFailure()
    : super('GitHub authentication failed. Please try again.');
}

/// Thrown when the uploaded file format is not supported.
///
/// Maps to a 415 response from the backend. Accepted formats are
/// MP3, WAV, FLAC, and AAC.
class UnsupportedFileFailure extends Failure {
  /// Creates an [UnsupportedFileFailure] with a fixed message.
  const UnsupportedFileFailure([
    super.message = 'File format not supported. Use MP3, WAV, FLAC or AAC.',
  ]);
}
