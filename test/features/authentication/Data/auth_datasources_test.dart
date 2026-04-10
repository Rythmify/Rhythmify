// Tests for auth_remote_datasource_impl.dart
// Strategy: mock the Dio instance via a DioAdapter, test _handleDioError
// mapping and response parsing logic.
//
// Tests for auth_mock_datasource.dart
// Strategy: call methods directly, verify behaviour against in-memory state.

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/authentication/data/datasources/auth_mock_datasource.dart';
import 'package:rythmify/features/authentication/data/datasources/auth_remote_datasource_impl.dart';
import 'package:rythmify/features/authentication/data/models/user_model.dart';
import 'package:rythmify/core/network/api_client.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockApiClient extends Mock implements ApiClient {}

class MockDio extends Mock implements Dio {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Builds a [Response] for the login endpoint.
Response<dynamic> loginSuccessResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/auth/login'),
    statusCode: 200,
    data: {
      'data': {
        'access_token': 'jwt-token-abc',
        'user': {
          'user_id': 'user-001',
          'email': 'karim@rythmify.com',
          'display_name': 'KarimWI',
          'is_verified': true,
        },
      },
    },
  );
}

/// Builds a [Response] for the register endpoint.
Response<dynamic> registerSuccessResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/auth/register'),
    statusCode: 201,
    data: {
      'data': {
        'user_id': 'user-001',
        'email': 'karim@rythmify.com',
        'display_name': 'KarimWI',
      },
    },
  );
}

/// Builds a [DioException] that simulates a backend error response.
DioException makeDioError(String code, {String? message}) {
  return DioException(
    requestOptions: RequestOptions(path: '/auth/login'),
    response: Response(
      requestOptions: RequestOptions(path: '/auth/login'),
      statusCode: 401,
      data: {
        'error': {'code': code, 'message': message ?? '$code error message'},
      },
    ),
    type: DioExceptionType.badResponse,
  );
}

// ---------------------------------------------------------------------------
// AuthRemoteDatasourceImpl tests
// ---------------------------------------------------------------------------

