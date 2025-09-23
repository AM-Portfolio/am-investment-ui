import '../../../core/domain/entities/portfolio_holdings.dart';

/// UI model specifically designed for web portfolio display
/// Optimized for table views, charts, and web-specific interactions
class WebPortfolioHoldingsViewModel {
  /// Holdings optimized for web display
  final List<WebEquityHoldingViewModel> holdings;
  
  /// Summary statistics for dashboard
  final WebPortfolioSummaryViewModel summary;
  
  /// View state information
  final WebPortfolioViewState viewState;

  /// Constructor
  const WebPortfolioHoldingsViewModel({
    required this.holdings,
    required this.summary,
    required this.viewState,
  });

  /// Create from domain model
  factory WebPortfolioHoldingsViewModel.fromDomain(PortfolioHoldings domain) {
    final holdings = domain.holdings
        .map((holding) => WebEquityHoldingViewModel.fromDomain(holding))
        .toList();

    final summary = WebPortfolioSummaryViewModel.fromDomain(domain);
    
    final viewState = WebPortfolioViewState(
      isLoading: false,
      isEmpty: domain.isEmpty,
      lastUpdated: domain.metadata.lastUpdated,
      totalCount: domain.totalHoldings,
    );

    return WebPortfolioHoldingsViewModel(
      holdings: holdings,
      summary: summary,
      viewState: viewState,
    );
  }

  /// Create loading state
  static WebPortfolioHoldingsViewModel loading() {
    return WebPortfolioHoldingsViewModel(
      holdings: const [],
      summary: WebPortfolioSummaryViewModel.empty(),
      viewState: const WebPortfolioViewState(
        isLoading: true,
        isEmpty: false,
        lastUpdated: null,
        totalCount: 0,
      ),
    );
  }

  /// Create empty state
  static WebPortfolioHoldingsViewModel empty() {
    return WebPortfolioHoldingsViewModel(
      holdings: const [],
      summary: WebPortfolioSummaryViewModel.empty(),
      viewState: WebPortfolioViewState(
        isLoading: false,
        isEmpty: true,
        lastUpdated: DateTime.now(),
        totalCount: 0,
      ),
    );
  }

  /// Filter holdings by criteria
  WebPortfolioHoldingsViewModel filterBy({
    String? sector,
    bool? isProfitable,
    double? minValue,
  }) {
    var filteredHoldings = holdings;

    if (sector != null) {
      filteredHoldings = filteredHoldings
          .where((h) => h.sector.toLowerCase() == sector.toLowerCase())
          .toList();
    }

    if (isProfitable != null) {
      filteredHoldings = filteredHoldings
          .where((h) => h.isProfitable == isProfitable)
          .toList();
    }

    if (minValue != null) {
      filteredHoldings = filteredHoldings
          .where((h) => h.currentValue >= minValue)
          .toList();
    }

    return copyWith(holdings: filteredHoldings);
  }

  /// Sort holdings by different criteria
  WebPortfolioHoldingsViewModel sortBy(WebSortCriteria criteria, {bool ascending = true}) {
    final sortedHoldings = List<WebEquityHoldingViewModel>.from(holdings);
    
    switch (criteria) {
      case WebSortCriteria.symbol:
        sortedHoldings.sort((a, b) => ascending 
            ? a.symbol.compareTo(b.symbol)
            : b.symbol.compareTo(a.symbol));
        break;
      case WebSortCriteria.currentValue:
        sortedHoldings.sort((a, b) => ascending 
            ? a.currentValue.compareTo(b.currentValue)
            : b.currentValue.compareTo(a.currentValue));
        break;
      case WebSortCriteria.gainLoss:
        sortedHoldings.sort((a, b) => ascending 
            ? a.totalGainLoss.compareTo(b.totalGainLoss)
            : b.totalGainLoss.compareTo(a.totalGainLoss));
        break;
      case WebSortCriteria.gainLossPercentage:
        sortedHoldings.sort((a, b) => ascending 
            ? a.totalGainLossPercentage.compareTo(b.totalGainLossPercentage)
            : b.totalGainLossPercentage.compareTo(a.totalGainLossPercentage));
        break;
      case WebSortCriteria.portfolioWeight:
        sortedHoldings.sort((a, b) => ascending 
            ? a.portfolioWeight.compareTo(b.portfolioWeight)
            : b.portfolioWeight.compareTo(a.portfolioWeight));
        break;
    }

    return copyWith(holdings: sortedHoldings);
  }

  /// Copy with modifications
  WebPortfolioHoldingsViewModel copyWith({
    List<WebEquityHoldingViewModel>? holdings,
    WebPortfolioSummaryViewModel? summary,
    WebPortfolioViewState? viewState,
  }) {
    return WebPortfolioHoldingsViewModel(
      holdings: holdings ?? this.holdings,
      summary: summary ?? this.summary,
      viewState: viewState ?? this.viewState,
    );
  }
}

/// UI model for individual holding optimized for web display
class WebEquityHoldingViewModel {
  /// Display information
  final String id;
  final String symbol;
  final String displayName;
  final String sector;
  final String industry;
  final String marketCapDisplay;

