/// Display options for investment card features
class InvestmentDisplayOptions {
  final bool showInvestmentDetails;
  final bool showCurrentPrice;
  final bool showQuantity;
  final bool showAveragePrice;

  const InvestmentDisplayOptions({
    this.showInvestmentDetails = true,
    this.showCurrentPrice = true,
    this.showQuantity = true,
    this.showAveragePrice = true,
  });

  /// Default options showing all details
  static const InvestmentDisplayOptions full = InvestmentDisplayOptions();

  /// Minimal options for compact displays
  static const InvestmentDisplayOptions minimal = InvestmentDisplayOptions(
    showInvestmentDetails: false,
    showCurrentPrice: false,
    showQuantity: false,
    showAveragePrice: false,
  );

  /// Watchlist options showing basic info
  static const InvestmentDisplayOptions watchlist = InvestmentDisplayOptions(
    showInvestmentDetails: false,
    showCurrentPrice: false,
  );

  /// Create a copy with modified values
  InvestmentDisplayOptions copyWith({
    bool? showInvestmentDetails,
    bool? showCurrentPrice,
    bool? showQuantity,
    bool? showAveragePrice,
  }) {
    return InvestmentDisplayOptions(
      showInvestmentDetails:
          showInvestmentDetails ?? this.showInvestmentDetails,
      showCurrentPrice: showCurrentPrice ?? this.showCurrentPrice,
      showQuantity: showQuantity ?? this.showQuantity,
      showAveragePrice: showAveragePrice ?? this.showAveragePrice,
    );
  }
}
