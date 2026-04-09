import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_mock_datasource.dart';
import '../../data/datasources/auth_remote_datasource_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/sign_in_with_email_usecase.dart';
import '../../domain/usecases/sign_up_with_email_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_in_with_apple_usecase.dart';
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
  late final SignInWithAppleUseCase _signInWithApple;
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
    _signInWithApple = SignInWithAppleUseCase(repository);
    _signOut = SignOutUseCase(repository);
    _sendVerificationEmail = SendVerificationEmailUseCase(repository);
    _sendPasswordReset = SendPasswordResetUseCase(repository);

    Future.microtask(() => checkAuthStatus());

    return const AuthLoading();
  }

  /// Fetches the full profile from `/users/me` and merges it with 
  /// the token and ID from the basic auth login.
  Future<void> _fetchAndEmitFullProfile(UserEntity basicUser) async {
    if (useMockData) {
      ProfileMockDatasource.setCurrentUser(basicUser.id);
      state = AuthAuthenticated(basicUser);
      return;
    }

    try {
      final response = await apiClient.dio.get('/users/me');
      final data = response.data['data'];

      final fullUser = UserModel.fromJson({
        ...data,
        'id': basicUser.id, 
        'is_email_verified': data['is_verified'] ?? data['is_email_verified'] ?? basicUser.isEmailVerified,
        // THE FIX: Grabbing profile_picture from the backend
        'avatar_url': data['profile_picture'] ?? data['avatar_url'], 
        'token': basicUser.token, // Keep the JWT token from the login response
      });

      state = AuthAuthenticated(fullUser);
    } catch (e) {
      // If fetching the profile fails, fallback to the basic user so they aren't blocked from using the app
      state = AuthAuthenticated(basicUser);
    }
  }

  Future<void> checkAuthStatus() async {
    if (useMockData) {
      state = const AuthUnauthenticated();
      return;
    }

    try {
      final token = await apiClient.getToken();

      if (token == null) {
        state = const AuthUnauthenticated();
        return;
      }

      final response = await apiClient.dio.get('/users/me');
      final data = response.data['data'];
      
      final user = UserModel.fromJson({
        ...data,
        'id': data['id']?.toString() ?? data['user_id']?.toString(),
        'is_email_verified': data['is_verified'] ?? data['is_email_verified'] ?? true,
        // THE FIX APPLIED HERE TOO
        'avatar_url': data['profile_picture'] ?? data['avatar_url'],
        'token': token,
      });

      state = AuthAuthenticated(user);
    } catch (e) {
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
    
    // Notice the 'async' added to this callback so we can await the profile
    result.fold(
      (failure) => state = AuthError(failure.message), 
      (basicUser) async {
        await _fetchAndEmitFullProfile(basicUser);
      }
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
      (basicUser) async {
        await _fetchAndEmitFullProfile(basicUser);
      }
    );
  }

  Future<void> signInWithGoogleAccount() async {
    state = const AuthLoading();
    final result = await _signInWithGoogle();
    
    result.fold(
      (failure) => state = AuthError(failure.message), 
      (basicUser) async {
        await _fetchAndEmitFullProfile(basicUser);
      }
    );
  }

  Future<void> signInWithAppleAccount() async {
    state = const AuthLoading();
    final result = await _signInWithApple();
    
    result.fold(
      (failure) => state = AuthError(failure.message), 
      (basicUser) async {
        await _fetchAndEmitFullProfile(basicUser);
      }
    );
  }

  Future<void> signOutUser() async {
    state = const AuthLoading();
    final result = await _signOut();
    result.fold((failure) => state = AuthError(failure.message), (_) async {
      await apiClient.clearToken();
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
}