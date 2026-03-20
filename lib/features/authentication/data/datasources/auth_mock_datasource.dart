import '../models/user_model.dart';
import 'auth_remote_datasource.dart';

class AuthMockDatasource implements AuthRemoteDatasource {
  static const _mockUsers = [
    {
      'email': 'karim@rythmify.com',
      'password': 'karim123',
      'id': 'user-001',
      'display_name': 'KarimWI',
    },
    {
      'email': 'bassel@rythmify.com',
      'password': 'bassel123',
      'id': 'user-002',
      'display_name': 'Bassel Alaa',
    },
    {
      'email': 'mohammed@rythmify.com',
      'password': 'mohammed123',
      'id': 'user-003',
      'display_name': 'Mohammed Al Abasy',
    },
    {
      'email': 'rana@rythmify.com',
      'password': 'rana123',
      'id': 'user-004',
      'display_name': 'Rana Elgharabawy',
    },
    {
      'email': 'h@rythmify.com',
      'password': 'h123456',
      'id': 'user-005',
      'display_name': '~H',
    },
    {
      'email': 'sohaila@rythmify.com',
      'password': 'sohaila123',
      'id': 'user-006',
      'display_name': '~sohaila',
    },
  ];

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final user = _mockUsers.firstWhere(
      (u) => u['email'] == email.trim().toLowerCase(),
      orElse: () => throw Exception('AUTH_INVALID_CREDENTIALS'),
    );

    if (user['password'] != password) {
      throw Exception('AUTH_INVALID_CREDENTIALS');
    }

    return UserModel(
      id: user['id']!,
      email: user['email']!,
      displayName: user['display_name']!,
      isEmailVerified: true,
      token: 'mock-jwt-token-${user['id']}',
    );
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String gender,
    required String dateOfBirth,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final exists = _mockUsers.any(
      (u) => u['email'] == email.trim().toLowerCase(),
    );

    if (exists) {
      throw Exception('AUTH_EMAIL_ALREADY_EXISTS');
    }

    return UserModel(
      id: 'user-001',
      email: email,
      displayName: displayName,
      isEmailVerified: false,
      token: 'mock-jwt-token-new',
    );
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));
    return const UserModel(
      id: 'user-001',
      email: 'karim@gmail.com',
      displayName: 'KarimWI',
      isEmailVerified: true,
      token: 'mock-google-token-xyz',
    );
  }

  @override
  Future<UserModel> signInWithApple() async {
    await Future.delayed(const Duration(seconds: 1));
    return const UserModel(
      id: 'user-001',
      email: 'karim@icloud.com',
      displayName: 'KarimWI',
      isEmailVerified: true,
      token: 'mock-apple-token-xyz',
    );
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> sendVerificationEmail() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final exists = _mockUsers.any(
      (u) => u['email'] == email.trim().toLowerCase(),
    );
    if (!exists) {
      throw Exception('AUTH_INVALID_CREDENTIALS');
    }
  }
}