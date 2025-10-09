import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Use case for logout
class LogoutUseCase {
  LogoutUseCase(this.repository);
  final AuthRepository repository;

  Future<Either<Failure, void>> call() async => repository.logout();
}