  /// Financial data formatted for display
  final double shares;
  final String sharesFormatted;
  final double currentPrice;
  final String currentPriceFormatted;
  final double currentValue;
  final String currentValueFormatted;
  final double investedAmount;
  final String investedAmountFormatted;
  final double portfolioWeight;
  final String portfolioWeightFormatted;

  /// Performance data
  final double totalGainLoss;
  final String totalGainLossFormatted;
  final double totalGainLossPercentage;
  final String totalGainLossPercentageFormatted;
  final double todayGainLoss;
  final String todayGainLossFormatted;
  final double todayGainLossPercentage;
  final String todayGainLossPercentageFormatted;

  /// UI state
  final bool isProfitable;
  final bool isTodayPositive;
  final WebHoldingStyle style;

  /// Broker breakdown for tooltips/details
  final List<WebBrokerHoldingViewModel> brokerBreakdown;

  /// Constructor
  const WebEquityHoldingViewModel({
    required this.id,
    required this.symbol,
    required this.displayName,
    required this.sector,
    required this.industry,
    required this.marketCapDisplay,
    required this.shares,
    required this.sharesFormatted,
    required this.currentPrice,
    required this.currentPriceFormatted,
    required this.currentValue,
    required this.currentValueFormatted,
    required this.investedAmount,
    required this.investedAmountFormatted,
    required this.portfolioWeight,
    required this.portfolioWeightFormatted,
    required this.totalGainLoss,
    required this.totalGainLossFormatted,
    required this.totalGainLossPercentage,
    required this.totalGainLossPercentageFormatted,
    required this.todayGainLoss,
    required this.todayGainLossFormatted,
    required this.todayGainLossPercentage,
    required this.todayGainLossPercentageFormatted,
    required this.isProfitable,
    required this.isTodayPositive,
    required this.style,
    required this.brokerBreakdown,
  });

  /// Create from domain model
  factory WebEquityHoldingViewModel.fromDomain(EquityHolding domain) {
    final isProfitable = domain.isProfitable;
    final isTodayPositive = domain.isTodayPositive;

    final brokerBreakdown = domain.brokerHoldings
        .map((broker) => WebBrokerHoldingViewModel.fromDomain(broker))
        .toList();

    return WebEquityHoldingViewModel(
      id: domain.id,
      symbol: domain.symbol,
      displayName: domain.identity.displayName,
      sector: domain.sector,
      industry: domain.industry,
      marketCapDisplay: domain.identity.marketCap.displayName,
      shares: domain.shares,
      sharesFormatted: _formatNumber(domain.shares, decimals: 2),
      currentPrice: domain.currentPrice,
      currentPriceFormatted: _formatCurrency(domain.currentPrice),
      currentValue: domain.currentValue,
      currentValueFormatted: _formatCurrency(domain.currentValue),
      investedAmount: domain.investedAmount,
      investedAmountFormatted: _formatCurrency(domain.investedAmount),
      portfolioWeight: domain.portfolioWeight,
      portfolioWeightFormatted: _formatPercentage(domain.portfolioWeight),
      totalGainLoss: domain.performance.totalGainLoss,
      totalGainLossFormatted: _formatCurrency(domain.performance.totalGainLoss, showSign: true),
      totalGainLossPercentage: domain.performance.totalGainLossPercentage,
      totalGainLossPercentageFormatted: _formatPercentage(domain.performance.totalGainLossPercentage, showSign: true),
      todayGainLoss: domain.performance.todayGainLoss,
      todayGainLossFormatted: _formatCurrency(domain.performance.todayGainLoss, showSign: true),
      todayGainLossPercentage: domain.performance.todayGainLossPercentage,
      todayGainLossPercentageFormatted: _formatPercentage(domain.performance.todayGainLossPercentage, showSign: true),
      isProfitable: isProfitable,
      isTodayPositive: isTodayPositive,
      style: WebHoldingStyle.fromPerformance(isProfitable, isTodayPositive),
      brokerBreakdown: brokerBreakdown,
    );
  }

  /// Formatting helpers
  static String _formatCurrency(double value, {bool showSign = false}) {
    final sign = showSign && value > 0 ? '+' : '';
    return '$sign₹${value.toStringAsFixed(2)}';
  }

  static String _formatPercentage(double value, {bool showSign = false}) {
    final sign = showSign && value > 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(2)}%';
  }

  static String _formatNumber(double value, {int decimals = 0}) {
    return value.toStringAsFixed(decimals);
  }
}

/// UI model for portfolio summary
class WebPortfolioSummaryViewModel {
  final String totalValueFormatted;
  final String totalInvestedFormatted;
  final String totalGainLossFormatted;
  final String totalGainLossPercentageFormatted;
  final int totalHoldings;
  final bool isOverallPositive;
  final WebPortfolioStyle style;

  const WebPortfolioSummaryViewModel({
    required this.totalValueFormatted,
    required this.totalInvestedFormatted,
    required this.totalGainLossFormatted,
    required this.totalGainLossPercentageFormatted,
    required this.totalHoldings,
    required this.isOverallPositive,
    required this.style,
  });

