import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/core/errors/failures.dart';
import 'package:rythmify/features/authentication/domain/entities/user_entity.dart';
import 'package:rythmify/features/authentication/domain/repositories/auth_repository.dart';
import 'package:rythmify/features/authentication/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:rythmify/features/authentication/domain/usecases/sign_up_with_email_usecase.dart';
import 'package:rythmify/features/authentication/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:rythmify/features/authentication/domain/usecases/sign_in_with_apple_usecase.dart';
import 'package:rythmify/features/authentication/domain/usecases/sign_out_usecase.dart';
import 'package:rythmify/features/authentication/domain/usecases/send_verification_email_usecase.dart';
import 'package:rythmify/features/authentication/domain/usecases/send_password_reset_usecase.dart';

// ---------------------------------------------------------------------------
// Mock
// ---------------------------------------------------------------------------

class MockAuthRepository extends Mock implements AuthRepository {}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const tUser = UserEntity(
  id: 'user-001',
  email: 'karim@rythmify.com',
  displayName: 'KarimWI',
  isEmailVerified: true,
  token: 'mock-jwt-token-user-001',
);

void main() {
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
  });

  // =========================================================================
  // SignInWithEmailUseCase
  // =========================================================================

  group('SignInWithEmailUseCase', () {
    late SignInWithEmailUseCase useCase;

    setUp(() {
      useCase = SignInWithEmailUseCase(mockRepository);
    });

    test('should return UserEntity when credentials are valid', () async {
      when(() => mockRepository.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Right(tUser));

      final result = await useCase(
        email: 'karim@rythmify.com',
        password: 'Karim123!',
      );

      expect(result, const Right(tUser));
      verify(() => mockRepository.signInWithEmail(
            email: 'karim@rythmify.com',
            password: 'Karim123!',
          )).called(1);
    });

    test('should return InvalidCredentialsFailure when credentials are wrong',
        () async {
      when(() => mockRepository.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer(
              (_) async => const Left(InvalidCredentialsFailure()));

      final result = await useCase(
        email: 'wrong@test.com',
        password: 'wrong',
      );

      expect(result, isA<Left>());
      expect(
          (result as Left).value, isA<InvalidCredentialsFailure>());
    });

    test('should return EmailNotVerifiedFailure when email is unverified',
        () async {
      when(() => mockRepository.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer(
              (_) async => const Left(EmailNotVerifiedFailure()));

      final result = await useCase(
        email: 'karim@rythmify.com',
        password: 'Karim123!',
      );

      expect((result as Left).value, isA<EmailNotVerifiedFailure>());
    });

    test('should return NetworkFailure when there is no connection', () async {
      when(() => mockRepository.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Left(NetworkFailure()));

      final result = await useCase(
        email: 'karim@rythmify.com',
        password: 'Karim123!',
      );

      expect((result as Left).value, isA<NetworkFailure>());
    });

    test('should pass email and password directly to repository', () async {
      when(() => mockRepository.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Right(tUser));

      await useCase(email: 'test@test.com', password: 'Pass123!');

      verify(() => mockRepository.signInWithEmail(
            email: 'test@test.com',
            password: 'Pass123!',
          )).called(1);
    });
  });

  // =========================================================================
  // SignUpWithEmailUseCase
  // =========================================================================

  group('SignUpWithEmailUseCase', () {
    late SignUpWithEmailUseCase useCase;

    setUp(() {
      useCase = SignUpWithEmailUseCase(mockRepository);
    });

    test('should return UserEntity when registration succeeds', () async {
      when(() => mockRepository.signUpWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
            gender: any(named: 'gender'),
            dateOfBirth: any(named: 'dateOfBirth'),
          )).thenAnswer((_) async => const Right(tUser));

      final result = await useCase(
        email: 'karim@rythmify.com',
        password: 'Karim123!',
        displayName: 'KarimWI',
        gender: 'male',
        dateOfBirth: '2000-01-01',
      );

      expect(result, const Right(tUser));
    });

    test('should return EmailAlreadyInUseFailure when email is taken',
        () async {
      when(() => mockRepository.signUpWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
            gender: any(named: 'gender'),
            dateOfBirth: any(named: 'dateOfBirth'),
          )).thenAnswer(
              (_) async => const Left(EmailAlreadyInUseFailure()));

      final result = await useCase(
        email: 'karim@rythmify.com',
        password: 'Karim123!',
        displayName: 'KarimWI',
        gender: 'male',
        dateOfBirth: '2000-01-01',
      );

      expect((result as Left).value, isA<EmailAlreadyInUseFailure>());
    });

    test('should return NetworkFailure when there is no connection', () async {
      when(() => mockRepository.signUpWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
            gender: any(named: 'gender'),
            dateOfBirth: any(named: 'dateOfBirth'),
          )).thenAnswer((_) async => const Left(NetworkFailure()));

      final result = await useCase(
        email: 'karim@rythmify.com',
        password: 'Karim123!',
        displayName: 'KarimWI',
        gender: 'male',
        dateOfBirth: '2000-01-01',
      );

      expect((result as Left).value, isA<NetworkFailure>());
    });

    test('should pass all parameters to repository correctly', () async {
      when(() => mockRepository.signUpWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
            gender: any(named: 'gender'),
            dateOfBirth: any(named: 'dateOfBirth'),
          )).thenAnswer((_) async => const Right(tUser));

      await useCase(
        email: 'new@rythmify.com',
        password: 'New123!',
        displayName: 'NewUser',
        gender: 'female',
        dateOfBirth: '1995-06-15',
      );

      verify(() => mockRepository.signUpWithEmail(
            email: 'new@rythmify.com',
            password: 'New123!',
            displayName: 'NewUser',
            gender: 'female',
            dateOfBirth: '1995-06-15',
          )).called(1);
    });

    test('should return ValidationFailure when data is invalid', () async {
      when(() => mockRepository.signUpWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
            gender: any(named: 'gender'),
            dateOfBirth: any(named: 'dateOfBirth'),
          )).thenAnswer((_) async =>
              const Left(ValidationFailure('Invalid date of birth')));

      final result = await useCase(
        email: 'karim@rythmify.com',
        password: 'Karim123!',
        displayName: 'KarimWI',
        gender: 'male',
        dateOfBirth: '2030-01-01',
      );

      expect((result as Left).value, isA<ValidationFailure>());
    });
  });

  // =========================================================================
  // SignInWithGoogleUseCase
  // =========================================================================

  group('SignInWithGoogleUseCase', () {
    late SignInWithGoogleUseCase useCase;

    setUp(() {
      useCase = SignInWithGoogleUseCase(mockRepository);
    });

    test('should return UserEntity when Google sign-in succeeds', () async {
      when(() => mockRepository.signInWithGoogle())
          .thenAnswer((_) async => const Right(tUser));

      final result = await useCase();

      expect(result, const Right(tUser));
      verify(() => mockRepository.signInWithGoogle()).called(1);
    });

    test('should return Failure when Google sign-in fails', () async {
      when(() => mockRepository.signInWithGoogle()).thenAnswer(
          (_) async => const Left(ServerFailure('Google sign-in failed')));

      final result = await useCase();

      expect(result, isA<Left>());
    });

    test('should return NetworkFailure when there is no connection', () async {
      when(() => mockRepository.signInWithGoogle())
          .thenAnswer((_) async => const Left(NetworkFailure()));

      final result = await useCase();

      expect((result as Left).value, isA<NetworkFailure>());
    });
  });

  // =========================================================================
  // SignInWithAppleUseCase
  // =========================================================================

  group('SignInWithAppleUseCase', () {
    late SignInWithAppleUseCase useCase;

    setUp(() {
      useCase = SignInWithAppleUseCase(mockRepository);
    });

    test('should return UserEntity when Apple sign-in succeeds', () async {
      when(() => mockRepository.signInWithApple())
          .thenAnswer((_) async => const Right(tUser));

      final result = await useCase();

      expect(result, const Right(tUser));
      verify(() => mockRepository.signInWithApple()).called(1);
    });

    test('should return Failure when Apple sign-in fails', () async {
      when(() => mockRepository.signInWithApple()).thenAnswer(
          (_) async => const Left(ServerFailure('Apple sign-in failed')));

      final result = await useCase();

      expect(result, isA<Left>());
    });

    test('should return NetworkFailure when there is no connection', () async {
      when(() => mockRepository.signInWithApple())
          .thenAnswer((_) async => const Left(NetworkFailure()));

      final result = await useCase();

      expect((result as Left).value, isA<NetworkFailure>());
    });
  });

  // =========================================================================
  // SignOutUseCase
  // =========================================================================

  group('SignOutUseCase', () {
    late SignOutUseCase useCase;

    setUp(() {
      useCase = SignOutUseCase(mockRepository);
    });

    test('should return Right(void) when sign-out succeeds', () async {
      when(() => mockRepository.signOut())
          .thenAnswer((_) async => const Right(null));

      final result = await useCase();

      expect(result, const Right(null));
      verify(() => mockRepository.signOut()).called(1);
    });

    test('should return Failure when sign-out fails', () async {
      when(() => mockRepository.signOut()).thenAnswer(
          (_) async => const Left(ServerFailure('Sign-out failed')));

      final result = await useCase();

      expect(result, isA<Left>());
    });

    test('should return NetworkFailure when there is no connection', () async {
      when(() => mockRepository.signOut())
          .thenAnswer((_) async => const Left(NetworkFailure()));

      final result = await useCase();

      expect((result as Left).value, isA<NetworkFailure>());
    });
  });

  // =========================================================================
  // SendVerificationEmailUseCase
  // =========================================================================

  group('SendVerificationEmailUseCase', () {
    late SendVerificationEmailUseCase useCase;

    setUp(() {
      useCase = SendVerificationEmailUseCase(mockRepository);
    });

    test('should return Right(void) when email is sent successfully', () async {
      when(() => mockRepository.sendVerificationEmail())
          .thenAnswer((_) async => const Right(null));

      final result = await useCase();

      expect(result, const Right(null));
      verify(() => mockRepository.sendVerificationEmail()).called(1);
    });

    test('should return Failure when sending fails', () async {
      when(() => mockRepository.sendVerificationEmail()).thenAnswer(
          (_) async =>
              const Left(ServerFailure('Failed to send verification email')));

      final result = await useCase();

      expect(result, isA<Left>());
    });

    test('should return NetworkFailure when there is no connection', () async {
      when(() => mockRepository.sendVerificationEmail())
          .thenAnswer((_) async => const Left(NetworkFailure()));

      final result = await useCase();

      expect((result as Left).value, isA<NetworkFailure>());
    });
  });

  // =========================================================================
  // SendPasswordResetUseCase
  // =========================================================================

  group('SendPasswordResetUseCase', () {
    late SendPasswordResetUseCase useCase;

    setUp(() {
      useCase = SendPasswordResetUseCase(mockRepository);
    });

    test('should return Right(void) when reset email is sent', () async {
      when(() => mockRepository.sendPasswordReset(
            email: any(named: 'email'),
          )).thenAnswer((_) async => const Right(null));

      final result =
          await useCase(email: 'karim@rythmify.com');

      expect(result, const Right(null));
      verify(() => mockRepository.sendPasswordReset(
            email: 'karim@rythmify.com',
          )).called(1);
    });

    test('should return InvalidCredentialsFailure when email is not registered',
        () async {
      when(() => mockRepository.sendPasswordReset(
            email: any(named: 'email'),
          )).thenAnswer(
              (_) async => const Left(InvalidCredentialsFailure()));

      final result =
          await useCase(email: 'notregistered@test.com');

      expect((result as Left).value, isA<InvalidCredentialsFailure>());
    });

    test('should return NetworkFailure when there is no connection', () async {
      when(() => mockRepository.sendPasswordReset(
            email: any(named: 'email'),
          )).thenAnswer((_) async => const Left(NetworkFailure()));

      final result = await useCase(email: 'karim@rythmify.com');

      expect((result as Left).value, isA<NetworkFailure>());
    });

    test('should pass email directly to repository', () async {
      when(() => mockRepository.sendPasswordReset(
            email: any(named: 'email'),
          )).thenAnswer((_) async => const Right(null));

      await useCase(email: 'specific@email.com');

      verify(() => mockRepository.sendPasswordReset(
            email: 'specific@email.com',
          )).called(1);
    });

    test('should handle empty string email', () async {
      when(() => mockRepository.sendPasswordReset(
            email: any(named: 'email'),
          )).thenAnswer(
              (_) async => const Left(InvalidCredentialsFailure()));

      final result = await useCase(email: '');

      expect(result, isA<Left>());
    });
  });
}
