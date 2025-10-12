import 'package:dio/dio.dart';

import '../../domain/entities/trade_entities.dart';
import '../../domain/repositories/trade_repository.dart';
import '../../domain/usecases/trade_usecases.dart';
import '../datasources/trade_datasource.dart';
import '../mappers/trade_mappers.dart';

class TradeRepositoryImpl implements TradeRepository {
  final TradeDataSource _dataSource;
  final TradeMappers _mappers;
  
  const TradeRepositoryImpl({
    required TradeDataSource dataSource,
    required TradeMappers mappers,
  }) : _dataSource = dataSource, _mappers = mappers;
  
  @override
  Future<List<TradePortfolioSummary>> getPortfoliosByOwner(String ownerId) async {
    try {
      final dtos = await _dataSource.getPortfoliosByOwner(ownerId);
      return _mappers.portfolioListFromDtos(dtos);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<TradePortfolioSummary> getPortfolioSummary(String portfolioId) async {
    try {
      final dto = await _dataSource.getPortfolioSummary(portfolioId);
      return _mappers.portfolioSummaryFromDto(dto);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<List<TradeHolding>> getTradeHoldings({
    required String portfolioId,
    int page = 1,
    int limit = 50,
    String? searchQuery,
    TradeStatus? statusFilter,
  }) async {
    try {
      final dtos = await _dataSource.getTradeHoldings(
        portfolioId: portfolioId,
        page: page,
        limit: limit,
        searchQuery: searchQuery,
        statusFilter: statusFilter?.name,
      );
      return _mappers.tradeHoldingsFromDtos(dtos);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<List<TradeHolding>> getTradeDetailsByIds(List<String> tradeIds) async {
    try {
      final dtos = await _dataSource.getTradeDetailsByIds(tradeIds);
      return _mappers.tradeHoldingsFromDtos(dtos);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          return NetworkException('Connection timeout');
        case DioExceptionType.badResponse:
          return ServerException('Server error: ${error.response?.statusCode}');
        default:
          return NetworkException('Network error');
      }
    }
    return UnknownException('Unexpected error: $error');
  }
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class UnknownException implements Exception {
  final String message;
  UnknownException(this.message);
}
    }
  }

  @override
  Future<List<TradeHolding>> searchTrades({
    required String portfolioId,
    required String query,
    int limit = 20,
  }) async {
    try {
      final response = await _dataSource.getTradeHoldings(
        portfolioId: portfolioId,
        limit: limit,
        searchQuery: query,
      );
      return _mappers.tradeHoldingsFromDto(response.trades);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> clearCache() async {
    // Implement cache clearing logic
    // Could use Hive, SharedPreferences, or in-memory cache
  }

  @override
  Future<void> refreshPortfolioData(String portfolioId) async {
    // Implement data refresh logic
    // Force fetch from remote and update cache
  }

  Exception _handleError(error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          return NetworkException('Connection timeout');
        case DioExceptionType.badResponse:
          return ServerException('Server error: ${error.response?.statusCode}');
        default:
          return NetworkException('Network error');
      }
    }
    return UnknownException('Unexpected error: $error');
  }
}

// Custom exceptions
class NetworkException implements Exception {
  NetworkException(this.message);
  final String message;
}

class ServerException implements Exception {
  ServerException(this.message);
  final String message;
}

class UnknownException implements Exception {
  UnknownException(this.message);
  final String message;
}
