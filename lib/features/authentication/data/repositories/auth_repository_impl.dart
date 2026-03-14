import 'package:dartz/dartz.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/errors/failures.dart';
import '../datasources/auth_remote_datasource.dart';

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
  }) async {
    try {
      final user = await remoteDatasource.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
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
  Future<Either<Failure, UserEntity>> signInWithApple() async {
    try {
      final user = await remoteDatasource.signInWithApple();
      return Right(user);
    } catch (e) {
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

  // ── Maps error codes to typed Failures ───────────
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
    } else if (error.contains('network') || error.contains('socket')) {
      return const NetworkFailure();
    }
    return ServerFailure(error);
  }
}