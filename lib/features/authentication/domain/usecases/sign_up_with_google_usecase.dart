import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case that completes registration for a user who signed in via Google OAuth.
///
/// This is called after [SignInWithGoogleUseCase] when the user is redirected from
/// Google Sign-In to the registration page. It sends the Google ID token along with
/// the remaining profile data (gender and date of birth) to complete account setup.
///
/// Delegates to [AuthRepository.signUpWithGoogle].
class SignUpWithGoogleUseCase {
  /// The repository used to perform Google registration.
  final AuthRepository repository;

  /// Creates a [SignUpWithGoogleUseCase] with the given [repository].
  SignUpWithGoogleUseCase(this.repository);

  /// Executes the Google registration flow.
  ///
  /// [idToken] — the Google ID token obtained during sign-in.
  /// [gender] — the user's gender (e.g., 'male', 'female').
  /// [dateOfBirth] — the user's date of birth in YYYY-MM-DD format.
  ///
  /// Returns [Right] with a [UserEntity] on success, or [Left] with
  /// a [Failure] if registration fails.
  Future<Either<Failure, UserEntity>> call({
    required String idToken,
    required String gender,
    required String dateOfBirth,
  }) {
    return repository.signUpWithGoogle(
      idToken: idToken,
      gender: gender,
      dateOfBirth: dateOfBirth,
    );
  }
}
