# Trade System Integration Guide - Following Portfolio Architecture

## Overview
This guide explains the complete trade management system integration following the exact same clean architecture patterns used in the portfolio feature, ensuring consistency across the codebase and leveraging proven implementation strategies.

---

## 🏗️ **Trade Structure Following Portfolio Pattern**

### **Exact Structure Mirroring Portfolio Feature**

```
lib/features/trade/                        # 📦 Trade feature (mirrors portfolio structure exactly)
├── internal/                              # 🧠 ALL feature-specific logic (following portfolio pattern)
│   ├── data/                             # Data layer - external concerns (same as portfolio)
│   │   ├── datasources/                   # Remote and local data sources (same pattern)
│   │   │   ├── trade_datasource.dart     # Abstract interface (like portfolio_datasource.dart)
│   │   │   └── trade_datasource_impl.dart # Implementation (like portfolio_datasource_impl.dart)
│   │   ├── dtos/                         # API Data Transfer Objects (same pattern)
│   │   │   └── trade_dtos.dart          # @freezed + @JsonSerializable API models
│   │   ├── mappers/                      # DTO ↔ Entity conversion (same pattern)
│   │   │   └── trade_mappers.dart        # Conversion logic (like portfolio_mappers.dart)
│   │   └── repositories/                 # Repository implementations (same pattern)
│   │       └── trade_repository_impl.dart # Concrete repository (like portfolio_repository_impl.dart)
│   │
│   ├── domain/                           # Pure business logic (same as portfolio)
│   │   ├── entities/                     # Domain entities (same pattern)
│   │   │   └── trade_entities.dart       # @freezed domain models with business logic
│   │   ├── repositories/                 # Abstract repository interfaces (same pattern)
│   │   │   └── trade_repository.dart     # Abstract interface (like portfolio_repository.dart)
│   │   └── usecases/                     # Single-purpose business operations (same pattern)
│   │       └── trade_usecases.dart       # Use cases (like portfolio_usecases.dart)
│   │
│   └── services/                         # Complex workflow orchestration (same as portfolio)
│       └── trade_service.dart            # Multi-step workflows (like portfolio_service.dart)
│
├── presentation/                         # 🎨 UI layer - matches portfolio structure exactly
│   ├── cubit/                           # State management (same as portfolio cubit structure)
│   │   ├── trade_cubit.dart             # Main cubit (like portfolio_cubit.dart)
│   │   └── trade_state.dart             # State definitions (like portfolio_state.dart)
│   │
│   ├── common/                          # Widgets reused across web/mobile (like portfolio/common)
│   │   ├── trade_summary_template.dart   # Reusable summary template
│   │   ├── trade_holdings_template.dart  # Reusable holdings template
│   │   └── trade_calendar_template.dart  # Reusable calendar template
│   │
│   ├── pages/                           # Page implementations (like portfolio/pages)
│   │   ├── trade_summary_page.dart      # Page 1: Summary & Asset Allocation
│   │   ├── trade_holdings_page.dart     # Page 2: Holdings Management
│   │   └── trade_calendar_page.dart     # Page 3: Calendar Analytics
│   │
│   ├── web/                             # Web-specific UI (like portfolio/web)
│   │   ├── trade_summary_web_widget.dart    # Web summary widget
│   │   ├── trade_holdings_web_widget.dart   # Web holdings widget
│   │   ├── trade_calendar_web_widget.dart   # Web calendar widget
│   │   └── trade_web_screen.dart            # Web screen (like portfolio_web_screen.dart)
│   │
│   ├── mobile/                          # Mobile UI (like portfolio/mobile)
│   │   └── trade_mobile_widgets.dart    # Mobile-specific widgets
│   │
│   └── widgets/                         # Trade-specific UI components (like portfolio/widgets)
│       ├── trade_card.dart              # Trade display card
│       ├── trade_metrics_display.dart   # Metrics display
│       └── trade_allocation_chart.dart  # Allocation chart
│
├── providers/                           # 🔗 Trade feature providers (like portfolio/providers)
│   └── trade_providers.dart             # @riverpod dependency injection
│
└── README.md                            # Trade feature documentation (like portfolio/README.md)
```

---

## 📊 **Implementation Following Portfolio Patterns**

