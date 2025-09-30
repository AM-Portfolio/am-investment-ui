import 'package:todo_app/core/app_logic/domain/entities/user.dart';

import '../repositories/auth_repository.dart';

/// Use case for managing test users
/// 
/// Handles the business logic for retrieving test user data
/// used for development and demo purposes
class GetTestUsersUseCase {
  final AuthRepository _authRepository;

  const GetTestUsersUseCase(this._authRepository);

  /// Get list of available test users
  /// 
  /// Returns list of test users for development/demo purposes
  Future<List<User>> call() async {
    return await _authRepository.getTestUsers();
  }
}