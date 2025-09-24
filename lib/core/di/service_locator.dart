import 'package:get_it/get_it.dart';
import '../data/repositories/portfolio_repository_impl.dart';
import '../domain/repositories/portfolio_repository.dart';
import '../services/api/portfolio_client.dart';

/// Service locator for dependency injection
final getIt = GetIt.instance;

/// Setup all dependencies for the application
Future<void> setupServiceLocator() async {
    
  // Register API clients
  getIt.registerLazySingleton<PortfolioClient>(
    () => PortfolioClient(), // Replace with your actual implementation
  );

  // Register repositories
  getIt.registerLazySingleton<PortfolioRepository>(
    () => PortfolioRepositoryImpl(
      apiClient: getIt<PortfolioClient>(),
    ),
  );
}

/// Get instance of PortfolioRepository
PortfolioRepository get portfolioRepository => getIt<PortfolioRepository>();