abstract class Failure {
  final String message;
  const Failure(this.message);
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure() : super('Invalid email or password.');
}

class EmailNotVerifiedFailure extends Failure {
  const EmailNotVerifiedFailure() : super('Please verify your email before signing in.');
}

class EmailAlreadyInUseFailure extends Failure {
  const EmailAlreadyInUseFailure() : super('An account with this email already exists.');
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('No internet connection. Please try again.');
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

class UnknownFailure extends Failure {
  const UnknownFailure() : super('An unexpected error occurred.');
}

class AccountSuspendedFailure extends Failure {
  const AccountSuspendedFailure() : super('Your account has been suspended.');
}

class RefreshTokenInvalidFailure extends Failure {
  const RefreshTokenInvalidFailure() : super('Your session has expired. Please sign in again.');
}

class TooManyRequestsFailure extends Failure {
  const TooManyRequestsFailure() : super('Too many attempts. Please try again later.');
}