### **1. DTOs Structure (Following Portfolio DTOs)**

```dart
// lib/features/trade/internal/data/dtos/trade_dtos.dart
// Following exact pattern from portfolio DTOs

import 'package:freezed_annotation/freezed_annotation.dart';

part 'trade_dtos.freezed.dart';
part 'trade_dtos.g.dart';

// Trade Portfolio Summary DTO (following portfolio DTO pattern)
@freezed
class ApiTradePortfolioSummaryDto with _$ApiTradePortfolioSummaryDto {
  const factory ApiTradePortfolioSummaryDto({
    required String portfolioId,
    required String portfolioName,
    required String ownerId,
    required double totalValue,
    required double totalReturn,
    required double totalReturnPercentage,
    required int totalTrades,
    required int activeTrades,
    required DateTime lastUpdated,
  }) = _ApiTradePortfolioSummaryDto;

  factory ApiTradePortfolioSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$ApiTradePortfolioSummaryDtoFromJson(json);
}

// Trade Holdings DTO (following portfolio holdings pattern)
@freezed
class ApiTradeHoldingDto with _$ApiTradeHoldingDto {
  const factory ApiTradeHoldingDto({
    required String tradeId,
    required String portfolioId,
    required String symbol,
    required String instrumentName,
    required String tradeType,
    required double quantity,
    required double entryPrice,
    double? exitPrice,
    required DateTime entryDate,
    DateTime? exitDate,
    required String status,
    required double currentValue,
    required double unrealizedPnL,
    required double realizedPnL,
  }) = _ApiTradeHoldingDto;

  factory ApiTradeHoldingDto.fromJson(Map<String, dynamic> json) =>
      _$ApiTradeHoldingDtoFromJson(json);
}

// ...existing code...
```

### **2. DataSource Implementation (Following Portfolio DataSource)**

```dart
// lib/features/trade/internal/data/datasources/trade_datasource.dart
// Following exact pattern from portfolio_datasource.dart

abstract class TradeDataSource {
  // Portfolio Discovery (Step 1) - same pattern as portfolio
  Future<List<ApiTradePortfolioSummaryDto>> getPortfoliosByOwner(String ownerId);
  
  // Portfolio Analysis (Step 2) - following portfolio patterns
  Future<ApiTradePortfolioSummaryDto> getPortfolioSummary(String portfolioId);
  Future<List<ApiTradeHoldingDto>> getTradeHoldings({
    required String portfolioId,
    int page = 1,
    int limit = 50,
    String? searchQuery,
    String? statusFilter,
  });
  
  // Trade Details (Step 3) - trade-specific but following same pattern
  Future<List<ApiTradeHoldingDto>> getTradeDetailsByIds(List<String> tradeIds);
  
  // Calendar Analytics (Step 4) - trade-specific
  Future<Map<String, dynamic>> getCalendarData({
    required String portfolioId,
    required String viewType,
    required DateTime startDate,
    required DateTime endDate,
  });
}

// Implementation following portfolio_datasource_impl.dart pattern
class TradeDataSourceImpl implements TradeDataSource {
  final ApiClient _apiClient;
  
  const TradeDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;
  
  @override
  Future<List<ApiTradePortfolioSummaryDto>> getPortfoliosByOwner(String ownerId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/v1/portfolio-summary/by-owner/$ownerId',
    );
    
    final List<dynamic> portfolioList = response.data!['portfolios'];
    return portfolioList
        .cast<Map<String, dynamic>>()
        .map((json) => ApiTradePortfolioSummaryDto.fromJson(json))
        .toList();
  }

  @override
  Future<ApiTradePortfolioSummaryDto> getPortfolioSummary(String portfolioId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/v1/portfolio-summary/$portfolioId',
    );
    return ApiTradePortfolioSummaryDto.fromJson(response.data!);
  }

  @override
  Future<List<ApiTradeHoldingDto>> getTradeHoldings({
    required String portfolioId,
    int page = 1,
    int limit = 50,
    String? searchQuery,
    String? statusFilter,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (searchQuery != null) 'search': searchQuery,
      if (statusFilter != null) 'status': statusFilter,
    };

    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/v1/trades/portfolio-details/$portfolioId',
      queryParameters: queryParams,
    );

    final List<dynamic> trades = response.data!['trades'];
    return trades
        .cast<Map<String, dynamic>>()
        .map((json) => ApiTradeHoldingDto.fromJson(json))
        .toList();
  }

  // ...existing code...
}
```

