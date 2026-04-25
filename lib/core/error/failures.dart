import 'package:dartz/dartz.dart';

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
    super.message = 'Upload limit reached. Try again later.',
  ]);
}

// File over 100MB (413 from server)
class FileTooLargeFailure extends Failure {
  const FileTooLargeFailure([
    super.message = 'File is too large. Maximum size is 100MB.',
  ]);
}

// Wrong file format (415 from server)
class UnsupportedFileFailure extends Failure {
  const UnsupportedFileFailure([
    super.message = 'File format not supported. Use MP3, WAV, FLAC or AAC.',
  ]);
}

/// Playlist-specific failure types for M14.
///
/// These extend the core [Failure] sealed class defined in
/// `lib/core/error/failures.dart` (created by M13).
///
/// Every use case returns `Either<Failure, T>` — callers fold on these
/// types to surface the right error message in the UI.
// ignore: depend_on_referenced_packages

// Re-export core failures so feature code only needs one import.
// The actual Failure base class lives in core/error/failures.dart (M13).

/// Base failure — imported from core by M13.
/// Declared here only to satisfy the Dart analyzer during M14 development
/// before M13 is merged. Remove this declaration once M13 is on the branch.

// ── Playlist-specific failures ────────────────────────────────────────────

/// Server returned 404 for a playlist or station.
class PlaylistNotFoundFailure extends Failure {
  const PlaylistNotFoundFailure() : super('Playlist not found.');
}

/// Server returned 403 — private playlist, no access token or secret token.
class PlaylistAccessDeniedFailure extends Failure {
  const PlaylistAccessDeniedFailure() : super('This playlist is private.');
}

/// Server returned 403 — authenticated user is not the playlist owner.
class PlaylistForbiddenFailure extends Failure {
  const PlaylistForbiddenFailure()
    : super('You are not allowed to modify this playlist.');
}

/// Server returned 409 — track already exists in this playlist.
class TrackAlreadyInPlaylistFailure extends Failure {
  const TrackAlreadyInPlaylistFailure()
    : super('This track is already in the playlist.');
}

/// Server returned 422 — invalid track position supplied for add/reorder.
class PlaylistPositionInvalidFailure extends Failure {
  const PlaylistPositionInvalidFailure() : super('Invalid track position.');
}

/// Server returned 422 — playlist count limit reached on free plan.
class PlaylistLimitReachedFailure extends Failure {
  const PlaylistLimitReachedFailure()
    : super(
        'Playlist limit reached. Upgrade to Premium for unlimited playlists.',
      );
}

/// Validation error before making the request — e.g. empty name.
class PlaylistValidationFailure extends Failure {
  const PlaylistValidationFailure(super.message);
}

/// Network or server error not covered by a specific code above.
class PlaylistNetworkFailure extends Failure {
  const PlaylistNetworkFailure()
    : super('Network error. Check your connection and try again.');
}

/// Generic server-side failure (5xx).
class PlaylistServerFailure extends Failure {
  const PlaylistServerFailure()
    : super('Something went wrong on our end. Please try again.');
}

/// Station-specific: artist not found or station computation returned empty.
class StationNotFoundFailure extends Failure {
  const StationNotFoundFailure() : super('Station not found.');
}

/// User cancelled the GitHub OAuth browser, or the backend rejected the token.
class GitHubAuthFailure extends Failure {
  const GitHubAuthFailure([
    super.message = 'GitHub sign-in failed or was cancelled.',
  ]);
}
// ── Re-export Either for convenience ─────────────────────────────────────

typedef PlaylistResult<T> = Either<Failure, T>;
