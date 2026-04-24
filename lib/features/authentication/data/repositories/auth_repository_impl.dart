import 'package:dartz/dartz.dart';
import '../../domain/entities/user_entity.dart';
import '../../data/datasources/discord_auth_data.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/errors/failures.dart';
import '../datasources/auth_remote_datasource.dart';

/// Concrete implementation of [AuthRepository].
///
/// Maps datasource results and exceptions to domain [Failure] types
/// using [_mapError] for string-based errors and explicit catches for
/// OAuth-specific exceptions.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;

  AuthRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDatasource.signInWithEmail(
        email: email,
        password: password,
      );
      return Right(user);
    } catch (e) {
      return Left(_mapError(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String gender,
    required String dateOfBirth,
  }) async {
    try {
      final user = await remoteDatasource.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
        gender: gender,
        dateOfBirth: dateOfBirth,
      );
      return Right(user);
    } catch (e) {
      return Left(_mapError(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final user = await remoteDatasource.signInWithGoogle();
      return Right(user);
    } catch (e) {
      return Left(_mapError(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithGoogle({
    required String idToken,
    required String gender,
    required String dateOfBirth,
  }) async {
    try {
      final user = await remoteDatasource.signUpWithGoogle(
        idToken: idToken,
        gender: gender,
        dateOfBirth: dateOfBirth,
      );
      return Right(user);
    } catch (e) {
      return Left(_mapError(e.toString()));
    }
  }

  /// Opens the GitHub OAuth browser, exchanges the code, and persists
  /// the returned access token via the datasource layer.
  ///
  /// Returns [Right] with [GitHubAuthData] on success.
  /// Returns [Left] with [GitHubAuthFailure] if the user cancels the
  /// browser, or [ServerFailure] for any backend error.
  @override
  Future<Either<Failure, GitHubAuthData>> loginWithGitHub() async {
    try {
      final data = await remoteDatasource.loginWithGitHub();
      final authData = GitHubAuthData.fromJson(data);
      return Right(authData);
    } on Exception catch (e) {
      if (e.toString().contains('cancelled') ||
          e.toString().contains('USER_CANCELLED')) {
        return const Left(GitHubAuthFailure());
      }
      return Left(_mapError(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDatasource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(_mapError(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendVerificationEmail() async {
    try {
      await remoteDatasource.sendVerificationEmail();
      return const Right(null);
    } catch (e) {
      return Left(_mapError(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordReset({
    required String email,
  }) async {
    try {
      await remoteDatasource.sendPasswordReset(email: email);
      return const Right(null);
    } catch (e) {
      return Left(_mapError(e.toString()));
    }
  }

  Failure _mapError(String error) {
    if (error.contains('AUTH_INVALID_CREDENTIALS')) {
      return const InvalidCredentialsFailure();
    } else if (error.contains('AUTH_EMAIL_NOT_VERIFIED')) {
      return const EmailNotVerifiedFailure();
    } else if (error.contains('AUTH_EMAIL_ALREADY_EXISTS')) {
      return const EmailAlreadyInUseFailure();
    } else if (error.contains('AUTH_ACCOUNT_SUSPENDED')) {
      return const AccountSuspendedFailure();
    } else if (error.contains('AUTH_REFRESH_TOKEN_INVALID')) {
      return const RefreshTokenInvalidFailure();
    } else if (error.contains('RATE_LIMIT_EXCEEDED')) {
      return const TooManyRequestsFailure();
    } else if (error.contains('github') || error.contains('cancelled')) {
      return const GitHubAuthFailure();
    } else if (error.contains('network') || error.contains('socket')) {
      return const NetworkFailure();
    }
    return ServerFailure(error);
  }
}