### **3. Mappers Implementation (Following Portfolio Mappers)**

```dart
// lib/features/trade/internal/data/mappers/trade_mappers.dart
// Following exact pattern from portfolio_mappers.dart

import '../../domain/entities/trade_entities.dart';
import '../dtos/trade_dtos.dart';

class TradeMappers {
  // Portfolio List Mapping (same pattern as portfolio mappers)
  List<TradePortfolioSummary> portfolioListFromDtos(List<ApiTradePortfolioSummaryDto> dtos) {
    return dtos.map(portfolioSummaryFromDto).toList();
  }
  
  TradePortfolioSummary portfolioSummaryFromDto(ApiTradePortfolioSummaryDto dto) {
    return TradePortfolioSummary(
      portfolioId: dto.portfolioId,
      portfolioName: dto.portfolioName,
      ownerId: dto.ownerId,
      totalValue: dto.totalValue,
      totalReturn: dto.totalReturn,
      totalReturnPercentage: dto.totalReturnPercentage,
      totalTrades: dto.totalTrades,
      activeTrades: dto.activeTrades,
      lastUpdated: dto.lastUpdated,
    );
  }
  
  // Trade Holdings Mapping (following portfolio holdings pattern)
  List<TradeHolding> tradeHoldingsFromDtos(List<ApiTradeHoldingDto> dtos) {
    return dtos.map(_tradeHoldingFromDto).toList();
  }
  
  TradeHolding _tradeHoldingFromDto(ApiTradeHoldingDto dto) {
    return TradeHolding(
      tradeId: dto.tradeId,
      portfolioId: dto.portfolioId,
      symbol: dto.symbol,
      instrumentName: dto.instrumentName,
      tradeType: _getTradeType(dto.tradeType),
      quantity: dto.quantity,
      entryPrice: dto.entryPrice,
      exitPrice: dto.exitPrice,
      entryDate: dto.entryDate,
      exitDate: dto.exitDate,
      status: _getTradeStatus(dto.status),
      currentValue: dto.currentValue,
      unrealizedPnL: dto.unrealizedPnL,
      realizedPnL: dto.realizedPnL,
    );
  }

  TradeType _getTradeType(String type) {
    switch (type.toLowerCase()) {
      case 'buy': return TradeType.buy;
      case 'sell': return TradeType.sell;
      default: return TradeType.buy;
    }
  }

  TradeStatus _getTradeStatus(String status) {
    switch (status.toLowerCase()) {
      case 'open': return TradeStatus.open;
      case 'closed': return TradeStatus.closed;
      case 'pending': return TradeStatus.pending;
      default: return TradeStatus.open;
    }
  }

  // ...existing code...
}
```

### **4. Repository Implementation (Following Portfolio Repository)**

```dart
// lib/features/trade/internal/data/repositories/trade_repository_impl.dart
// Following exact pattern from portfolio_repository_impl.dart

import '../../domain/entities/trade_entities.dart';
import '../../domain/repositories/trade_repository.dart';
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
      throw _handleError(e); // Same error handling as portfolio
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
  
  // Same error handling pattern as portfolio
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

  // ...existing code...
}

// Same exception classes as portfolio
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
```

### **5. Domain Entities (Following Portfolio Entities)**

