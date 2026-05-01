import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_mock_datasource.dart';
import '../../data/datasources/auth_remote_datasource_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/user_entity.dart';
import '../../data/datasources/discord_auth_data.dart';
import '../../domain/usecases/sign_in_with_email_usecase.dart';
import '../../domain/usecases/sign_up_with_email_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_up_with_google_usecase.dart';
import '../../domain/usecases/login_with_github_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/send_verification_email_usecase.dart';
import '../../domain/usecases/send_password_reset_usecase.dart';
import '../../../../core/network/api_client.dart';
import '../../../../features/profile/data/datasources/profile_mock_datasource.dart';
import 'auth_state.dart';

const bool useMockData = false;

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

class AuthNotifier extends Notifier<AuthState> {
  late final SignInWithEmailUseCase _signInWithEmail;
  late final SignUpWithEmailUseCase _signUpWithEmail;
  late final SignInWithGoogleUseCase _signInWithGoogle;
  late final SignUpWithGoogleUseCase _signUpWithGoogle;
  late final LoginWithGitHubUseCase _loginWithGitHub;
  late final SignOutUseCase _signOut;
  late final SendVerificationEmailUseCase _sendVerificationEmail;
  late final SendPasswordResetUseCase _sendPasswordReset;

  @override
  AuthState build() {
    final datasource = useMockData
        ? AuthMockDatasource()
        : AuthRemoteDatasourceImpl(client: apiClient);

    final repository = AuthRepositoryImpl(remoteDatasource: datasource);

    _signInWithEmail = SignInWithEmailUseCase(repository);
    _signUpWithEmail = SignUpWithEmailUseCase(repository);
    _signInWithGoogle = SignInWithGoogleUseCase(repository);
    _signUpWithGoogle = SignUpWithGoogleUseCase(repository);
    _loginWithGitHub = LoginWithGitHubUseCase(repository);
    _signOut = SignOutUseCase(repository);
    _sendVerificationEmail = SendVerificationEmailUseCase(repository);
    _sendPasswordReset = SendPasswordResetUseCase(repository);

    apiClient.onSessionExpired = () {
      state = const AuthUnauthenticated();
    };

    Future.microtask(() => checkAuthStatus());

    return const AuthChecking();
  }

  // ── Internal helpers ──────────────────────────────────────────────────────

  /// Fetches the full profile from `/users/me` and merges it with
  /// the token and ID from the basic auth login response.
  ///
  /// Passes the access token explicitly in the request header instead of
  /// relying on the [ApiClient] interceptor reading it from storage.
  /// This avoids a race condition where [FlutterSecureStorage.write] has not
  /// yet completed by the time the interceptor calls [ApiClient.getToken].
  Future<void> _fetchAndEmitFullProfile(UserEntity basicUser) async {
    if (useMockData) {
      ProfileMockDatasource.setCurrentUser(basicUser.id);
      state = AuthAuthenticated(basicUser);
      return;
    }

    try {
      final response = await apiClient.dio.get(
        '/users/me',
        options: Options(
          headers: {'Authorization': 'Bearer ${basicUser.token}'},
        ),
      );
      final data = response.data['data'];

      final fullUser = UserModel.fromJson({
        ...data,
        'id': basicUser.id,
        'is_email_verified':
            data['is_verified'] ??
            data['is_email_verified'] ??
            basicUser.isEmailVerified,
        'avatar_url': data['profile_picture'] ?? data['avatar_url'],
        'token': basicUser.token,
      });

      state = AuthAuthenticated(fullUser);
    } catch (e) {
      // Profile fetch failed — fall back to basic login user so the
      // session is not lost over a transient network error.
      state = AuthAuthenticated(basicUser);
    }
  }

  /// Builds a [UserEntity] from the GitHub OAuth response data map,
  /// then fetches the full profile via `/users/me`.
  ///
  /// Mirrors the pattern used by Google sign-in: parse a minimal user
  /// from the auth response, then enrich it with the full profile.
  Future<void> _handleGitHubAuthData(GitHubAuthData authData) async {
    final basicUser = UserModel(
      id: '',
      email: '',
      displayName: '',
      isEmailVerified: true,
      token: authData.accessToken,
    );
    await _fetchAndEmitFullProfile(basicUser);
  }

  // ── Public methods ────────────────────────────────────────────────────────

