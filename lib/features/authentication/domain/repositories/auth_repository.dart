import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String gender,
    required String dateOfBirth,
  });

  Future<Either<Failure, UserEntity>> signInWithGoogle();

  Future<Either<Failure, UserEntity>> signInWithApple();

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, void>> sendVerificationEmail();

  Future<Either<Failure, void>> sendPasswordReset({required String email});

}
