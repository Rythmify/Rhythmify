import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/core/errors/failures.dart';
import 'package:rythmify/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:rythmify/features/authentication/data/models/user_model.dart';
import 'package:rythmify/features/authentication/data/repositories/auth_repository_impl.dart';

class MockAuthRemoteDatasource extends Mock implements AuthRemoteDatasource {}

void main() {
  late MockAuthRemoteDatasource datasource;
  late AuthRepositoryImpl repository;

  const user = UserModel(
    id: 'u1',
    email: 'u@test.com',
    displayName: 'User',
    isEmailVerified: true,
    token: 't',
  );

  setUp(() {
    datasource = MockAuthRemoteDatasource();
    repository = AuthRepositoryImpl(remoteDatasource: datasource);
  });

  test('returns Right for successful auth operations', () async {
    when(() => datasource.signInWithEmail(email: 'u@test.com', password: 'P'))
        .thenAnswer((_) async => user);
    when(() => datasource.signUpWithEmail(
          email: 'u@test.com',
          password: 'P',
          displayName: 'User',
          gender: 'male',
          dateOfBirth: '2000-01-01',
        )).thenAnswer((_) async => user);
    when(() => datasource.signInWithGoogle()).thenAnswer((_) async => user);
    when(() => datasource.signInWithApple()).thenAnswer((_) async => user);
    when(() => datasource.signOut()).thenAnswer((_) async {});
    when(() => datasource.sendVerificationEmail()).thenAnswer((_) async {});
    when(() => datasource.sendPasswordReset(email: 'u@test.com'))
        .thenAnswer((_) async {});

    expect(
      (await repository.signInWithEmail(email: 'u@test.com', password: 'P'))
          .isRight(),
      true,
    );
    expect(
      (await repository.signUpWithEmail(
        email: 'u@test.com',
        password: 'P',
        displayName: 'User',
        gender: 'male',
        dateOfBirth: '2000-01-01',
      ))
          .isRight(),
      true,
    );
    expect((await repository.signInWithGoogle()).isRight(), true);
    expect((await repository.signInWithApple()).isRight(), true);
    expect((await repository.signOut()).isRight(), true);
    expect((await repository.sendVerificationEmail()).isRight(), true);
    expect((await repository.sendPasswordReset(email: 'u@test.com')).isRight(), true);
  });

  test('maps known auth error codes to typed failures', () async {
    when(() => datasource.signInWithEmail(email: 'u@test.com', password: 'P'))
        .thenThrow(Exception('AUTH_INVALID_CREDENTIALS'));
    when(() => datasource.signInWithGoogle())
        .thenThrow(Exception('AUTH_EMAIL_NOT_VERIFIED'));
    when(() => datasource.signInWithApple())
        .thenThrow(Exception('AUTH_EMAIL_ALREADY_EXISTS'));
    when(() => datasource.signOut())
        .thenThrow(Exception('AUTH_ACCOUNT_SUSPENDED'));
    when(() => datasource.sendVerificationEmail())
        .thenThrow(Exception('AUTH_REFRESH_TOKEN_INVALID'));
    when(() => datasource.sendPasswordReset(email: 'u@test.com'))
        .thenThrow(Exception('RATE_LIMIT_EXCEEDED'));

    expect(
      (await repository.signInWithEmail(email: 'u@test.com', password: 'P'))
          .fold((l) => l, (_) => null),
      isA<InvalidCredentialsFailure>(),
    );
    expect(
      (await repository.signInWithGoogle()).fold((l) => l, (_) => null),
      isA<EmailNotVerifiedFailure>(),
    );
    expect(
      (await repository.signInWithApple()).fold((l) => l, (_) => null),
      isA<EmailAlreadyInUseFailure>(),
    );
    expect(
      (await repository.signOut()).fold((l) => l, (_) => null),
      isA<AccountSuspendedFailure>(),
    );
    expect(
      (await repository.sendVerificationEmail()).fold((l) => l, (_) => null),
      isA<RefreshTokenInvalidFailure>(),
    );
    expect(
      (await repository.sendPasswordReset(email: 'u@test.com'))
          .fold((l) => l, (_) => null),
      isA<TooManyRequestsFailure>(),
    );
  });

  test('maps network and unknown errors', () async {
    when(() => datasource.signInWithEmail(email: 'u@test.com', password: 'P'))
        .thenThrow(Exception('socket timeout'));
    when(() => datasource.signInWithGoogle())
        .thenThrow(Exception('UNHANDLED_ERROR'));

    expect(
      (await repository.signInWithEmail(email: 'u@test.com', password: 'P'))
          .fold((l) => l, (_) => null),
      isA<NetworkFailure>(),
    );

    final unknown = (await repository.signInWithGoogle()).fold((l) => l, (_) => null);
    expect(unknown, isA<ServerFailure>());
    expect((unknown as ServerFailure).message, contains('UNHANDLED_ERROR'));
  });
}
