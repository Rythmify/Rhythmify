import '../models/user_model.dart';
import 'auth_remote_datasource.dart';
import 'package:rythmify/features/profile/data/datasources/profile_mock_datasource.dart';

/// In-memory auth datasource used for development and deterministic tests.
class AuthMockDatasource implements AuthRemoteDatasource {
  static final List<Map<String, dynamic>> _mockUsers = [
    {
      'email': 'karim@rythmify.com',
      'password': 'Karim123!',
      'id': 'user-001',
      'display_name': 'KarimWI',
      'avatar_url': 'https://avatars.githubusercontent.com/u/1?v=4',
    },
    {
      'email': 'bassel@rythmify.com',
      'password': 'Biso1234',
      'id': 'user-002',
      'display_name': 'Biso The King',
      'avatar_url': 'https://avatars.githubusercontent.com/u/2?v=4',
    },
    {
      'email': 'rana@rythmify.com',
      'password': 'Rana1234!',
      'id': 'user-004',
      'display_name': 'Rana Elgharabawy',
      'avatar_url': 'https://avatars.githubusercontent.com/u/3?v=4',
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
      avatarUrl: user['avatar_url'],
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

    // ── Check if email already exists ─────────────────
    final exists = _mockUsers.any(
      (u) => u['email'] == email.trim().toLowerCase(),
    );
    if (exists) throw Exception('AUTH_EMAIL_ALREADY_EXISTS');

    // ── Generate new user ID ──────────────────────────
    final newId = 'user-${DateTime.now().millisecondsSinceEpoch}';

    // ── Add to mock users list ────────────────────────
    _mockUsers.add({
      'email': email.trim().toLowerCase(),
      'password': password,
      'id': newId,
      'display_name': displayName,
    });

    // ── Add to mock profiles ──────────────────────────
    ProfileMockDatasource.addDynamicProfile(
      id: newId,
      displayName: displayName,
      email: email,
      gender: gender,
      dateOfBirth: dateOfBirth,
    );

    return UserModel(
      id: newId,
      email: email,
      displayName: displayName,
      isEmailVerified: true,
      token: 'mock-jwt-token-$newId',
    );
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));
    final googleEmail = 'karim@rythmify.com';
    final exists = _mockUsers.any(
      (u) => u['email'] == googleEmail.trim().toLowerCase(),
    );
    if (exists) {
      throw Exception('EMAIL_ALREADY_EXISTS');
    }

    return const UserModel(
      id: 'user-001',
      email: 'karim@gmail.com',
      displayName: 'KarimWI',
      avatarUrl: 'https://avatars.githubusercontent.com/u/1?v=4',
      isEmailVerified: true,
      token: 'mock-google-token-xyz',
    );
  }

  @override
  Future<UserModel> signUpWithGoogle({
    required String idToken,
    required String gender,
    required String dateOfBirth,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    const newId = 'user-google-${1}';

    // Add to mock profiles
    ProfileMockDatasource.addDynamicProfile(
      id: newId,
      displayName: 'Google User',
      email: 'google-user@gmail.com',
      gender: gender,
      dateOfBirth: dateOfBirth,
    );

    return const UserModel(
      id: newId,
      email: 'google-user@gmail.com',
      displayName: 'Google User',
      avatarUrl: 'https://avatars.githubusercontent.com/u/1?v=4',
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
      avatarUrl: 'https://avatars.githubusercontent.com/u/1?v=4',
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
    if (!exists) throw Exception('AUTH_INVALID_CREDENTIALS');
  }

  @override
  Future<Map<String, dynamic>> loginWithGitHub() async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'id': 'user-001',
      'email': 'karim@github.com',
      'display_name': 'KarimWI',
      'avatar_url': 'https://avatars.githubusercontent.com/u/1?v=4',
      'token': 'mock-github-token-xyz',
    };
  }
}
