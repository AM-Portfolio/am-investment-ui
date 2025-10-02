import 'package:freezed_annotation/freezed_annotation.dart';

part 'portfolio_list.freezed.dart';
part 'portfolio_list.g.dart';

/// Domain entity representing a single portfolio item
@freezed
class PortfolioItem with _$PortfolioItem {
  const PortfolioItem._();

  const factory PortfolioItem({
    required String portfolioId,
    required String portfolioName,
  }) = _PortfolioItem;

  /// Create from JSON
  factory PortfolioItem.fromJson(Map<String, dynamic> json) =>
      _$PortfolioItemFromJson(json);

  /// Helper getter to check if portfolio has a valid ID
  bool get hasValidId => portfolioId.isNotEmpty;

  /// Helper getter to check if portfolio has a valid name
  bool get hasValidName => portfolioName.isNotEmpty;

  /// Helper getter to check if portfolio is valid
  bool get isValid => hasValidId && hasValidName;
}

/// Domain entity representing a list of portfolios
@freezed
class PortfolioList with _$PortfolioList {
  const PortfolioList._();

  const factory PortfolioList({
    required String userId,
    @Default([]) List<PortfolioItem> portfolios,
    required DateTime lastUpdated,
  }) = _PortfolioList;

  /// Create from JSON
  factory PortfolioList.fromJson(Map<String, dynamic> json) =>
      _$PortfolioListFromJson(json);

  /// Helper getter to check if the list is empty
  bool get isEmpty => portfolios.isEmpty;

  /// Helper getter to check if the list is not empty
  bool get isNotEmpty => portfolios.isNotEmpty;

  /// Helper getter to get the count of portfolios
  int get count => portfolios.length;

  /// Helper method to find portfolio by ID
  PortfolioItem? findById(String portfolioId) {
    try {
      return portfolios.firstWhere(
        (portfolio) => portfolio.portfolioId == portfolioId,
      );
    } catch (_) {
      return null;
    }
  }

  /// Helper method to find portfolio by name
  PortfolioItem? findByName(String portfolioName) {
    try {
      return portfolios.firstWhere(
        (portfolio) =>
            portfolio.portfolioName.toLowerCase() ==
            portfolioName.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Helper method to check if portfolio exists by ID
  bool containsPortfolioId(String portfolioId) {
    return portfolios.any((portfolio) => portfolio.portfolioId == portfolioId);
  }

  /// Helper method to check if portfolio exists by name
  bool containsPortfolioName(String portfolioName) {
    return portfolios.any(
      (portfolio) =>
          portfolio.portfolioName.toLowerCase() == portfolioName.toLowerCase(),
    );
  }

  /// Helper method to get all valid portfolios
  List<PortfolioItem> get validPortfolios =>
      portfolios.where((portfolio) => portfolio.isValid).toList();

  /// Helper method to get portfolio names as a list
  List<String> get portfolioNames =>
      portfolios.map((portfolio) => portfolio.portfolioName).toList();

  /// Helper method to get portfolio IDs as a list
  List<String> get portfolioIds =>
      portfolios.map((portfolio) => portfolio.portfolioId).toList();
}