```dart
// lib/features/trade/internal/domain/entities/trade_entities.dart
// Following exact pattern from portfolio entities

import 'package:freezed_annotation/freezed_annotation.dart';

part 'trade_entities.freezed.dart';

// Trade Portfolio Summary Entity (following portfolio summary pattern)
@freezed
class TradePortfolioSummary with _$TradePortfolioSummary {
  const factory TradePortfolioSummary({
    required String portfolioId,
    required String portfolioName,
    required String ownerId,
    required double totalValue,
    required double totalReturn,
    required double totalReturnPercentage,
    required int totalTrades,
    required int activeTrades,
    required DateTime lastUpdated,
  }) = _TradePortfolioSummary;

  const TradePortfolioSummary._();

  // Business logic methods (same pattern as portfolio)
  bool get isPositiveReturn => totalReturn > 0;
  bool get hasActiveTrades => activeTrades > 0;
  String get performanceStatus => isPositiveReturn ? 'Profit' : 'Loss';
  double get averageTradeValue => totalTrades > 0 ? totalValue / totalTrades : 0;
}

// Trade Holding Entity (following portfolio holding pattern)
@freezed
class TradeHolding with _$TradeHolding {
  const factory TradeHolding({
    required String tradeId,
    required String portfolioId,
    required String symbol,
    required String instrumentName,
    required TradeType tradeType,
    required double quantity,
    required double entryPrice,
    double? exitPrice,
    required DateTime entryDate,
    DateTime? exitDate,
    required TradeStatus status,
    required double currentValue,
    required double unrealizedPnL,
    required double realizedPnL,
  }) = _TradeHolding;

  const TradeHolding._();

  // Business logic methods (same pattern as portfolio holdings)
  double get totalPnL => unrealizedPnL + realizedPnL;
  double get returnPercentage => (totalPnL / (entryPrice * quantity)) * 100;
  bool get isProfitable => totalPnL > 0;
  bool get isOpenTrade => status == TradeStatus.open;
  Duration get holdingPeriod => (exitDate ?? DateTime.now()).difference(entryDate);
}

// Enums (following portfolio enum patterns)
enum TradeType { buy, sell, short, cover }
enum TradeStatus { open, closed, pending, cancelled }
```

### **6. Use Cases (Following Portfolio Use Cases)**

```dart
// lib/features/trade/internal/domain/usecases/trade_usecases.dart
// Following exact pattern from portfolio_usecases.dart

import '../entities/trade_entities.dart';
import '../repositories/trade_repository.dart';

// Base use case class (same as portfolio)
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

// Get portfolios by owner use case (same pattern as portfolio)
class GetPortfoliosByOwnerUseCase implements UseCase<List<TradePortfolioSummary>, String> {
  final TradeRepository _repository;

  GetPortfoliosByOwnerUseCase(this._repository);

  @override
  Future<List<TradePortfolioSummary>> call(String ownerId) async {
    if (ownerId.isEmpty) {
      throw ArgumentError('Owner ID cannot be empty');
    }
    return await _repository.getPortfoliosByOwner(ownerId);
  }
}

// Get portfolio summary use case (same pattern as portfolio)
class GetPortfolioSummaryUseCase implements UseCase<TradePortfolioSummary, String> {
  final TradeRepository _repository;

  GetPortfolioSummaryUseCase(this._repository);

  @override
  Future<TradePortfolioSummary> call(String portfolioId) async {
    if (portfolioId.isEmpty) {
      throw ArgumentError('Portfolio ID cannot be empty');
    }
    return await _repository.getPortfolioSummary(portfolioId);
  }
}

// Get trade holdings use case (following portfolio holdings pattern)
class GetTradeHoldingsUseCase implements UseCase<List<TradeHolding>, TradeHoldingsParams> {
  final TradeRepository _repository;

  GetTradeHoldingsUseCase(this._repository);

  @override
  Future<List<TradeHolding>> call(TradeHoldingsParams params) async {
    if (params.portfolioId.isEmpty) {
      throw ArgumentError('Portfolio ID cannot be empty');
    }
    if (params.page < 1) {
      throw ArgumentError('Page must be greater than 0');
    }
    if (params.limit < 1 || params.limit > 100) {
      throw ArgumentError('Limit must be between 1 and 100');
    }

    return await _repository.getTradeHoldings(
      portfolioId: params.portfolioId,
      page: params.page,
      limit: params.limit,
      searchQuery: params.searchQuery,
      statusFilter: params.statusFilter,
    );
  }
}

// Parameter classes (same pattern as portfolio)
class TradeHoldingsParams {
  final String portfolioId;
  final int page;
  final int limit;
  final String? searchQuery;
  final TradeStatus? statusFilter;

  const TradeHoldingsParams({
    required this.portfolioId,
    this.page = 1,
    this.limit = 50,
    this.searchQuery,
    this.statusFilter,
  });
}

// ...existing code...
```

### **7. Providers (Following Portfolio Providers)**

