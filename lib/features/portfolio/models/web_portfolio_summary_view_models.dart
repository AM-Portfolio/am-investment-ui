import '../../../core/domain/entities/portfolio_summary.dart';

/// UI model specifically designed for web portfolio summary display
/// Optimized for dashboard views, charts, and web-specific interactions
class WebPortfolioSummaryViewModel {
  /// Portfolio overview for dashboard
  final WebPortfolioOverview overview;
  
  /// Performance metrics for charts
  final WebPerformanceMetrics performance;
  
  /// Allocation breakdown for pie charts
  final WebAllocationBreakdown allocation;
  
  /// Market insights for recommendations
  final WebMarketInsights insights;
  
  /// View state information
  final WebSummaryViewState viewState;

  /// Constructor
  const WebPortfolioSummaryViewModel({
    required this.overview,
    required this.performance,
    required this.allocation,
    required this.insights,
    required this.viewState,
  });

  /// Create from domain model
  factory WebPortfolioSummaryViewModel.fromDomain(PortfolioSummary domain) {
    final overview = WebPortfolioOverview.fromDomain(domain);
    final performance = WebPerformanceMetrics.fromDomain(domain.performance);
    final allocation = WebAllocationBreakdown.fromDomain(domain.allocation);
    final insights = WebMarketInsights.fromDomain(domain.insights);
    
    final viewState = WebSummaryViewState(
      isLoading: false,
      isEmpty: domain.portfolioValue.current == 0,
      lastUpdated: domain.metadata.lastUpdated,
      dataSource: domain.metadata.dataSource,
      performanceCategory: domain.performance.category,
    );

    return WebPortfolioSummaryViewModel(
      overview: overview,
      performance: performance,
      allocation: allocation,
      insights: insights,
      viewState: viewState,
    );
  }

  /// Create loading state
  static WebPortfolioSummaryViewModel loading() {
    return WebPortfolioSummaryViewModel(
      overview: WebPortfolioOverview.empty(),
      performance: WebPerformanceMetrics.empty(),
      allocation: WebAllocationBreakdown.empty(),
      insights: WebMarketInsights.empty(),
      viewState: const WebSummaryViewState(
        isLoading: true,
        isEmpty: false,
        lastUpdated: null,
        dataSource: DataSource.api,
        performanceCategory: PerformanceCategory.fair,
      ),
    );
  }

  /// Create empty state
  static WebPortfolioSummaryViewModel empty() {
    return WebPortfolioSummaryViewModel(
      overview: WebPortfolioOverview.empty(),
      performance: WebPerformanceMetrics.empty(),
      allocation: WebAllocationBreakdown.empty(),
      insights: WebMarketInsights.empty(),
      viewState: WebSummaryViewState(
        isLoading: false,
        isEmpty: true,
        lastUpdated: DateTime.now(),
        dataSource: DataSource.api,
        performanceCategory: PerformanceCategory.fair,
      ),
    );
  }

  /// Copy with modifications
  WebPortfolioSummaryViewModel copyWith({
    WebPortfolioOverview? overview,
    WebPerformanceMetrics? performance,
    WebAllocationBreakdown? allocation,
    WebMarketInsights? insights,
    WebSummaryViewState? viewState,
  }) {
    return WebPortfolioSummaryViewModel(
      overview: overview ?? this.overview,
      performance: performance ?? this.performance,
      allocation: allocation ?? this.allocation,
      insights: insights ?? this.insights,
      viewState: viewState ?? this.viewState,
    );
  }
}

/// UI model for portfolio overview section
class WebPortfolioOverview {
  final String totalValueFormatted;
  final String investedAmountFormatted;
  final String totalGainFormatted;
  final String totalGainPercentageFormatted;
  final String todayGainFormatted;
  final String todayGainPercentageFormatted;
  final String returnOnInvestmentFormatted;
  final int totalHoldings;
  final bool isPositive;
  final bool isTodayPositive;
  final WebOverviewStyle style;

  const WebPortfolioOverview({
    required this.totalValueFormatted,
    required this.investedAmountFormatted,
    required this.totalGainFormatted,
    required this.totalGainPercentageFormatted,
    required this.todayGainFormatted,
    required this.todayGainPercentageFormatted,
    required this.returnOnInvestmentFormatted,
    required this.totalHoldings,
    required this.isPositive,
    required this.isTodayPositive,
    required this.style,
  });