  factory WebPortfolioSummaryViewModel.fromDomain(PortfolioHoldings domain) {
    final isPositive = domain.totalGainLoss >= 0;
    
    return WebPortfolioSummaryViewModel(
      totalValueFormatted: '₹${domain.totalValue.toStringAsFixed(2)}',
      totalInvestedFormatted: '₹${domain.totalInvested.toStringAsFixed(2)}',
      totalGainLossFormatted: '${isPositive ? '+' : ''}₹${domain.totalGainLoss.toStringAsFixed(2)}',
      totalGainLossPercentageFormatted: '${isPositive ? '+' : ''}${domain.totalGainLossPercentage.toStringAsFixed(2)}%',
      totalHoldings: domain.totalHoldings,
      isOverallPositive: isPositive,
      style: WebPortfolioStyle.fromPerformance(isPositive),
    );
  }

  static WebPortfolioSummaryViewModel empty() {
    return const WebPortfolioSummaryViewModel(
      totalValueFormatted: '₹0.00',
      totalInvestedFormatted: '₹0.00',
      totalGainLossFormatted: '₹0.00',
      totalGainLossPercentageFormatted: '0.00%',
      totalHoldings: 0,
      isOverallPositive: true,
      style: WebPortfolioStyle.neutral,
    );
  }
}

/// UI model for broker holdings
class WebBrokerHoldingViewModel {
  final String brokerName;
  final String sharesFormatted;
  final String percentageFormatted;

  const WebBrokerHoldingViewModel({
    required this.brokerName,
    required this.sharesFormatted,
    required this.percentageFormatted,
  });

  factory WebBrokerHoldingViewModel.fromDomain(BrokerHolding domain) {
    return WebBrokerHoldingViewModel(
      brokerName: domain.brokerName,
      sharesFormatted: domain.quantity.toStringAsFixed(2),
      percentageFormatted: '${domain.percentage.toStringAsFixed(1)}%',
    );
  }
}

/// View state for the entire portfolio
class WebPortfolioViewState {
  final bool isLoading;
  final bool isEmpty;
  final DateTime? lastUpdated;
  final int totalCount;

  const WebPortfolioViewState({
    required this.isLoading,
    required this.isEmpty,
    required this.lastUpdated,
    required this.totalCount,
  });

  String get lastUpdatedFormatted {
    if (lastUpdated == null) return 'Never';
    final now = DateTime.now();
    final difference = now.difference(lastUpdated!);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}

/// Styling information for UI components
class WebHoldingStyle {
  final String primaryColor;
  final String backgroundColor;
  final String textColor;
  final String iconName;

  const WebHoldingStyle({
    required this.primaryColor,
    required this.backgroundColor,
    required this.textColor,
    required this.iconName,
  });

  static const WebHoldingStyle positive = WebHoldingStyle(
    primaryColor: '#10B981',
    backgroundColor: '#F0FDF4',
    textColor: '#065F46',
    iconName: 'trending_up',
  );

  static const WebHoldingStyle negative = WebHoldingStyle(
    primaryColor: '#EF4444',
    backgroundColor: '#FEF2F2',
    textColor: '#991B1B',
    iconName: 'trending_down',
  );

  static const WebHoldingStyle neutral = WebHoldingStyle(
    primaryColor: '#6B7280',
    backgroundColor: '#F9FAFB',
    textColor: '#374151',
    iconName: 'trending_flat',
  );

  factory WebHoldingStyle.fromPerformance(bool isProfitable, [bool? isTodayPositive]) {
    if (isProfitable) return positive;
    if (isTodayPositive == false) return negative;
    return neutral;
  }
}

/// Portfolio-level styling
class WebPortfolioStyle {
  final String primaryColor;
  final String accentColor;
  final String backgroundGradient;

  const WebPortfolioStyle({
    required this.primaryColor,
    required this.accentColor,
    required this.backgroundGradient,
  });

  static const WebPortfolioStyle positive = WebPortfolioStyle(
    primaryColor: '#10B981',
    accentColor: '#059669',
    backgroundGradient: 'linear-gradient(135deg, #F0FDF4 0%, #DCFCE7 100%)',
  );

  static const WebPortfolioStyle negative = WebPortfolioStyle(
    primaryColor: '#EF4444',
    accentColor: '#DC2626',
    backgroundGradient: 'linear-gradient(135deg, #FEF2F2 0%, #FEE2E2 100%)',
  );

  static const WebPortfolioStyle neutral = WebPortfolioStyle(
    primaryColor: '#6B7280',
    accentColor: '#4B5563',
    backgroundGradient: 'linear-gradient(135deg, #F9FAFB 0%, #F3F4F6 100%)',
  );

  factory WebPortfolioStyle.fromPerformance(bool isPositive) {
    return isPositive ? positive : negative;
  }
}

/// Sort criteria for web table
enum WebSortCriteria {
  symbol,
  currentValue,
  gainLoss,
  gainLossPercentage,
  portfolioWeight,
}