import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class SendVerificationEmailUseCase {
  final AuthRepository repository;

  SendVerificationEmailUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.sendVerificationEmail();
  }
}
