import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_mock_datasource.dart';
import '../../data/datasources/auth_remote_datasource_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/models/user_model.dart';
import '../../domain/usecases/sign_in_with_email_usecase.dart';
import '../../domain/usecases/sign_up_with_email_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_in_with_apple_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/send_verification_email_usecase.dart';
import '../../domain/usecases/send_password_reset_usecase.dart';
import '../../../../core/network/api_client.dart';
import 'auth_state.dart';


const bool useMockData = false;

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

class AuthNotifier extends Notifier<AuthState> {
  late final SignInWithEmailUseCase _signInWithEmail;
  late final SignUpWithEmailUseCase _signUpWithEmail;
  late final SignInWithGoogleUseCase _signInWithGoogle;
  late final SignInWithAppleUseCase _signInWithApple;
  late final SignOutUseCase _signOut;
  late final SendVerificationEmailUseCase _sendVerificationEmail;
  late final SendPasswordResetUseCase _sendPasswordReset;

  @override
  AuthState build() {
    // ── Datasource selected by useMockData flag above ─────
    final datasource = useMockData
        ? AuthMockDatasource()
        : AuthRemoteDatasourceImpl(client: apiClient);

    final repository = AuthRepositoryImpl(remoteDatasource: datasource);

    _signInWithEmail = SignInWithEmailUseCase(repository);
    _signUpWithEmail = SignUpWithEmailUseCase(repository);
    _signInWithGoogle = SignInWithGoogleUseCase(repository);
    _signInWithApple = SignInWithAppleUseCase(repository);
    _signOut = SignOutUseCase(repository);
    _sendVerificationEmail = SendVerificationEmailUseCase(repository);
    _sendPasswordReset = SendPasswordResetUseCase(repository);

    // ── Check existing auth on app start ──────────────────
    Future.microtask(() => checkAuthStatus());

    return const AuthLoading();
  }

  // ── Check if user is already logged in ───────────────────
  Future<void> checkAuthStatus() async {
    print('CHECK AUTH STATUS STARTED');

    if (useMockData) {
      print('MOCK MODE — setting unauthenticated');
      state = const AuthUnauthenticated();
      return;
    }

    try {
      // ── Wrap getToken in try-catch to handle corrupted storage ──
      final token = await apiClient.getToken();
      print('TOKEN FROM STORAGE: $token');

      if (token == null) {
        print('NO TOKEN — setting unauthenticated');
        state = const AuthUnauthenticated();
        return;
      }

      // ── Token exists — verify with backend ────────────────
      print('TOKEN EXISTS — calling /users/me');
      final response = await apiClient.dio.get('/users/me');
      print('USERS/ME RESPONSE: ${response.data}');

      final data = response.data['data'];
      final user = UserModel.fromJson({
        'id': data['id'],
        'email': data['email'],
        'display_name': data['display_name'],
        'is_email_verified': data['is_verified'] ?? true,
        'token': token,
      });

      print('SETTING AUTH AUTHENTICATED: ${user.email}');
      state = AuthAuthenticated(user);
    } catch (e) {
      // ── Handles BadPaddingException and any other errors ──
      print('ERROR IN CHECK AUTH: $e');
      await apiClient.clearToken();
      state = const AuthUnauthenticated();
    }
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();
    final result = await _signInWithEmail(email: email, password: password);
    result.fold(
      (failure) => state = AuthError(failure.message),
      (user) => state = AuthAuthenticated(user),
    );
  }

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    required String gender,
    required String dateOfBirth,
  }) async {
    state = const AuthLoading();
    final result = await _signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
      gender: gender,
      dateOfBirth: dateOfBirth,
    );
    result.fold(
      (failure) => state = AuthError(failure.message),
      (user) => state = AuthAuthenticated(user),
    );
  }

  Future<void> signInWithGoogleAccount() async {
    state = const AuthLoading();
    final result = await _signInWithGoogle();
    result.fold(
      (failure) => state = AuthError(failure.message),
      (user) => state = AuthAuthenticated(user),
    );
  }

  Future<void> signInWithAppleAccount() async {
    state = const AuthLoading();
    final result = await _signInWithApple();
    result.fold(
      (failure) => state = AuthError(failure.message),
      (user) => state = AuthAuthenticated(user),
    );
  }

  Future<void> signOutUser() async {
    state = const AuthLoading();
    final result = await _signOut();
    result.fold(
      (failure) => state = AuthError(failure.message),
      (_) async {
        await apiClient.clearToken();
        state = const AuthUnauthenticated();
      },
    );
  }

  Future<void> sendEmailVerification() async {
    final result = await _sendVerificationEmail();
    result.fold(
      (failure) => state = AuthError(failure.message),
      (_) {},
    );
  }

  Future<void> resetPassword({required String email}) async {
    state = const AuthLoading();
    final result = await _sendPasswordReset(email: email);
    result.fold(
      (failure) => state = AuthError(failure.message),
      (_) => state = const AuthUnauthenticated(),
    );
  }
}