  factory WebPortfolioOverview.fromDomain(PortfolioSummary domain) {
    final isPositive = domain.performance.totalGain >= 0;
    final isTodayPositive = domain.performance.todayGain >= 0;

    return WebPortfolioOverview(
      totalValueFormatted: _formatCurrency(domain.portfolioValue.current),
      investedAmountFormatted: _formatCurrency(domain.portfolioValue.invested),
      totalGainFormatted: _formatCurrency(domain.performance.totalGain, showSign: true),
      totalGainPercentageFormatted: _formatPercentage(domain.performance.totalGainPercentage, showSign: true),
      todayGainFormatted: _formatCurrency(domain.performance.todayGain, showSign: true),
      todayGainPercentageFormatted: _formatPercentage(domain.performance.todayGainPercentage, showSign: true),
      returnOnInvestmentFormatted: _formatPercentage(domain.returnOnInvestment),
      totalHoldings: domain.metadata.totalHoldings,
      isPositive: isPositive,
      isTodayPositive: isTodayPositive,
      style: WebOverviewStyle.fromPerformance(isPositive, isTodayPositive),
    );
  }

  static WebPortfolioOverview empty() {
    return const WebPortfolioOverview(
      totalValueFormatted: '₹0.00',
      investedAmountFormatted: '₹0.00',
      totalGainFormatted: '₹0.00',
      totalGainPercentageFormatted: '0.00%',
      todayGainFormatted: '₹0.00',
      todayGainPercentageFormatted: '0.00%',
      returnOnInvestmentFormatted: '0.00%',
      totalHoldings: 0,
      isPositive: true,
      isTodayPositive: true,
      style: WebOverviewStyle.neutral,
    );
  }

  /// Formatting helpers
  static String _formatCurrency(double value, {bool showSign = false}) {
    final sign = showSign && value > 0 ? '+' : '';
    if (value >= 1000000) {
      return '${sign}₹${(value / 1000000).toStringAsFixed(2)}M';
    } else if (value >= 1000) {
      return '${sign}₹${(value / 1000).toStringAsFixed(1)}K';
    }
    return '$sign₹${value.toStringAsFixed(2)}';
  }

  static String _formatPercentage(double value, {bool showSign = false}) {
    final sign = showSign && value > 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(2)}%';
  }
}

/// UI model for performance metrics
class WebPerformanceMetrics {
  final double totalGain;
  final double totalGainPercentage;
  final double todayGain;
  final double todayGainPercentage;
  final String performanceCategoryDisplay;
  final String performanceDescription;
  final WebPerformanceStyle style;
  final List<WebPerformanceIndicator> indicators;

  const WebPerformanceMetrics({
    required this.totalGain,
    required this.totalGainPercentage,
    required this.todayGain,
    required this.todayGainPercentage,
    required this.performanceCategoryDisplay,
    required this.performanceDescription,
    required this.style,
    required this.indicators,
  });

  factory WebPerformanceMetrics.fromDomain(PortfolioPerformance domain) {
    final indicators = [
      WebPerformanceIndicator(
        label: 'Total Return',
        value: domain.totalGainPercentage,
        isPositive: domain.totalGain >= 0,
        iconName: domain.totalGain >= 0 ? 'trending_up' : 'trending_down',
      ),
      WebPerformanceIndicator(
        label: 'Today',
        value: domain.todayGainPercentage,
        isPositive: domain.todayGain >= 0,
        iconName: domain.todayGain >= 0 ? 'arrow_upward' : 'arrow_downward',
      ),
    ];

    return WebPerformanceMetrics(
      totalGain: domain.totalGain,
      totalGainPercentage: domain.totalGainPercentage,
      todayGain: domain.todayGain,
      todayGainPercentage: domain.todayGainPercentage,
      performanceCategoryDisplay: domain.category.displayName,
      performanceDescription: domain.category.description,
      style: WebPerformanceStyle.fromCategory(domain.category),
      indicators: indicators,
    );
  }