```dart
// lib/features/trade/providers/trade_providers.dart
// Following exact pattern from portfolio_providers.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import '../internal/data/datasources/trade_datasource.dart';
import '../internal/data/mappers/trade_mappers.dart';
import '../internal/data/repositories/trade_repository_impl.dart';
import '../internal/domain/repositories/trade_repository.dart';
import '../internal/domain/usecases/trade_usecases.dart';
import '../presentation/cubit/trade_cubit.dart';

part 'trade_providers.g.dart';

// Data layer providers (same pattern as portfolio)
@riverpod
TradeDataSource tradeDataSource(TradeDataSourceRef ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TradeDataSourceImpl(apiClient: apiClient);
}

@riverpod
TradeMappers tradeMappers(TradeMappersRef ref) {
  return TradeMappers();
}

@riverpod
TradeRepository tradeRepository(TradeRepositoryRef ref) {
  final dataSource = ref.watch(tradeDataSourceProvider);
  final mappers = ref.watch(tradeMappersProvider);
  return TradeRepositoryImpl(dataSource: dataSource, mappers: mappers);
}

// Use case providers (same pattern as portfolio)
@riverpod
GetPortfoliosByOwnerUseCase getPortfoliosByOwnerUseCase(GetPortfoliosByOwnerUseCaseRef ref) {
  final repository = ref.watch(tradeRepositoryProvider);
  return GetPortfoliosByOwnerUseCase(repository);
}

@riverpod
GetPortfolioSummaryUseCase getPortfolioSummaryUseCase(GetPortfolioSummaryUseCaseRef ref) {
  final repository = ref.watch(tradeRepositoryProvider);
  return GetPortfolioSummaryUseCase(repository);
}

@riverpod
GetTradeHoldingsUseCase getTradeHoldingsUseCase(GetTradeHoldingsUseCaseRef ref) {
  final repository = ref.watch(tradeRepositoryProvider);
  return GetTradeHoldingsUseCase(repository);
}

// Cubit provider (same pattern as portfolio)
@riverpod
TradeCubit tradeCubit(TradeCubitRef ref) {
  return TradeCubit(
    getPortfoliosByOwner: ref.watch(getPortfoliosByOwnerUseCaseProvider),
    getPortfolioSummary: ref.watch(getPortfolioSummaryUseCaseProvider),
    getTradeHoldings: ref.watch(getTradeHoldingsUseCaseProvider),
  );
}

// ...existing code...
```

---

## 💡 **Benefits of Following Portfolio Pattern Exactly**

### **1. Complete Consistency**
- **Same File Names**: TradeDataSource mirrors PortfolioDataSource
- **Same Method Signatures**: Identical patterns for similar operations
- **Same Error Handling**: Consistent exception types and handling
- **Same Provider Structure**: Identical dependency injection patterns

### **2. Developer Familiarity**
- **Easy Context Switching**: Developers can move between portfolio and trade seamlessly
- **Reusable Knowledge**: Learning portfolio structure applies directly to trade
- **Consistent Debugging**: Same patterns make troubleshooting easier
- **Code Review Efficiency**: Reviewers familiar with portfolio can easily review trade

### **3. Maintainability**
- **Unified Updates**: Changes to patterns can be applied to both features
- **Shared Utilities**: Common error handling, mapping patterns, validation
- **Testing Consistency**: Same testing strategies work for both features
- **Documentation Reuse**: Portfolio documentation patterns apply to trade

### **4. Future Scalability**
- **Template for New Features**: Established pattern for financial features
- **Component Library**: Shared UI components between portfolio and trade
- **Architectural Standards**: Consistent clean architecture across all features
- **Code Quality**: Maintain high standards with proven patterns

This approach ensures that the trade system follows the exact same proven architecture as the portfolio feature, making it easy to maintain, extend, and understand for any developer familiar with the existing codebase.
- **Reduced Development Time**: Don't recreate what already exists
- **Lower Risk**: Follow patterns that are already working in production

### **Scalability for Future Features**
- **Template Library**: Build reusable template library from portfolio/trade patterns
- **Standard Architecture**: Establish consistent patterns for all financial features
- **Easy Onboarding**: New developers learn one pattern that applies everywhere
- **Code Quality**: Maintain high standards across all features

This approach ensures that the trade system follows the exact same proven architecture as the portfolio feature while providing the specific functionality needed for trade management across three dedicated pages.