  Future<void> checkAuthStatus() async {
    if (useMockData) {
      state = const AuthUnauthenticated();
      return;
    }

    try {
      var token = await apiClient.getToken();
      final refreshToken = await apiClient.getRefreshToken();

      if ((token == null || token.isEmpty) &&
          refreshToken != null &&
          refreshToken.isNotEmpty) {
        token = await apiClient.refreshAccessToken();
      }

      if (token == null || token.isEmpty) {
        state = const AuthUnauthenticated();
        return;
      }

      final response = await apiClient.dio.get('/users/me');
      // Re-read in case Dio interceptor silently refreshed the token above.
      final freshToken = await apiClient.getToken() ?? token;
      final data = response.data['data'];

      final user = UserModel.fromJson({
        ...data,
        'id': data['id']?.toString() ?? data['user_id']?.toString(),
        'is_email_verified':
            data['is_verified'] ?? data['is_email_verified'] ?? true,
        'avatar_url': data['profile_picture'] ?? data['avatar_url'],
        'token': freshToken,
      });

      state = AuthAuthenticated(user);
    } catch (e) {
      if (_isInvalidSessionError(e)) {
        await apiClient.clearTokens();
        state = const AuthUnauthenticated();
        return;
      }

      final token = await apiClient.getToken();
      if (token != null) {
        state = AuthAuthenticated(
          UserModel(
            id: 'cached-session',
            email: '',
            displayName: 'Rythmify User',
            isEmailVerified: true,
            token: token,
          ),
        );
      } else {
        state = const AuthUnauthenticated();
      }
    }
  }

  bool _isInvalidSessionError(Object error) {
    if (error is DioException) {
      return error.response?.statusCode == 401;
    }
    return false;
  }

  // ── Email ─────────────────────────────────────────────────────────────────

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();
    final result = await _signInWithEmail(email: email, password: password);
    result.fold(
      (failure) => state = AuthError(failure.message),
      (basicUser) async => _fetchAndEmitFullProfile(basicUser),
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
      (basicUser) => state = AuthEmailVerificationRequired(basicUser.email),
    );
  }

  // ── Google ────────────────────────────────────────────────────────────────

  Future<void> signInWithGoogleAccount() async {
    state = const AuthLoading();
    final result = await _signInWithGoogle();
    result.fold(
      (failure) {
        state = AuthError(failure.message);
      },
      (basicUser) async {
        await _fetchAndEmitFullProfile(basicUser);
      },
    );
  }

  /// Completes registration for a user who signed in via Google OAuth.
  ///
  /// Called after the user fills in the registration form (gender,
  /// date of birth) on the [RegisterPage].
  ///
  /// [idToken] — the Google ID token from the sign-in flow.
  /// [gender] — lowercase gender string (e.g. `'male'`).
  /// [dateOfBirth] — date in `YYYY-MM-DD` format.
  Future<void> signUpWithGoogle({
    required String idToken,
    required String gender,
    required String dateOfBirth,
  }) async {
    state = const AuthLoading();
    final result = await _signUpWithGoogle(
      idToken: idToken,
      gender: gender,
      dateOfBirth: dateOfBirth,
    );
    result.fold(
      (failure) => state = AuthError(failure.message),
      (basicUser) async => _fetchAndEmitFullProfile(basicUser),
    );
  }

  // ── GitHub ────────────────────────────────────────────────────────────────

  /// Signs in an existing user via GitHub OAuth.
  ///
  /// Opens the GitHub consent screen in the system browser, waits for the
  /// deep-link callback, and exchanges the code with the backend.
  ///
  /// On success, fetches the full profile and emits [AuthAuthenticated].
  /// On failure, emits [AuthError] with the failure message.
  Future<void> signInWithGitHub() async {
    state = const AuthLoading();
    final result = await _loginWithGitHub();
    result.fold((failure) => state = AuthError(failure.message), (
      authData,
    ) async {
      if (authData.isNewUser) {
        // New account created — send to onboarding/register flow
        state = const AuthEmailVerificationRequired('');
      } else {
        await _handleGitHubAuthData(authData);
      }
    });
  }

  /// Signs up a new user via GitHub OAuth.
  ///
  /// Identical flow to [signInWithGitHub] — the backend creates a new
  /// account automatically if one does not exist for the GitHub identity.
  /// The [GitHubAuthData.isNewUser] flag indicates which case occurred.
  Future<void> signUpWithGitHub() async => signInWithGitHub();

  // ── Sign out ──────────────────────────────────────────────────────────────

  Future<void> signOutUser() async {
    state = const AuthLoading();
    final result = await _signOut();
    result.fold((failure) => state = AuthError(failure.message), (_) async {
      await apiClient.clearTokens();
      state = const AuthUnauthenticated();
    });
  }

  Future<void> sendEmailVerification() async {
    final result = await _sendVerificationEmail();
    result.fold((failure) => state = AuthError(failure.message), (_) {});
  }

  Future<void> resetPassword({required String email}) async {
    state = const AuthLoading();
    final result = await _sendPasswordReset(email: email);
    result.fold(
      (failure) => state = AuthError(failure.message),
      (_) => state = const AuthUnauthenticated(),
    );
  }

  void setUnauthenticated() {
    state = const AuthUnauthenticated();
  }
}