void main() {
  late MockApiClient mockApiClient;
  late MockDio mockDio;
  late AuthRemoteDatasourceImpl datasource;

  setUp(() {
    mockApiClient = MockApiClient();
    mockDio = MockDio();
    when(() => mockApiClient.dio).thenReturn(mockDio);
    datasource = AuthRemoteDatasourceImpl(client: mockApiClient);
  });

  group('AuthRemoteDatasourceImpl.signInWithEmail', () {
    test('should return UserModel when login succeeds', () async {
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => loginSuccessResponse());

      when(() => mockApiClient.saveToken(any())).thenAnswer((_) async {});

      final result = await datasource.signInWithEmail(
        email: 'karim@rythmify.com',
        password: 'Karim123!',
      );

      expect(result, isA<UserModel>());
      expect(result.id, 'user-001');
      expect(result.token, 'jwt-token-abc');
    });

    test('should save token after successful login', () async {
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => loginSuccessResponse());
      when(() => mockApiClient.saveToken(any())).thenAnswer((_) async {});

      await datasource.signInWithEmail(
        email: 'karim@rythmify.com',
        password: 'Karim123!',
      );

      verify(() => mockApiClient.saveToken('jwt-token-abc')).called(1);
    });

    test('should send identifier field (not email) in request body', () async {
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => loginSuccessResponse());
      when(() => mockApiClient.saveToken(any())).thenAnswer((_) async {});

      await datasource.signInWithEmail(
        email: 'karim@rythmify.com',
        password: 'Karim123!',
      );

      verify(
        () => mockDio.post(
          '/auth/login',
          data: {'identifier': 'karim@rythmify.com', 'password': 'Karim123!'},
        ),
      ).called(1);
    });

    test(
      'should throw AUTH_INVALID_CREDENTIALS on 401 with that code',
      () async {
        when(
          () => mockDio.post(any(), data: any(named: 'data')),
        ).thenThrow(makeDioError('AUTH_INVALID_CREDENTIALS'));

        expect(
          () => datasource.signInWithEmail(
            email: 'bad@test.com',
            password: 'wrong',
          ),
          throwsA(
            predicate<Exception>(
              (e) => e.toString().contains('AUTH_INVALID_CREDENTIALS'),
            ),
          ),
        );
      },
    );

    test('should throw AUTH_EMAIL_NOT_VERIFIED on that code', () async {
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenThrow(makeDioError('AUTH_EMAIL_NOT_VERIFIED'));

      expect(
        () => datasource.signInWithEmail(
          email: 'karim@rythmify.com',
          password: 'Karim123!',
        ),
        throwsA(
          predicate<Exception>(
            (e) => e.toString().contains('AUTH_EMAIL_NOT_VERIFIED'),
          ),
        ),
      );
    });

    test('should throw AUTH_ACCOUNT_SUSPENDED on that code', () async {
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenThrow(makeDioError('AUTH_ACCOUNT_SUSPENDED'));

      expect(
        () => datasource.signInWithEmail(
          email: 'karim@rythmify.com',
          password: 'Karim123!',
        ),
        throwsA(
          predicate<Exception>(
            (e) => e.toString().contains('AUTH_ACCOUNT_SUSPENDED'),
          ),
        ),
      );
    });

    test('should throw RATE_LIMIT_EXCEEDED on that code', () async {
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenThrow(makeDioError('RATE_LIMIT_EXCEEDED'));

      expect(
        () => datasource.signInWithEmail(
          email: 'karim@rythmify.com',
          password: 'Karim123!',
        ),
        throwsA(
          predicate<Exception>(
            (e) => e.toString().contains('RATE_LIMIT_EXCEEDED'),
          ),
        ),
      );
    });

    test('should throw generic exception for unknown error code', () async {
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenThrow(makeDioError('UNKNOWN_CODE', message: 'Something broke'));

      expect(
        () => datasource.signInWithEmail(
          email: 'karim@rythmify.com',
          password: 'Karim123!',
        ),
        throwsA(
          predicate<Exception>((e) => e.toString().contains('Something broke')),
        ),
      );
    });
  });

  group('AuthRemoteDatasourceImpl.signUpWithEmail', () {
    test('should return UserModel with null token on success', () async {
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => registerSuccessResponse());

      final result = await datasource.signUpWithEmail(
        email: 'karim@rythmify.com',
        password: 'Karim123!',
        displayName: 'KarimWI',
        gender: 'male',
        dateOfBirth: '2000-01-01',
      );

      expect(result.token, isNull);
      expect(result.isEmailVerified, false);
      expect(result.id, 'user-001');
    });

    test(
      'should send sign-up payload without captcha_token when not implemented',
      () async {
        when(
          () => mockDio.post(any(), data: any(named: 'data')),
        ).thenAnswer((_) async => registerSuccessResponse());

        await datasource.signUpWithEmail(
          email: 'karim@rythmify.com',
          password: 'Karim123!',
          displayName: 'KarimWI',
          gender: 'male',
          dateOfBirth: '2000-01-01',
        );

        final captured =
            verify(
                  () => mockDio.post(any(), data: captureAny(named: 'data')),
                ).captured.first
                as Map<String, dynamic>;

        expect(captured.containsKey('captcha_token'), false);
      },
    );

    test('should parse user_id (not id) from response', () async {
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => registerSuccessResponse());

      final result = await datasource.signUpWithEmail(
        email: 'karim@rythmify.com',
        password: 'Karim123!',
        displayName: 'KarimWI',
        gender: 'male',
        dateOfBirth: '2000-01-01',
      );

      // user_id from response becomes the entity id
      expect(result.id, 'user-001');
    });

    test('should throw AUTH_EMAIL_ALREADY_EXISTS on that code', () async {
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenThrow(makeDioError('AUTH_EMAIL_ALREADY_EXISTS'));

      expect(
        () => datasource.signUpWithEmail(
          email: 'karim@rythmify.com',
          password: 'Karim123!',
          displayName: 'KarimWI',
          gender: 'male',
          dateOfBirth: '2000-01-01',
        ),
        throwsA(
          predicate<Exception>(
            (e) => e.toString().contains('AUTH_EMAIL_ALREADY_EXISTS'),
          ),
        ),
      );
    });

    test('should throw VALIDATION_FAILED with server message', () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
        makeDioError('VALIDATION_FAILED', message: 'date_of_birth is required'),
      );

      expect(
        () => datasource.signUpWithEmail(
          email: 'karim@rythmify.com',
          password: 'Karim123!',
          displayName: 'KarimWI',
          gender: 'male',
          dateOfBirth: '',
        ),
        throwsA(
          predicate<Exception>(
            (e) => e.toString().contains('date_of_birth is required'),
          ),
        ),
      );
    });
  });

  group('AuthRemoteDatasourceImpl.signOut', () {
    test('should call /auth/logout and clear token', () async {
      when(() => mockDio.post(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/auth/logout'),
          statusCode: 200,
        ),
      );
      when(() => mockApiClient.clearToken()).thenAnswer((_) async {});

      await datasource.signOut();

      verify(() => mockDio.post('/auth/logout')).called(1);
      verify(() => mockApiClient.clearToken()).called(1);
    });

    test('should throw on DioException', () async {
      when(
        () => mockDio.post(any()),
      ).thenThrow(makeDioError('UNKNOWN', message: 'Logout failed'));

      expect(() => datasource.signOut(), throwsA(isA<Exception>()));
    });
  });

  group('AuthRemoteDatasourceImpl.sendVerificationEmail', () {
    test('should call /auth/resend-verification', () async {
      when(() => mockDio.post(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/auth/resend-verification'),
          statusCode: 200,
        ),
      );

      await datasource.sendVerificationEmail();

      verify(() => mockDio.post('/auth/resend-verification')).called(1);
    });
  });

  group('AuthRemoteDatasourceImpl.sendPasswordReset', () {
    test('should call /auth/forgot-password with email in body', () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/auth/forgot-password'),
          statusCode: 200,
        ),
      );

      await datasource.sendPasswordReset(email: 'karim@rythmify.com');

      verify(
        () => mockDio.post(
          '/auth/forgot-password',
          data: {'email': 'karim@rythmify.com'},
        ),
      ).called(1);
    });

    test(
      'should throw AUTH_INVALID_CREDENTIALS when email not registered',
      () async {
        when(
          () => mockDio.post(any(), data: any(named: 'data')),
        ).thenThrow(makeDioError('AUTH_INVALID_CREDENTIALS'));

        expect(
          () => datasource.sendPasswordReset(email: 'ghost@test.com'),
          throwsA(
            predicate<Exception>(
              (e) => e.toString().contains('AUTH_INVALID_CREDENTIALS'),
            ),
          ),
        );
      },
    );
  });

  group('AuthRemoteDatasourceImpl._handleDioError — all codes', () {
    final codes = [
      'AUTH_INVALID_CREDENTIALS',
      'AUTH_EMAIL_NOT_VERIFIED',
      'AUTH_EMAIL_ALREADY_EXISTS',
      'AUTH_ACCOUNT_SUSPENDED',
      'AUTH_REFRESH_TOKEN_INVALID',
      'RATE_LIMIT_EXCEEDED',
    ];

    for (final code in codes) {
      test('should throw Exception containing $code', () async {
        when(
          () => mockDio.post(any(), data: any(named: 'data')),
        ).thenThrow(makeDioError(code));

        expect(
          () => datasource.signInWithEmail(
            email: 'test@test.com',
            password: 'pass',
          ),
          throwsA(predicate<Exception>((e) => e.toString().contains(code))),
        );
      });
    }

    test('should use server message for VALIDATION_FAILED', () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
        makeDioError('VALIDATION_FAILED', message: 'Server says invalid'),
      );

      expect(
        () => datasource.signInWithEmail(
          email: 'test@test.com',
          password: 'pass',
        ),
        throwsA(
          predicate<Exception>(
            (e) => e.toString().contains('Server says invalid'),
          ),
        ),
      );
    });
  });

  // =========================================================================
  // AuthMockDatasource tests (included here as it is also a data-layer file)
  // =========================================================================

  group('AuthMockDatasource', () {
    late AuthMockDatasource mockDs;

    setUp(() => mockDs = AuthMockDatasource());

    group('signInWithEmail', () {
      test('should return UserModel for valid karim credentials', () async {
        final result = await mockDs.signInWithEmail(
          email: 'karim@rythmify.com',
          password: 'Karim123!',
        );
        expect(result.id, 'user-001');
        expect(result.token, contains('user-001'));
      });

      test('should return UserModel for valid bassel credentials', () async {
        final result = await mockDs.signInWithEmail(
          email: 'bassel@rythmify.com',
          password: 'Biso1234',
        );
        expect(result.id, 'user-002');
      });

      test('should return UserModel for valid rana credentials', () async {
        final result = await mockDs.signInWithEmail(
          email: 'rana@rythmify.com',
          password: 'Rana1234!',
        );
        expect(result.id, 'user-004');
      });

      test('should throw AUTH_INVALID_CREDENTIALS for unknown email', () async {
        expect(
          () => mockDs.signInWithEmail(
            email: 'nobody@test.com',
            password: 'Pass123!',
          ),
          throwsA(
            predicate<Exception>(
              (e) => e.toString().contains('AUTH_INVALID_CREDENTIALS'),
            ),
          ),
        );
      });

      test(
        'should throw AUTH_INVALID_CREDENTIALS for wrong password',
        () async {
          expect(
            () => mockDs.signInWithEmail(
              email: 'karim@rythmify.com',
              password: 'WrongPass!',
            ),
            throwsA(
              predicate<Exception>(
                (e) => e.toString().contains('AUTH_INVALID_CREDENTIALS'),
              ),
            ),
          );
        },
      );

      test('should match email case-insensitively', () async {
        final result = await mockDs.signInWithEmail(
          email: 'KARIM@RYTHMIFY.COM',
          password: 'Karim123!',
        );
        expect(result.id, 'user-001');
      });

      test('should match email after trimming whitespace', () async {
        final result = await mockDs.signInWithEmail(
          email: '  karim@rythmify.com  ',
          password: 'Karim123!',
        );
        expect(result.id, 'user-001');
      });
    });

    group('signUpWithEmail', () {
      test('should create new user and return UserModel', () async {
        final result = await mockDs.signUpWithEmail(
          email: 'newuser@test.com',
          password: 'NewPass123!',
          displayName: 'New User',
          gender: 'female',
          dateOfBirth: '2000-06-15',
        );

        expect(result.email, 'newuser@test.com');
        expect(result.displayName, 'New User');
        expect(result.isEmailVerified, true);
        expect(result.token, isNotNull);
      });

      test('should generate id starting with user-', () async {
        final result = await mockDs.signUpWithEmail(
          email: 'another@test.com',
          password: 'Pass123!',
          displayName: 'Another',
          gender: 'male',
          dateOfBirth: '1999-01-01',
        );

        expect(result.id, startsWith('user-'));
      });

      test(
        'should throw AUTH_EMAIL_ALREADY_EXISTS for duplicate email',
        () async {
          expect(
            () => mockDs.signUpWithEmail(
              email: 'karim@rythmify.com',
              password: 'Karim123!',
              displayName: 'Dup',
              gender: 'male',
              dateOfBirth: '2000-01-01',
            ),
            throwsA(
              predicate<Exception>(
                (e) => e.toString().contains('AUTH_EMAIL_ALREADY_EXISTS'),
              ),
            ),
          );
        },
      );

      test('should allow new user to sign in after registration', () async {
        await mockDs.signUpWithEmail(
          email: 'brand@new.com',
          password: 'BrandNew123!',
          displayName: 'Brand New',
          gender: 'male',
          dateOfBirth: '2001-01-01',
        );

        final signIn = await mockDs.signInWithEmail(
          email: 'brand@new.com',
          password: 'BrandNew123!',
        );

        expect(signIn.displayName, 'Brand New');
      });
    });

    group('signInWithGoogle', () {
      test('should return hardcoded user-001 UserModel', () async {
        final result = await mockDs.signInWithGoogle();
        expect(result.id, 'user-001');
        expect(result.token, 'mock-google-token-xyz');
      });
    });

    group('signInWithApple', () {
      test('should return hardcoded user-001 UserModel', () async {
        final result = await mockDs.signInWithApple();
        expect(result.id, 'user-001');
        expect(result.token, 'mock-apple-token-xyz');
      });
    });

    group('signOut', () {
      test('should complete without throwing', () async {
        await expectLater(mockDs.signOut(), completes);
      });
    });

    group('sendVerificationEmail', () {
      test('should complete without throwing', () async {
        await expectLater(mockDs.sendVerificationEmail(), completes);
      });
    });

    group('sendPasswordReset', () {
      test('should complete for registered email', () async {
        await expectLater(
          mockDs.sendPasswordReset(email: 'karim@rythmify.com'),
          completes,
        );
      });

      test(
        'should throw AUTH_INVALID_CREDENTIALS for unregistered email',
        () async {
          expect(
            () => mockDs.sendPasswordReset(email: 'ghost@test.com'),
            throwsA(
              predicate<Exception>(
                (e) => e.toString().contains('AUTH_INVALID_CREDENTIALS'),
              ),
            ),
          );
        },
      );

      test('should complete for email matching case-insensitively', () async {
        await expectLater(
          mockDs.sendPasswordReset(email: 'KARIM@RYTHMIFY.COM'),
          completes,
        );
      });
    });
  });
}
