// coverage:ignore-file
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

/// Base class for all authentication states in Rythmify.
///
/// Used with [AuthNotifier] (a Riverpod [Notifier]) to represent
/// the current authentication lifecycle. Extends [Equatable] so
/// Riverpod can detect state changes efficiently.
///
/// The state machine transitions:
/// ```
/// AuthInitial → AuthLoading → AuthAuthenticated
///                           → AuthUnauthenticated
///                           → AuthError
/// ```
abstract class AuthState extends Equatable {
  const AuthState();

  /// Default props — subclasses override to add their own fields.
  @override
  List<Object?> get props => [];
}

/// The initial state before any auth check has been performed.
///
/// Emitted immediately when [AuthNotifier] is first built, before
/// [checkAuthStatus] resolves.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Emitted while an auth operation is in progress.
///
/// During this state, buttons are disabled and a loading spinner
/// is shown (e.g. in [LoginPasswordPage] and [CreateAccountProfilePage]).
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Emitted when the user is successfully authenticated.
///
/// Carries the authenticated [user]'s identity. The router redirects
/// to `/home` when this state is detected.
class AuthAuthenticated extends AuthState {
  /// The currently authenticated user.
  final UserEntity user;

  /// Creates an [AuthAuthenticated] state with the given [user].
  const AuthAuthenticated(this.user);

  /// Props include [user] so equality is based on user identity.
  @override
  List<Object?> get props => [user];
}

/// Emitted when no valid session exists.
///
/// The router redirects to `/onboarding` when this state is detected.
/// Also emitted after a successful sign-out.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Emitted when an auth operation fails.
///
/// Carries the [message] from the [Failure] to display in a SnackBar.
/// The UI listens via `ref.listen(authProvider, ...)` and shows the
/// error message, then typically remains on the current screen.
class AuthError extends AuthState {
  /// The human-readable error message from the underlying [Failure].
  final String message;

  /// Creates an [AuthError] state with the given error [message].
  const AuthError(this.message);

  /// Props include [message] so identical errors are deduplicated.
  @override
  List<Object?> get props => [message];
}