  static WebPerformanceMetrics empty() {
    return const WebPerformanceMetrics(
      totalGain: 0.0,
      totalGainPercentage: 0.0,
      todayGain: 0.0,
      todayGainPercentage: 0.0,
      performanceCategoryDisplay: 'Fair',
      performanceDescription: 'No performance data available',
      style: WebPerformanceStyle.neutral,
      indicators: [],
    );
  }
}

/// UI model for allocation breakdown
class WebAllocationBreakdown {
  final List<WebSectorAllocation> sectorAllocations;
  final List<WebMarketCapAllocation> marketCapAllocations;
  final bool isWellDiversified;
  final String dominantSector;
  final String diversificationAdvice;

  const WebAllocationBreakdown({
    required this.sectorAllocations,
    required this.marketCapAllocations,
    required this.isWellDiversified,
    required this.dominantSector,
    required this.diversificationAdvice,
  });

  factory WebAllocationBreakdown.fromDomain(PortfolioAllocation domain) {
    // Convert sector breakdown
    final sectorAllocations = domain.sectorBreakdown.entries
        .map((entry) => WebSectorAllocation(
              sectorName: entry.key,
              percentage: entry.value,
              isOverweight: entry.value > 30.0,
              color: _getSectorColor(entry.key),
            ))
        .toList()
      ..sort((a, b) => b.percentage.compareTo(a.percentage));

    // Convert market cap breakdown
    final marketCapAllocations = domain.marketCapDistribution.entries
        .map((entry) => WebMarketCapAllocation(
              category: entry.key,
              percentage: entry.value,
              holdingsCount: domain.marketCapBreakdown[entry.key]?.length ?? 0,
              color: _getMarketCapColor(entry.key),
            ))
        .toList()
      ..sort((a, b) => b.percentage.compareTo(a.percentage));

    // Find dominant sector
    final dominantSector = sectorAllocations.isNotEmpty 
        ? sectorAllocations.first.sectorName 
        : 'N/A';

    // Generate diversification advice
    final diversificationAdvice = domain.isBalanced
        ? 'Portfolio is well diversified across sectors'
        : 'Consider rebalancing - some sectors may be overweight';

    return WebAllocationBreakdown(
      sectorAllocations: sectorAllocations,
      marketCapAllocations: marketCapAllocations,
      isWellDiversified: domain.isBalanced,
      dominantSector: dominantSector,
      diversificationAdvice: diversificationAdvice,
    );
  }

  static WebAllocationBreakdown empty() {
    return const WebAllocationBreakdown(
      sectorAllocations: [],
      marketCapAllocations: [],
      isWellDiversified: true,
      dominantSector: 'N/A',
      diversificationAdvice: 'No allocation data available',
    );
  }

  /// Helper to get sector colors for charts
  static String _getSectorColor(String sector) {
    const sectorColors = {
      'Technology': '#3B82F6',
      'Healthcare': '#10B981',
      'Finance': '#F59E0B',
      'Consumer': '#EF4444',
      'Energy': '#8B5CF6',
      'Materials': '#06B6D4',
      'Industrials': '#84CC16',
      'Utilities': '#F97316',
      'Real Estate': '#EC4899',
      'Telecommunications': '#6366F1',
    };
    return sectorColors[sector] ?? '#6B7280';
  }

  /// Helper to get market cap colors
  static String _getMarketCapColor(MarketCapCategory category) {
    switch (category) {
      case MarketCapCategory.largeCap:
        return '#1E40AF';
      case MarketCapCategory.midCap:
        return '#7C3AED';
      case MarketCapCategory.smallCap:
        return '#DC2626';
      case MarketCapCategory.microCap:
        return '#B91C1C';
      case MarketCapCategory.unknown:
        return '#6B7280';
    }
  }
}

/// UI model for market insights
class WebMarketInsights {
  final List<WebTopPerformer> topPerformers;
  final List<WebTopLoser> topLosers;
  final List<String> recommendations;
  final String marketSentiment;
  final WebInsightsStyle style;

  const WebMarketInsights({
    required this.topPerformers,
    required this.topLosers,
    required this.recommendations,
    required this.marketSentiment,
    required this.style,
  });

