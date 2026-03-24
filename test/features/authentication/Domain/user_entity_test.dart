import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/authentication/domain/entities/user_entity.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Test fixtures
  // ---------------------------------------------------------------------------

  const tUser = UserEntity(
    id: 'user-001',
    email: 'karim@rythmify.com',
    displayName: 'KarimWI',
    isEmailVerified: true,
    token: 'mock-jwt-token-user-001',
  );

  const tUserNoToken = UserEntity(
    id: 'user-002',
    email: 'bassel@rythmify.com',
    displayName: 'Bassel Alaa',
    isEmailVerified: false,
    token: null,
  );

  // ---------------------------------------------------------------------------
  // Construction
  // ---------------------------------------------------------------------------

  group('UserEntity — construction', () {
    test('should create a UserEntity with all fields set', () {
      expect(tUser.id, 'user-001');
      expect(tUser.email, 'karim@rythmify.com');
      expect(tUser.displayName, 'KarimWI');
      expect(tUser.isEmailVerified, true);
      expect(tUser.token, 'mock-jwt-token-user-001');
    });

    test('should allow token to be null', () {
      expect(tUserNoToken.token, isNull);
    });

    test('should allow isEmailVerified to be false', () {
      expect(tUserNoToken.isEmailVerified, false);
    });
  });

  // ---------------------------------------------------------------------------
  // Equality (Equatable)
  // ---------------------------------------------------------------------------

  group('UserEntity — equality', () {
    test('should return true when two instances have identical fields', () {
      const duplicate = UserEntity(
        id: 'user-001',
        email: 'karim@rythmify.com',
        displayName: 'KarimWI',
        isEmailVerified: true,
        token: 'mock-jwt-token-user-001',
      );
      expect(tUser, equals(duplicate));
    });

    test('should return false when ids differ', () {
      const different = UserEntity(
        id: 'user-999',
        email: 'karim@rythmify.com',
        displayName: 'KarimWI',
        isEmailVerified: true,
        token: 'mock-jwt-token-user-001',
      );
      expect(tUser, isNot(equals(different)));
    });

    test('should return false when emails differ', () {
      const different = UserEntity(
        id: 'user-001',
        email: 'other@rythmify.com',
        displayName: 'KarimWI',
        isEmailVerified: true,
        token: 'mock-jwt-token-user-001',
      );
      expect(tUser, isNot(equals(different)));
    });

    test('should return false when displayName differs', () {
      const different = UserEntity(
        id: 'user-001',
        email: 'karim@rythmify.com',
        displayName: 'OtherName',
        isEmailVerified: true,
        token: 'mock-jwt-token-user-001',
      );
      expect(tUser, isNot(equals(different)));
    });

    test('should return false when isEmailVerified differs', () {
      const different = UserEntity(
        id: 'user-001',
        email: 'karim@rythmify.com',
        displayName: 'KarimWI',
        isEmailVerified: false,
        token: 'mock-jwt-token-user-001',
      );
      expect(tUser, isNot(equals(different)));
    });

    test('should return false when token differs', () {
      const different = UserEntity(
        id: 'user-001',
        email: 'karim@rythmify.com',
        displayName: 'KarimWI',
        isEmailVerified: true,
        token: 'different-token',
      );
      expect(tUser, isNot(equals(different)));
    });

    test('should return false when one token is null and the other is not', () {
      expect(tUser, isNot(equals(tUserNoToken)));
    });

    test(
      'should return true for two null-token instances with same fields',
      () {
        const a = UserEntity(
          id: 'user-002',
          email: 'bassel@rythmify.com',
          displayName: 'Bassel Alaa',
          isEmailVerified: false,
          token: null,
        );
        expect(tUserNoToken, equals(a));
      },
    );
  });

  // ---------------------------------------------------------------------------
  // props
  // ---------------------------------------------------------------------------

  group('UserEntity — props', () {
    test('should expose all five fields in props', () {
      expect(tUser.props, [
        'user-001',
        'karim@rythmify.com',
        'KarimWI',
        true,
        'mock-jwt-token-user-001',
      ]);
    });

    test('should include null token in props', () {
      expect(tUserNoToken.props, contains(null));
    });
  });

  // ---------------------------------------------------------------------------
  // Edge cases
  // ---------------------------------------------------------------------------

  group('UserEntity — edge cases', () {
    test('should handle empty string id', () {
      const u = UserEntity(
        id: '',
        email: 'test@test.com',
        displayName: 'Test',
        isEmailVerified: false,
      );
      expect(u.id, '');
    });

    test('should handle empty string email', () {
      const u = UserEntity(
        id: 'user-001',
        email: '',
        displayName: 'Test',
        isEmailVerified: false,
      );
      expect(u.email, '');
    });

    test('should handle empty string displayName', () {
      const u = UserEntity(
        id: 'user-001',
        email: 'test@test.com',
        displayName: '',
        isEmailVerified: false,
      );
      expect(u.displayName, '');
    });
  });
}
