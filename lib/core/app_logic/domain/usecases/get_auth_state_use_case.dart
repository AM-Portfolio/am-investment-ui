import '../entities/auth_state.dart';
import '../repositories/auth_repository.dart';

/// Use case for getting authentication state
///
/// Handles the business logic for retrieving current authentication status
/// and listening to authentication state changes
class GetAuthStateUseCase {
  const GetAuthStateUseCase(this._authRepository);
  final AuthRepository _authRepository;

  /// Get current authentication state
  AuthState get currentState => _authRepository.currentState;

  /// Stream of authentication state changes
  Stream<AuthState> get authStateChanges => _authRepository.authStateChanges;

  /// Initialize the authentication system
  Future<void> initialize() async {
    await _authRepository.initialize();
  }
}