  factory WebMarketInsights.fromDomain(PortfolioInsights domain) {
    final topPerformers = domain.topPerformers
        .map((performer) => WebTopPerformer.fromDomain(performer))
        .toList();

    final topLosers = domain.topLosers
        .map((loser) => WebTopLoser.fromDomain(loser))
        .toList();

    // Determine market sentiment
    final marketSentiment = _determineSentiment(topPerformers, topLosers);

    return WebMarketInsights(
      topPerformers: topPerformers,
      topLosers: topLosers,
      recommendations: domain.recommendations,
      marketSentiment: marketSentiment,
      style: WebInsightsStyle.fromSentiment(marketSentiment),
    );
  }

  static WebMarketInsights empty() {
    return const WebMarketInsights(
      topPerformers: [],
      topLosers: [],
      recommendations: [],
      marketSentiment: 'Neutral',
      style: WebInsightsStyle.neutral,
    );
  }

  static String _determineSentiment(List<WebTopPerformer> performers, List<WebTopLoser> losers) {
    if (performers.isEmpty && losers.isEmpty) return 'Neutral';
    if (performers.length > losers.length) return 'Positive';
    if (losers.length > performers.length) return 'Negative';
    return 'Mixed';
  }
}

/// Supporting UI models
class WebSectorAllocation {
  final String sectorName;
  final double percentage;
  final bool isOverweight;
  final String color;

  const WebSectorAllocation({
    required this.sectorName,
    required this.percentage,
    required this.isOverweight,
    required this.color,
  });

  String get percentageFormatted => '${percentage.toStringAsFixed(1)}%';
}

class WebMarketCapAllocation {
  final MarketCapCategory category;
  final double percentage;
  final int holdingsCount;
  final String color;

  const WebMarketCapAllocation({
    required this.category,
    required this.percentage,
    required this.holdingsCount,
    required this.color,
  });

  String get categoryDisplay => category.displayName;
  String get percentageFormatted => '${percentage.toStringAsFixed(1)}%';
  String get holdingsText => '$holdingsCount holding${holdingsCount != 1 ? 's' : ''}';
}

class WebTopPerformer {
  final String symbol;
  final String displayName;
  final String gainPercentageFormatted;
  final String gainAmountFormatted;
  final bool isSignificant;

  const WebTopPerformer({
    required this.symbol,
    required this.displayName,
    required this.gainPercentageFormatted,
    required this.gainAmountFormatted,
    required this.isSignificant,
  });

  factory WebTopPerformer.fromDomain(TopPerformer domain) {
    return WebTopPerformer(
      symbol: domain.symbol,
      displayName: domain.displayName,
      gainPercentageFormatted: '+${domain.gainPercentage.toStringAsFixed(2)}%',
      gainAmountFormatted: '+₹${domain.gainAmount.toStringAsFixed(2)}',
      isSignificant: domain.isSignificantGain,
    );
  }
}

class WebTopLoser {
  final String symbol;
  final String displayName;
  final String lossPercentageFormatted;
  final String lossAmountFormatted;
  final bool isSignificant;

  const WebTopLoser({
    required this.symbol,
    required this.displayName,
    required this.lossPercentageFormatted,
    required this.lossAmountFormatted,
    required this.isSignificant,
  });

  factory WebTopLoser.fromDomain(TopLoser domain) {
    return WebTopLoser(
      symbol: domain.symbol,
      displayName: domain.displayName,
      lossPercentageFormatted: '-${domain.lossPercentage.toStringAsFixed(2)}%',
      lossAmountFormatted: '-₹${domain.lossAmount.toStringAsFixed(2)}',
      isSignificant: domain.isSignificantLoss,
    );
  }
}

class WebPerformanceIndicator {
  final String label;
  final double value;
  final bool isPositive;
  final String iconName;

  const WebPerformanceIndicator({
    required this.label,
    required this.value,
    required this.isPositive,
    required this.iconName,
  });

  String get valueFormatted => '${isPositive ? '+' : ''}${value.toStringAsFixed(2)}%';
}

/// View state for portfolio summary
class WebSummaryViewState {
  final bool isLoading;
  final bool isEmpty;
  final DateTime? lastUpdated;
  final DataSource dataSource;
  final PerformanceCategory performanceCategory;

