import 'dart:async';
import '../../domain/entities/portfolio_holding.dart';
import '../../domain/entities/portfolio_summary.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../datasources/portfolio_remote_data_source.dart';
import '../dtos/portfolio_dto.dart';
import '../../../../../core/utils/logger.dart';

/// Implementation of PortfolioRepository
class PortfolioRepositoryImpl implements PortfolioRepository {
  final PortfolioRemoteDataSource _remoteDataSource;
  
  // Cache controllers for streams
  final Map<String, StreamController<PortfolioHoldings>> _holdingsControllers = {};
  final Map<String, StreamController<PortfolioSummary>> _summaryControllers = {};
  
  PortfolioRepositoryImpl(this._remoteDataSource);

  @override
  Future<PortfolioHoldings> getPortfolioHoldings(String userId) async {
    AppLogger.methodEntry('getPortfolioHoldings', tag: 'PortfolioRepository', 
        params: {'userId': userId});
    
    try {
      AppLogger.info('Fetching portfolio holdings from data source', tag: 'PortfolioRepository');
      final dto = await _remoteDataSource.getPortfolioHoldings(userId);
      
      AppLogger.debug('Converting DTO to domain entity', tag: 'PortfolioRepository');
      final domain = dto.toDomain();
      
      // Update stream if exists
      if (_holdingsControllers.containsKey(userId)) {
        AppLogger.debug('Updating holdings stream for user', tag: 'PortfolioRepository');
        _holdingsControllers[userId]!.add(domain);
      }
      
      AppLogger.info('Portfolio holdings retrieved successfully (${domain.holdings.length} holdings)', tag: 'PortfolioRepository');
      AppLogger.methodExit('getPortfolioHoldings', tag: 'PortfolioRepository', result: 'success');
      
      return domain;
    } catch (e) {
      AppLogger.error('Failed to get portfolio holdings', tag: 'PortfolioRepository', 
          error: e, stackTrace: StackTrace.current);
      AppLogger.methodExit('getPortfolioHoldings', tag: 'PortfolioRepository', result: 'error');
      rethrow;
    }
  }

  @override
  Future<PortfolioSummary> getPortfolioSummary(String userId) async {
    final dto = await _remoteDataSource.getPortfolioSummary(userId);
    final domain = dto.toDomain();
    
    // Update stream if exists
    if (_summaryControllers.containsKey(userId)) {
      _summaryControllers[userId]!.add(domain);
    }
    
    return domain;
  }

  @override
  Stream<PortfolioHoldings> watchPortfolioHoldings(String userId) {
    if (!_holdingsControllers.containsKey(userId)) {
      _holdingsControllers[userId] = StreamController<PortfolioHoldings>.broadcast();
      
      // Initialize with current data
      getPortfolioHoldings(userId).then((holdings) {
        if (_holdingsControllers.containsKey(userId)) {
          _holdingsControllers[userId]!.add(holdings);
        }
      }).catchError((error) {
        if (_holdingsControllers.containsKey(userId)) {
          _holdingsControllers[userId]!.addError(error);
        }
      });
    }
    
    return _holdingsControllers[userId]!.stream;
  }

  @override
  Stream<PortfolioSummary> watchPortfolioSummary(String userId) {
    if (!_summaryControllers.containsKey(userId)) {
      _summaryControllers[userId] = StreamController<PortfolioSummary>.broadcast();
      
      // Initialize with current data
      getPortfolioSummary(userId).then((summary) {
        if (_summaryControllers.containsKey(userId)) {
          _summaryControllers[userId]!.add(summary);
        }
      }).catchError((error) {
        if (_summaryControllers.containsKey(userId)) {
          _summaryControllers[userId]!.addError(error);
        }
      });
    }
    
    return _summaryControllers[userId]!.stream;
  }

  @override
  Future<void> refreshPortfolioData(String userId) async {
    // Refresh both holdings and summary
    await Future.wait([
      getPortfolioHoldings(userId),
      getPortfolioSummary(userId),
    ]);
  }

  @override
  Future<PortfolioHolding?> getHoldingDetails(String userId, String symbol) async {
    final holdings = await getPortfolioHoldings(userId);
    return holdings.holdings.where((h) => h.symbol == symbol).firstOrNull;
  }

  @override
  Future<List<SectorAllocation>> getSectorAllocation(String userId) async {
    final summary = await getPortfolioSummary(userId);
    return summary.sectorAllocation;
  }

  @override
  Future<List<TopPerformer>> getTopPerformers(String userId, {int limit = 5}) async {
    final summary = await getPortfolioSummary(userId);
    return summary.topPerformers.take(limit).toList();
  }

  @override
  Future<List<TopPerformer>> getWorstPerformers(String userId, {int limit = 5}) async {
    final summary = await getPortfolioSummary(userId);
    return summary.worstPerformers.take(limit).toList();
  }

  @override
  Future<List<PortfolioHolding>> searchHoldings(String userId, String query) async {
    final holdings = await getPortfolioHoldings(userId);
    final lowerQuery = query.toLowerCase();
    
    return holdings.holdings.where((holding) =>
        holding.symbol.toLowerCase().contains(lowerQuery) ||
        holding.companyName.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  /// Dispose all stream controllers
  void dispose() {
    for (final controller in _holdingsControllers.values) {
      controller.close();
    }
    for (final controller in _summaryControllers.values) {
      controller.close();
    }
    _holdingsControllers.clear();
    _summaryControllers.clear();
  }
}