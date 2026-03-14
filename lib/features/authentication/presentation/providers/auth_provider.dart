import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/sign_in_with_email_usecase.dart';
import '../../domain/usecases/sign_up_with_email_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_in_with_apple_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/send_verification_email_usecase.dart';
import '../../domain/usecases/send_password_reset_usecase.dart';
import '../../data/datasources/auth_mock_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import 'auth_state.dart';

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
    final datasource = AuthMockDatasource();
    final repository = AuthRepositoryImpl(remoteDatasource: datasource);

    _signInWithEmail = SignInWithEmailUseCase(repository);
    _signUpWithEmail = SignUpWithEmailUseCase(repository);
    _signInWithGoogle = SignInWithGoogleUseCase(repository);
    _signInWithApple = SignInWithAppleUseCase(repository);
    _signOut = SignOutUseCase(repository);
    _sendVerificationEmail = SendVerificationEmailUseCase(repository);
    _sendPasswordReset = SendPasswordResetUseCase(repository);

    return const AuthInitial();
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
  }) async {
    state = const AuthLoading();
    final result = await _signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
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
      (_) => state = const AuthUnauthenticated(),
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