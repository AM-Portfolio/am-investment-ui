/// Portfolio analytics request model
class PortfolioAnalyticsRequest {
  final CoreIdentifiers coreIdentifiers;
  final FeatureToggles featureToggles;
  final FeatureConfiguration featureConfiguration;
  final Pagination pagination;

  const PortfolioAnalyticsRequest({
    required this.coreIdentifiers,
    required this.featureToggles,
    required this.featureConfiguration,
    required this.pagination,
  });
}

/// Core identifiers for analytics request
class CoreIdentifiers {
  final String portfolioId;

  const CoreIdentifiers({required this.portfolioId});
}

/// Feature toggles to control analytics inclusion
class FeatureToggles {
  final bool includeHeatmap;
  final bool includeMovers;
  final bool includeSectorAllocation;
  final bool includeMarketCapAllocation;

  const FeatureToggles({
    required this.includeHeatmap,
    required this.includeMovers,
    required this.includeSectorAllocation,
    required this.includeMarketCapAllocation,
  });
}

/// Configuration for analytics features
class FeatureConfiguration {
  final int moversLimit;

  const FeatureConfiguration({required this.moversLimit});
}

/// Pagination configuration
class Pagination {
  final int page;
  final int size;
  final String sortBy;
  final String sortDirection;
  final bool returnAllData;

  const Pagination({
    required this.page,
    required this.size,
    required this.sortBy,
    required this.sortDirection,
    required this.returnAllData,
  });
}