  const WebSummaryViewState({
    required this.isLoading,
    required this.isEmpty,
    required this.lastUpdated,
    required this.dataSource,
    required this.performanceCategory,
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

  String get dataSourceDisplay => dataSource.displayName;
}

/// Styling classes
class WebOverviewStyle {
  final String primaryColor;
  final String backgroundColor;
  final String textColor;
  final String iconName;
  final String gradientColors;

  const WebOverviewStyle({
    required this.primaryColor,
    required this.backgroundColor,
    required this.textColor,
    required this.iconName,
    required this.gradientColors,
  });

  static const WebOverviewStyle positive = WebOverviewStyle(
    primaryColor: '#10B981',
    backgroundColor: '#F0FDF4',
    textColor: '#065F46',
    iconName: 'trending_up',
    gradientColors: 'linear-gradient(135deg, #10B981 0%, #059669 100%)',
  );

  static const WebOverviewStyle negative = WebOverviewStyle(
    primaryColor: '#EF4444',
    backgroundColor: '#FEF2F2',
    textColor: '#991B1B',
    iconName: 'trending_down',
    gradientColors: 'linear-gradient(135deg, #EF4444 0%, #DC2626 100%)',
  );

  static const WebOverviewStyle neutral = WebOverviewStyle(
    primaryColor: '#6B7280',
    backgroundColor: '#F9FAFB',
    textColor: '#374151',
    iconName: 'trending_flat',
    gradientColors: 'linear-gradient(135deg, #6B7280 0%, #4B5563 100%)',
  );

  factory WebOverviewStyle.fromPerformance(bool isPositive, bool isTodayPositive) {
    if (isPositive) return positive;
    return negative;
  }
}

class WebPerformanceStyle {
  final String color;
  final String backgroundColor;
  final String borderColor;

  const WebPerformanceStyle({
    required this.color,
    required this.backgroundColor,
    required this.borderColor,
  });

  static const WebPerformanceStyle excellent = WebPerformanceStyle(
    color: '#059669',
    backgroundColor: '#D1FAE5',
    borderColor: '#10B981',
  );

  static const WebPerformanceStyle good = WebPerformanceStyle(
    color: '#0369A1',
    backgroundColor: '#DBEAFE',
    borderColor: '#3B82F6',
  );

  static const WebPerformanceStyle fair = WebPerformanceStyle(
    color: '#D97706',
    backgroundColor: '#FEF3C7',
    borderColor: '#F59E0B',
  );

  static const WebPerformanceStyle poor = WebPerformanceStyle(
    color: '#DC2626',
    backgroundColor: '#FEE2E2',
    borderColor: '#EF4444',
  );

  static const WebPerformanceStyle terrible = WebPerformanceStyle(
    color: '#991B1B',
    backgroundColor: '#FEE2E2',
    borderColor: '#DC2626',
  );

  static const WebPerformanceStyle neutral = WebPerformanceStyle(
    color: '#4B5563',
    backgroundColor: '#F3F4F6',
    borderColor: '#6B7280',
  );

  factory WebPerformanceStyle.fromCategory(PerformanceCategory category) {
    switch (category) {
      case PerformanceCategory.excellent:
        return excellent;
      case PerformanceCategory.good:
        return good;
      case PerformanceCategory.fair:
        return fair;
      case PerformanceCategory.poor:
        return poor;
      case PerformanceCategory.terrible:
        return terrible;
    }
  }
}

class WebInsightsStyle {
  final String color;
  final String iconName;

  const WebInsightsStyle({
    required this.color,
    required this.iconName,
  });

  static const WebInsightsStyle positive = WebInsightsStyle(
    color: '#10B981',
    iconName: 'sentiment_very_satisfied',
  );

  static const WebInsightsStyle negative = WebInsightsStyle(
    color: '#EF4444',
    iconName: 'sentiment_very_dissatisfied',
  );

  static const WebInsightsStyle neutral = WebInsightsStyle(
    color: '#6B7280',
    iconName: 'sentiment_neutral',
  );

  factory WebInsightsStyle.fromSentiment(String sentiment) {
    switch (sentiment.toLowerCase()) {
      case 'positive':
        return positive;
      case 'negative':
        return negative;
      default:
        return neutral;
    }
  }
}